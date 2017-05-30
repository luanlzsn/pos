//
//  PaymentOrderCell.swift
//  pos
//
//  Created by luan on 2017/5/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class PaymentOrderCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var extrasLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
