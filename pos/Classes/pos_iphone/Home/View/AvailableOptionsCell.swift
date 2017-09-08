//
//  AvailableOptionsCell.swift
//  pos
//
//  Created by luan on 2017/9/8.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class AvailableOptionsCell: UITableViewCell {

    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var optionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
