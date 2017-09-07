//
//  ShopCartCell.swift
//  pos
//
//  Created by luan on 2017/9/5.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

@objc protocol ShopCartCell_Delegate {
    func deleteShopCart(_ row: Int)
}

class ShopCartCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var total: UILabel!
    weak var delegate: ShopCartCell_Delegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        delegate?.deleteShopCart(tag)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
