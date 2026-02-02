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
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            let score = calculateBlueScore(from: ciImage)
            
            DispatchQueue.main.async {
                self.onColorScored?(score)
            }
        }
    
    func calculateBlueScore(from ciImage: CIImage) -> Double {
        let context = CIContext()
        
        let normalizedImage = ciImage.transformed(by: CGAffineTransform(translationX: -ciImage.extent.origin.x, y: -ciImage.extent.origin.y))
        
        let targetExtent = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        guard let cgImage = context.createCGImage(normalizedImage, from: normalizedImage.extent) else { return 0 }
        
        let width = 100
        let height = 100
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let renderContext = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return 0 }
        
        renderContext.draw(cgImage, in: targetExtent)

        var bluePixelCount: Double = 0
        let totalPixels = width * height
        let targetHue: CGFloat = 220.0
        let maxDistance: CGFloat = 50.0

        for i in stride(from: 0, to: totalPixels * 4, by: 4) {
            let r = CGFloat(rawData[i]) / 255.0
            let g = CGFloat(rawData[i+1]) / 255.0
            let b = CGFloat(rawData[i+2]) / 255.0
            
            let color = UIColor(red: r, green: g, blue: b, alpha: 1)
            var h: CGFloat = 0, s: CGFloat = 0, v: CGFloat = 0, a: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
            
            let hueDegrees = h * 360
            let diff = abs(hueDegrees - targetHue)
            let shortestDiff = min(diff, 360 - diff)
            
            if shortestDiff < maxDistance && s > 0.15 && v > 0.15 {
                bluePixelCount += 1.0
            }
        }
        
        let rawScore = bluePixelCount / Double(totalPixels)
        return mapToSensoryScore(rawScore)
    }
    
    private func compareToTargetColor(image: CIImage) -> Double {
            
            let smallImage = image.transformed(by: CGAffineTransform(scaleX: 0.1, y: 0.1))
            let context = CIContext()
            
            guard let cgImage = context.createCGImage(smallImage, from: smallImage.extent) else { return 0 }
            
            let width = cgImage.width
            let height = cgImage.height
            let totalPixels = width * height
            
            guard let data = cgImage.dataProvider?.data,
                  let ptr = CFDataGetBytePtr(data) else { return 0 }
            
            var totalWeightedScore: Double = 0
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
                
                if shortestDiff < maxDistance {
                    let hueScore = 1.0 - (shortestDiff / maxDistance)
                    totalWeightedScore += Double(hueScore * s * v)
                }
            }
            
            return totalWeightedScore / Double(totalPixels)
        }
    
    private func mapToSensoryScore(_ raw: Double) -> Double {
        if raw < 0.05 { return 0 }
        if raw < 0.4 {
            return raw * 2.0
        } else {
            let boosted = 0.7 + (raw - 0.4) * 0.33
            return min(boosted, 1.0)
        }
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
