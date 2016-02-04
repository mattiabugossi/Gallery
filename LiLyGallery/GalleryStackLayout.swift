//
//  GalleryStackLayout.swift
//  LiLyGallery
//
//  Created by Mattia Bugossi on 1/27/16.
//  Copyright © 2016 Mattia Bugossi. All rights reserved.
//

import UIKit

class GalleryStackLayout: UICollectionViewLayout {

    var numberOfPictures = 2
    var itemSize = CGSize(width: 120, height: 120)
    var centerPoint = CGPointZero
    var anglesArray = [CGFloat]()
    var attributesArray = [UICollectionViewLayoutAttributes]()
    
    override func prepareLayout() {
        let size = collectionView!.bounds.size
        var center: CGPoint
        
        if centerPoint.x > 0 {
            center = CGPoint(x: centerPoint.x, y: centerPoint.y)
        } else {
            center = CGPoint(x: size.width / 2, y: size.height / 2)
        }
        
        let itemCount = collectionView!.numberOfItemsInSection(0)
        
        anglesArray.removeAll()
        anglesArray.insert(0, atIndex: 0)
        for i in 1 ..< numberOfPictures * 10 {
            anglesArray.append(anglesArray[i - 1] + CGFloat(-M_1_PI / 1.2))
        }
        
        for i in 0 ..< itemCount {
            let angleIndex = i % (numberOfPictures * 10)
            let angle = anglesArray[angleIndex]
            let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: i, inSection: 0))
            attribute.size = itemSize
            attribute.center = center
            attribute.transform = CGAffineTransformMakeRotation(angle)
            attribute.alpha = i > numberOfPictures ? 0 : 1
            attribute.zIndex = itemCount - i
            attributesArray.append(attribute)
        }
    }
    
    override func invalidateLayout() {
        attributesArray.removeAll()
    }
    
    override func collectionViewContentSize() -> CGSize {
        return collectionView?.bounds.size ?? CGSizeZero
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return attributesArray[indexPath.item]
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributesArray
    }
    
}
