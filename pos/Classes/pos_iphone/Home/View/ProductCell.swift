//
//  ProductCell.swift
//  pos
//
//  Created by luan on 2017/8/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

@objc protocol ProductCell_Delegate {
    func addShopCart(_ row: Int)
}

class ProductCell: UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    @IBOutlet weak var exTax: UILabel!
    weak var delegate: ProductCell_Delegate?
    
    @IBAction func shopCartClick(_ sender: UIButton) {
        delegate?.addShopCart(tag)
    }
    
}
