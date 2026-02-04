//
//  ColorCameraView.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/27.
//

import Foundation
import SwiftUI

struct ColorCameraView: View {
    @StateObject private var camera = CameraManager()
    @State private var score: Double = 0.0
    @Environment(\.dismiss) var dismiss
    
    @State private var currentZoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    
    @State private var focusPoint: CGPoint = .zero
    @State private var isShowingFocusBox = false
    
    var onCapture: (UIImage, Double) -> Void
    
    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
                .onTapGesture { location in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.focusPoint = location
                        self.isShowingFocusBox = true
                    }
                    let screenSize = UIScreen.main.bounds.size
                    let x = location.y / screenSize.height
                    let y = 1.0 - (location.x / screenSize.width)
                    let focusPoint = CGPoint(x: x, y: y)
                    
                    camera.focus(at: focusPoint)
                    
                }
                .simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / 1.0
                            let newZoom = lastZoom * delta
                            camera.setZoom(factor: newZoom)
                            currentZoom = newZoom
                        }
                        .onEnded { value in
                            lastZoom = currentZoom
                        }
                )
            
            if isShowingFocusBox {
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 70, height: 70)
                    .position(focusPoint)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isShowingFocusBox = false
                            }
                        }
                    }
            }
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        camera.takePhoto()
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 85, height: 85)
                            
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                                )
                            
                            VStack(spacing: 0) {
                                Text("\(Int(score * 100))")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                Text("%")
                                    .font(.system(size: 10, weight: .semibold))
                            }
                            .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            camera.checkPermission()
            
            camera.onColorScored = { newScore in
                self.score = newScore
            }
            
            camera.onImageCaptured = { uiImage in
                onCapture(uiImage, self.score)
                dismiss()
            }
        }
    }
}
