//
//  AssetsPhotoViewController+AssetsManager.swift
//  AssetsPickerViewController
//
//  Created by DragonCherry on 2020/07/02.
//

import UIKit
import Photos

// MARK: - AssetsManagerDelegate
extension AssetsPhotoViewController: AssetsManagerDelegate {
    
    public func assetsManagerFetched() {}
    
    public func assetsManager(authorizationStatusChanged oldStatus: PHAuthorizationStatus, newStatus: PHAuthorizationStatus) {
        if #available(iOS 14, *) {
            if newStatus == .limited {
                updateNoPermissionView()
                AssetsManager.shared.fetchAssets(isRefetch: true, completion: { [weak self] (_) in
                    DispatchQueue.main.async { [weak self] in
                        self?.collectionView.reloadData()
                    }
                })
            } else {
                updateNoPermissionView()
            }
        } else {
            if oldStatus != .authorized {
                if newStatus == .authorized {
                    updateNoPermissionView()
                    AssetsManager.shared.fetchAssets(isRefetch: true, completion: { [weak self] (_) in
                        DispatchQueue.main.async { [weak self] in
                            self?.collectionView.reloadData()
                        }
                    })
                }
            } else {
                updateNoPermissionView()
            }
        }
    }
    
    public func assetsManager(reloadedAlbumsInSection section: Int) {}
    public func assetsManager(insertedAlbums albums: [PHAssetCollection], at indexPaths: [IndexPath]) {}
    
    public func assetsManager(removedAlbums albums: [PHAssetCollection], at indexPaths: [IndexPath]) {
        logi("removedAlbums at indexPaths: \(indexPaths)")
        guard let selectedAlbum = AssetsManager.shared.selectedAlbum else {
            logw("selected album is nil.")
            return
        }
        if albums.contains(selectedAlbum) {
            AssetsManager.shared.selectDefaultAlbum()
            updateNavigationStatus()
            updateFooter()
            collectionView.reloadData()
        }
    }
    
    public func assetsManager(updatedAlbums albums: [PHAssetCollection], at indexPaths: [IndexPath]) {}
    public func assetsManager(reloadedAlbum album: PHAssetCollection, at indexPath: IndexPath) {}
    
    public func assetsManager(insertedAssets assets: [PHAsset], at indexPaths: [IndexPath]) {
        logi("insertedAssets at: \(indexPaths)")
        collectionView.insertItems(at: indexPaths)
        updateFooter()
    }
    
    public func assetsManager(removedAssets assets: [PHAsset], at indexPaths: [IndexPath]) {
        logi("removedAssets at: \(indexPaths)")
        for removedAsset in assets {
            if let index = selectedArray.firstIndex(of: removedAsset) {
                selectedArray.remove(at: index)
                selectedMap.removeValue(forKey: removedAsset.localIdentifier)
            }
        }
        collectionView.deleteItems(at: indexPaths)
        updateSelectionCount()
        updateNavigationStatus()
        updateFooter()
    }
    
    public func assetsManager(updatedAssets assets: [PHAsset], at indexPaths: [IndexPath]) {
        logi("updatedAssets at: \(indexPaths)")
        let indexPathsToReload = collectionView.indexPathsForVisibleItems.filter { indexPaths.contains($0) }
        
        collectionView.isUserInteractionEnabled = false
        selectNewlyAddedAssetIfNeeded { [weak self] (newlyaddedIndexPath) in
            if let indexPathToReload = indexPathsToReload.first, indexPathsToReload.count == 1, newlyaddedIndexPath == indexPathToReload {
                logd("Ignore newly added asset.")
            } else {
                self?.collectionView.reloadItems(at: indexPathsToReload)
            }
            self?.updateNavigationStatus()
            self?.updateFooter()
            self?.collectionView.isUserInteractionEnabled = true
        }
    }
}

extension AssetsPhotoViewController: AssetsPickerManagerDelegate {
    func assetsPickerManagerSavedAsset(identifier: String) {
        self.newlySavedIdentifier = identifier
    }
}

extension AssetsPhotoViewController {
    func selectNewlyAddedAssetIfNeeded(completion: @escaping ((IndexPath?) -> Void)) {
        var indexPathToSelect: IndexPath?
        
        if let newlySavedIdentifier = self.newlySavedIdentifier {
            self.newlySavedIdentifier = nil
            guard pickerConfig.assetIsAutoSelectAssetFromCamera else {
                completion(nil)
                return
            }
            var index: Int = NSNotFound
            guard let fetchResult = AssetsManager.shared.fetchResult else { return }
            fetchResult.enumerateObjects { (asset, idx, stop) in
                if asset.localIdentifier == newlySavedIdentifier {
                    index = idx
                    stop.pointee = true
                }
            }
            if index == NSNotFound {
                return
            }
            let ip = IndexPath(row: index, section: 0)
            indexPathToSelect = ip
            if selectedArray.count < pickerConfig.assetsMaximumSelectionCount {
                select(at: ip)
            } else {
                if pickerConfig.assetIsForcedSelectAssetFromCamera {
                    select(at: ip)
                    deselectOldestIfNeeded(isForced: true)
                    updateSelectionCount()
                }
            }
        }
        if let indexPathToSelect = indexPathToSelect {
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                guard let `self` = self else { return }
                self.selectCell(at: indexPathToSelect)
                if let addedCell = self.collectionView.cellForItem(at: indexPathToSelect) {
                    if !self.collectionView.fullyVisibleCells.contains(addedCell) {
                        self.collectionView.scrollToItem(at: indexPathToSelect, at: .bottom, animated: false)
                    }
                } else {
                    self.collectionView.scrollToItem(at: indexPathToSelect, at: .bottom, animated: false)
                }
                completion(indexPathToSelect)
            }
        } else {
            completion(nil)
        }
    }
}
