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
                Picker("選擇版面", selection: $viewModel.targetSlotCount) {
                    Text("2格").tag(2)
                    Text("3格").tag(3)
                    Text("4格").tag(4)
                    Text("6格").tag(6)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: viewModel.targetSlotCount) { oldCount, newCount in
                    if newCount == 2 || newCount == 3 {
                        viewModel.currentPattern = .horizontal
                    } else {
                        viewModel.currentPattern = .grid
                    }
                }
                
                Spacer()
                PuzzleContainerView(
                    items: viewModel.walkPhotos,
                    targetCount: viewModel.targetSlotCount,
                    pattern: viewModel.currentPattern
                ) { photo in
                    ImageGridCell(image: photo)
                }
                .aspectRatio(1, contentMode: .fit) 
                .padding()
                
                Spacer()
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

