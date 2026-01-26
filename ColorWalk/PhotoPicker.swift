//
//  PhotoPicker.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/26.
//

import Foundation
import PhotosUI
import Photos
import SwiftUI

struct PhotoPicker: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = PHPickerViewController
    
    let configuration: PHPickerConfiguration
    let delegate: PHPickerViewControllerDelegate

    func makeUIViewController(context: Context) -> PHPickerViewController {
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = delegate
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
}
