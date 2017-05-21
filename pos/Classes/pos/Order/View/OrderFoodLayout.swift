//
//  OrderFoodLayout.swift
//  pos
//
//  Created by luan on 2017/5/21.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

@objc protocol OrderFoodLayout_Delegate {
    func collectionView(collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat
}

class OrderFoodLayout: UICollectionViewLayout {
    
    weak var delegate : OrderFoodLayout_Delegate?
    var endPoint = CGPoint.zero
    var count = 0
    var sectionInset = UIEdgeInsets.zero
    var lineSpacing: CGFloat = 0.5
    var itemSpacing: CGFloat = 0.5
    var itemHeigh: CGFloat = 50.0
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        super.prepare()
        endPoint = CGPoint.zero
        count = (collectionView?.numberOfItems(inSection: 0))!
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: (collectionView?.frame.size.width)!, height: endPoint.y)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let width = delegate?.collectionView(collectionView: collectionView!, indexPath: indexPath)
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        let judge = endPoint.x + width! + itemSpacing + sectionInset.right
        if judge > collectionView!.frame.size.width {
            x = sectionInset.left
            y = endPoint.y + lineSpacing
        } else {
            if indexPath.item == 0 {
                x = sectionInset.left
                y = sectionInset.top
            } else {
                x = endPoint.x + itemSpacing
                y = endPoint.y - itemHeigh
            }
        }
        
        endPoint = CGPoint(x: x + width!, y: y + itemHeigh)
        attr.frame = CGRect(x: x, y: y, width: width!, height: itemHeigh)
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrsArray = [UICollectionViewLayoutAttributes]()
        for i in 0..<count {
            attrsArray.append(layoutAttributesForItem(at: IndexPath(item: i, section: 0))!)
        }
        return attrsArray
    }
    
}
