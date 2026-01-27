//
//  AssetManager.swift
//  ColorWalk
//
//  Created by Clara on 2026/1/26.
//

import Photos
import UIKit

class AssetManager {
    static func fetchTodayAssets() -> [PHAsset] {
        let options = PHFetchOptions()
        
        let startOfDay = Calendar.current.startOfDay(for: Date())
        options.predicate = NSPredicate(format: "creationDate >= %@", startOfDay as NSDate)
        
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        var assets: [PHAsset] = []
        
        fetchResult.enumerateObjects { asset, _, _ in
            if asset.location != nil {
                assets.append(asset)
            }
        }
        return assets
    }
}
