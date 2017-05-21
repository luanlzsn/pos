//
//  ChangeTableCell.swift
//  pos
//
//  Created by luan on 2017/5/21.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ChangeTableCell: UICollectionViewCell {
    
    @IBOutlet weak var changeNumBtn: UIButton!
    var changeTable: ConfirmBlock?
    
    deinit {
        changeTable = nil
    }
    
    @IBAction func changeTableClick(_ sender: UIButton) {
        if changeTable != nil {
            changeTable!(sender)
        }
    }
    
}
