//
//  PhotoPickingViewModel.swift
//  ColorWalk
//
//  Created by 小妍寶 on 2026/1/22.
//

import Foundation
import PhotosUI
import SwiftUI
import SwiftData

@MainActor
class PhotoPickingViewModel: ObservableObject {
    
    var modelContext: ModelContext
    
    var selectedItems: [PhotosPickerItem] = [] {
        didSet { loadImages() }
    }
    var images: [UIImage] = []
    @Published var isLoading = false
    
    init(modelContext: ModelContext, selectedItems: [PhotosPickerItem] = [], images: [UIImage] = [], isLoading: Bool = false) {
        self.modelContext = modelContext
        self.selectedItems = selectedItems
        self.images = images
        self.isLoading = isLoading
    }
    
    private func loadImages() {
        Task {
            isLoading = true
            var loadedImages: [UIImage] = []
            
            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    loadedImages.append(uiImage)
                }
            }
            
            self.images = loadedImages
            isLoading = false
        }
    }
}
