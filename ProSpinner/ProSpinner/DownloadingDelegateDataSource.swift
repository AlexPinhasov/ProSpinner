//
//  DownloadingDelegateDataSource.swift
//  ProSpinner
//
//  Created by AlexP on 4.6.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import Foundation
import SpriteKit

class DownloadingDelegateDataSource: NSObject,
                                     UICollectionViewDelegate,
                                     UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout
{
    private var dataModel = [SKTexture]()
    private weak var collectionView: UICollectionView?
    
    
    init(collectionView: UICollectionView)
    {
        super.init()
        self.collectionView = collectionView
    }
    
    func removeObserver()
    {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: NotificationName.notifyWithNewTexture.rawValue),
                                                  object: nil)
    }
    
    func resetDataModel()
    {
        dataModel = [SKTexture]()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func newSpinnerAvailable(spinnerTexture: SKTexture)
    {
        dataModel.append(spinnerTexture)
        collectionView?.insertItems(at: [IndexPath(row: dataModel.count - 1, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return dataModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionCell
        {
            cell.image.image = UIImage(cgImage: dataModel[indexPath.row].cgImage())
            cell.customView.layer.backgroundColor = UIColor.clear.cgColor
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: Int((collectionView.bounds.size.width / 3) - 13), height: Int((collectionView.bounds.size.width / 3) - 13))
    }
}
