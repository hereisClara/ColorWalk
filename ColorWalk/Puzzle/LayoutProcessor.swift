//
//  LayoutProcessor.swift
//  ColorWalk
//
//  Created by Clara on 2026/2/1.
//

import Foundation

enum LayoutPattern {
    case verticle
    case horizontal
    case grid
}

struct LayoutProcessor {
    static func getFrames(for count: Int, pattern: LayoutPattern, in size: CGSize) -> [CGRect] {
        let w = size.width
        let h = size.height
        var frames: [CGRect] = []
        
        switch (count, pattern) {
        case (2, .verticle):
            frames = [CGRect(x: 0, y: 0, width: w, height: h/2),
                      CGRect(x: 0, y: h/2, width: w, height: h/2)]
            
        case (2, .horizontal):
            frames = [CGRect(x: 0, y: 0, width: w/2, height: h),
                      CGRect(x: w/2, y: 0, width: w/2, height: h)]
            
        case (3, .verticle):
            let segment = h / 3
            for i in 0..<3 {
                frames.append(CGRect(x: 0, y: CGFloat(i) * segment, width: w, height: segment))
            }
            
        case (3, .horizontal):
            let segment = w / 3
            for i in 0..<3 {
                frames.append(CGRect(x: CGFloat(i) * segment, y: 0, width: segment, height: h))
            }
            
        case (4, _):
            let cw = w / 2, ch = h / 2
            frames = [CGRect(x: 0, y: 0, width: cw, height: ch),
                      CGRect(x: cw, y: 0, width: cw, height: ch),
                      CGRect(x: 0, y: ch, width: cw, height: ch),
                      CGRect(x: cw, y: ch, width: cw, height: ch)]
            
        case (6, _):
            let cw = w / 3, ch = h / 2
            for r in 0..<2 {
                for c in 0..<3 {
                    frames.append(CGRect(x: CGFloat(c) * cw, y: CGFloat(r) * ch, width: cw, height: ch))
                }
            }
            
        default: break
        }
        
        return frames
    }
}
