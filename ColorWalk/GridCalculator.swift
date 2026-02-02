//
//  GridCalculator.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/28.
//

import Foundation
import CoreGraphics

struct GridCalculator {
    static func clampScale(_ input: CGFloat) -> CGFloat {
        return max(input, 1.0)
    }
    
    static func clampOffset(_ currentOffset: CGFloat,
                            contentSize: CGFloat,
                            containerSize: CGFloat) -> CGFloat {
        
        if contentSize <= containerSize { return 0 }
        let limit = (contentSize - containerSize) / 2
        
        return min(max(currentOffset, -limit), limit)
    }
}
