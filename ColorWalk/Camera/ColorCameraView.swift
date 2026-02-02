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
    var onCapture: (UIImage, Double) -> Void
    
    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
                .gesture(
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
                
                VStack(spacing: 10) {
                    Text("藍色相符度")
                        .font(.caption)
                        .bold()
                    
                    Text("\(Int(score * 100))%")
                        .font(.system(size: 50, weight: .black, design: .rounded))
                    
                    ProgressView(value: score)
                        .accentColor(.blue)
                        .padding(.horizontal, 50)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(20)
                .padding(.bottom, 50)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        camera.takePhoto()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 80, height: 80)
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
