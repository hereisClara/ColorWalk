//
//  PhotoPickingViewModel.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/22.
//

import Foundation
import PhotosUI
import SwiftUI
import SwiftData

@MainActor
class PhotoPickingViewModel: ObservableObject {
    @Published var walkPhotos: [WalkPhoto] = []
    @Published var isShowingPicker = false
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
           self.modelContext = modelContext
       }
    
    func handleSelectedAssets(_ assets: [PHAsset]) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat

        for asset in assets {
            let location = asset.location
            let date = asset.creationDate
            
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: 1080, height: 1080),
                                 contentMode: .aspectFill,
                                 options: options) { [weak self] image, _ in
                if let uiImage = image {
                    let newPhoto = WalkPhoto(image: uiImage, location: location, date: date, colorScore: 0)
                    DispatchQueue.main.async {
                        self?.walkPhotos.append(newPhoto)
                    }
                }
            }
        }
    }
    
    func addCameraPhoto(image: UIImage, score: Double, location: CLLocation?) {
        
        let newPhoto = WalkPhoto(
            image: image,
            location: location,
            date: Date(),
            colorScore: score
        )
        
        self.walkPhotos.append(newPhoto)
    }
}

struct WalkPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
    let location: CLLocation?
    let date: Date?
    let colorScore: Double?
}
