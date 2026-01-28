//
//  InstagramGridCell.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/28.
//

import Foundation
import SwiftUI

struct ImageGridCell: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            scale = lastScale * value.magnification
                        }
                        .onEnded { _ in
                            lastScale = scale
                            if scale < 1.0 {
                                withAnimation { scale = 1.0; lastScale = 1.0 }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
        }
        .frame(height: 150)
        .clipped() 
        .background(Color.gray.opacity(0.2))
    }
}
