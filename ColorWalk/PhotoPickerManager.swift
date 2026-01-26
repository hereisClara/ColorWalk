//
//  PhotoPickerManager.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/26.
//

import Photos
import PhotosUI
import UIKit

class PhotoPickerManager: NSObject, PHPickerViewControllerDelegate {
    
    var didPickData: ((UIImage, CLLocation?, Date?) -> Void)?

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        if results.isEmpty { return }
        
        for result in results {
            let provider = result.itemProvider
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let uiImage = image as? UIImage else { return }
                    
                    var location: CLLocation?
                    var date: Date?
                    
                    if let assetId = result.assetIdentifier {
                        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject
                        
                        if let photoAsset = asset {
                            let calendar = Calendar.current
                            
                            let isToday = calendar.isDateInToday(photoAsset.creationDate ?? Date.distantPast)
                            
                            let hasLocation = photoAsset.location != nil
                            
                            if isToday && hasLocation {
                                DispatchQueue.main.async {
                                    self?.didPickData?(uiImage, photoAsset.location, photoAsset.creationDate)
                                }
                            } else {
                                print("這張照片不符合條件（不是今天或沒有位置資訊），已跳過")
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self?.didPickData?(uiImage, location, date)
                    }
                }
            }
        }
    }
}
