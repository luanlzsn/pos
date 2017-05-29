//
//  OrderPriceCell.swift
//  pos
//
//  Created by luan on 2017/5/21.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class OrderPriceCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var priceRight: NSLayoutConstraint!
    var removeDiscount: ConfirmBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    deinit {
        removeDiscount = nil
    }

    @IBAction func cancelClick(_ sender: UIButton) {
        if removeDiscount != nil {
            removeDiscount!(sender)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
