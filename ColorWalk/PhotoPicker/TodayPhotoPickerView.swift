//
//  TodayPhotoPickerView.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/26.
//

import Foundation
import SwiftUI
import Photos

struct TodayPickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var assets: [PHAsset] = []
    @State private var selectedAssets: Set<PHAsset> = []
    var onSelected: ([PHAsset]) -> Void
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(assets, id: \.localIdentifier) { asset in
                        ZStack(alignment: .topTrailing) {
                            AssetThumbnail(asset: asset)
                                .onTapGesture {
                                    if selectedAssets.contains(asset) {
                                        selectedAssets.remove(asset)
                                    } else {
                                        selectedAssets.insert(asset)
                                    }
                                }
                            
                            if selectedAssets.contains(asset) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                    .padding(5)
                            }
                        }
                    }
                }
            }
            .navigationTitle("今天拍的照片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        onSelected(Array(selectedAssets))
                        dismiss()
                    }
                }
            }
            .onAppear {
                self.assets = AssetManager.fetchTodayAssets()
            }
        }
    }
}
