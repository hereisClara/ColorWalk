//
//  PhotoPickingView.swift
//  ColorWalk
//
//  Created by 小妍寶 on 2026/1/22.
//

import Foundation
import SwiftUI
import PhotosUI
import SwiftData

struct PhotoPickingView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PhotoPickingViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: PhotoPickingViewModel(modelContext: modelContext))
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.images.isEmpty {
                    ContentUnavailableView("打造拼圖", systemImage: "square.grid.2x2", description: Text("選取至少兩張照片"))
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(0..<viewModel.images.count, id: \.self) { index in
                            Image(uiImage: viewModel.images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 150)
                                .clipped()
                        }
                    }
                    .background(Color.white)
                    .border(Color.white, width: 2)
                    .padding()
                    
                }
                
                Spacer()
                
                PhotosPicker(
                    selection: $viewModel.selectedItems,
                    maxSelectionCount: 9,
                    matching: .images,
                    label: {
                        Label("選取照片", systemImage: "photo.stack")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding()
                    }
                )
            }
            .navigationTitle("相片拼圖")
        }
    }
}

