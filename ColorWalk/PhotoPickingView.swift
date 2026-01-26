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
                            Image(uiImage: photo.image)
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
                    // 當使用者在 Picker 點選「完成」時，會執行這段
                    viewModel.handleSelectedAssets(selectedAssets)
                }
            }
        }
    }
}

