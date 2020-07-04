//
//  BrowseContainerCollectionViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 01/05/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseContainerCollectionViewCell: UICollectionViewCell {
    @IBOutlet var collectionView: UICollectionView!

    private weak var parentController: BrowseCollectionViewController?
    private var entities: [Entity] = []
    
    class func requiredSize(layout: UICollectionViewFlowLayout) -> CGSize {
        let width = layout.collectionView?.bounds.width ?? AppDelegate.shared.viewPortSize.width
        return CGSize(width: width, height: BrowseEntityCollectionViewCell.requiredSize().height)
    }

    func fill(with entities: [Entity], parentController: BrowseCollectionViewController?) {
        self.entities = entities
        self.parentController = parentController
        collectionView.reloadData()
    }
}

extension BrowseContainerCollectionViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, EntityCellLongPressDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseEntityCollectionViewCell", for: indexPath) as! BrowseEntityCollectionViewCell
        
        cell.longPressDelegate = self
        cell.fill(with: entities[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return BrowseEntityCollectionViewCell.requiredSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        parentController?.showEntityView(entity: entities[indexPath.row], alternative: false)
    }
    
    func didLongPressCell(_ cell: EntityOwnerCell) {
        parentController?.showEntityView(entity: cell.entity, alternative: true)
    }
}
