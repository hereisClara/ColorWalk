//
//  AssetThumbnail.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/26.
//

import Foundation
import SwiftUI
import Photos

struct AssetThumbnail: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120) 
                    .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 120, height: 120)
            }
        }
        .onAppear {
            requestImage()
        }
    }
    
    private func requestImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 200, height: 200),
                             contentMode: .aspectFill,
                             options: options) { result, _ in
            self.image = result
        }
    }
}
