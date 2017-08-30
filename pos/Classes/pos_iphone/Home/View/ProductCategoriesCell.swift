//
//  ProductCategoriesCell.swift
//  pos
//
//  Created by luan on 2017/8/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ProductCategoriesCell: UICollectionViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection: UICollectionView!
    var categoriesArray = [CategoriesModel]()
    
    func refreshCategories(_ array: [CategoriesModel]) {
        categoriesArray = array
        collection.reloadData()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (kScreenWidth - 30) / 2.5
        return CGSize(width: cellWidth, height: 50)
    }
    
    // MARK: - UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCategoriesItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCategoriesItemCell", for: indexPath) as! ProductCategoriesItemCell
        cell.itemTitle.text = categoriesArray[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
