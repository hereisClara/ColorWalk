//
//  PuzzleContainerView.swift
//  ColorWalk
//
//  Created by Clara on 2026/2/1.
//

import Foundation
import SwiftUI

struct PuzzleContainerView<Content: View, T: Identifiable>: View {
    let items: [T]
    let targetCount: Int
    let pattern: LayoutPattern
    let content: (T) -> Content
    
    var body: some View {
        Color.clear
            .aspectRatio(9/16, contentMode: .fit)
            .overlay(
                GeometryReader { geo in
                    let frames = LayoutProcessor.getFrames(for: targetCount, pattern: pattern, in: geo.size)
                    
                    ZStack(alignment: .topLeading) {
                        Color.black.opacity(0.05)
                        ForEach(0..<targetCount, id: \.self) { index in
                            let frame = (index < frames.count) ? frames[index] : .zero
                            
                            Group {
                                if index < items.count {
                                    content(items[index])
                                } else {
                                    ZStack {
                                        Color.gray.opacity(0.3)
                                        Image(systemName: "plus")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(width: frame.width, height: frame.height)
                            .clipped()
                            .border(Color.white, width: 0.5)
                            .offset(x: frame.origin.x, y: frame.origin.y)
                        }
                    }
                }
            )
    }
}
