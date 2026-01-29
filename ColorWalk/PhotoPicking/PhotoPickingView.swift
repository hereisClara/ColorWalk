//
//  PhotoPickingView.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/22.
//

import Foundation
import SwiftUI
import PhotosUI
import SwiftData

struct PhotoPickingView: View {
    
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PhotoPickingViewModel
    @State private var showCamera = false
    
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
                if viewModel.walkPhotos.isEmpty {
                    ContentUnavailableView("打造拼圖", systemImage: "square.grid.2x2", description: Text("選取至少兩張照片"))
                } else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(viewModel.walkPhotos) { photo in
                            ImageGridCell(image: photo)
                        }
                    }
                    .background(Color.white)
                    .border(Color.white, width: 2)
                    .padding()
                    
                }
                
            }
            .navigationTitle("相片拼圖")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isShowingPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingPicker) {
                TodayPickerView { selectedAssets in
                    viewModel.handleSelectedAssets(selectedAssets)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCamera = true }) {
                        Image(systemName: "camera.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                ColorCameraView { capturedImage, score in
                    viewModel.addCameraPhoto(
                        image: capturedImage,
                        score: score,
                        location: nil
                    )
                }
            }
        }
    }
}

