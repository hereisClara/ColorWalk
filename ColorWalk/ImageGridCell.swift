//
//  ImageGridCell.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/28.
//

import Foundation
import SwiftUI

struct ImageGridCell: View {
    let image: WalkPhoto
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var realImageSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            let containerSize = proxy.size
            
            Image(uiImage: image.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background(GeometryReader { imgProxy in
                    Color.clear.onChange(of: imgProxy.size, initial: true) { _, newSize in
                        realImageSize = newSize
                    }
                })
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: containerSize.width, height: containerSize.height)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = lastScale * value.magnification
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                if scale < 1.0 {
                                    scale = 1.0
                                    offset = .zero
                                } else {
                                    offset.width = GridCalculator.clampOffset(offset.width, contentSize: realImageSize.width * scale, containerSize: containerSize.width)
                                    offset.height = GridCalculator.clampOffset(offset.height, contentSize: realImageSize.height * scale, containerSize: containerSize.height)
                                }
                            }
                            lastScale = scale
                            lastOffset = offset
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            guard realImageSize != .zero else { return }
                            
                            let newX = lastOffset.width + value.translation.width
                            let newY = lastOffset.height + value.translation.height
                            
                            let currentW = realImageSize.width * scale
                            let currentH = realImageSize.height * scale
                            
                            offset.width = GridCalculator.clampOffset(newX, contentSize: currentW, containerSize: containerSize.width)
                            offset.height = GridCalculator.clampOffset(newY, contentSize: currentH, containerSize: containerSize.height)
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
        }
        .frame(height: 180)
        .clipped()
        .background(Color.gray.opacity(0.2))
    }
}
