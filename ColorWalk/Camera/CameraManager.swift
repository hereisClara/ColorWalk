//
//  CameraManager.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/27.
//

import Foundation
import AVFoundation
import UIKit

class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDevice: AVCaptureDevice? {
        return (session.inputs.first as? AVCaptureDeviceInput)?.device
    }
    private var frameCount = 0
    var onColorScored: ((Double) -> Void)?
    var onImageCaptured: ((UIImage) -> Void)?
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status { self.setupSession() }
            }
        default: break
        }
    }
    
    func setZoom(factor: CGFloat) {
        guard let device = videoDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 5.0)
            let newZoomFactor = max(1.0, min(factor, maxZoom))
            
            device.videoZoomFactor = newZoomFactor
            device.unlockForConfiguration()
        } catch {
            print("無法調整縮放: \(error)")
        }
    }
    
    private func setupSession() {
        session.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) { session.addInput(input) }
        
        if session.canAddOutput(photoOutput) {
                    session.addOutput(photoOutput)
                }
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func takePhoto() {
            let settings = AVCapturePhotoSettings()
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        frameCount += 1
        guard frameCount % 20 == 0 else { return }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let currentFrame = CIImage(cvPixelBuffer: pixelBuffer)
        let score = calculateBlueScore(image: currentFrame)
        
        DispatchQueue.main.async {
            self.onColorScored?(score)
        }
    }
    
    private func calculateBlueScore(image: CIImage) -> Double {
        
        let filter = CIFilter(name: "CILanczosScaleTransform")
        filter?.setValue(image, forKey: kCIInputImageKey)
        filter?.setValue(0.05, forKey: kCIInputScaleKey)
        
        guard let smallImage = filter?.outputImage else { return 0 }
        
        return compareToTargetColor(image: smallImage)
    }
    
    private func compareToTargetColor(image: CIImage) -> Double {
        let context = CIContext()
        guard let cgImage = context.createCGImage(image, from: image.extent) else { return 0 }
        
        let width = cgImage.width
        let height = cgImage.height
        let totalPixels = width * height
        var totalWeightedScore: Double = 0
        
        guard let data = cgImage.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return 0 }
        
        let targetHue: CGFloat = 220.0
        let maxDistance: CGFloat = 50.0
        
        for i in stride(from: 0, to: totalPixels * 4, by: 4) {
            let r = CGFloat(ptr[i]) / 255.0
            let g = CGFloat(ptr[i+1]) / 255.0
            let b = CGFloat(ptr[i+2]) / 255.0
            
            let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
            
            let hueDegrees = h * 360
            
            let diff = abs(hueDegrees - targetHue)
            let shortestDiff = min(diff, 360 - diff)
            
            var hueScore: CGFloat = 0
            if shortestDiff < maxDistance {
                hueScore = 1.0 - (shortestDiff / maxDistance)
            }
            
            let finalPixelScore = hueScore * s * v
            
            totalWeightedScore += Double(finalPixelScore)
        }
        
        return totalWeightedScore / Double(totalPixels)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.onImageCaptured?(image)
        }
    }
}
