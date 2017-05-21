//
//  MenuCell.swift
//  pos
//
//  Created by luan on 2017/5/20.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {
    
    @IBOutlet weak var menuBtn: UIButton!
    var confirmMenu: ConfirmBlock?
    
    deinit {
        confirmMenu = nil
    }
    
    @IBAction func menuClick(_ sender: UIButton) {
        if confirmMenu != nil {
            confirmMenu!(sender)
        }
    }
    
}
