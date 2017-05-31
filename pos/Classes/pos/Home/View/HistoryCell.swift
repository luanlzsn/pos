//
//  HistoryCell.swift
//  pos
//
//  Created by luan on 2017/5/31.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var orderTime: UILabel!//时间
    @IBOutlet weak var orderNum: UILabel!//订单号
    @IBOutlet weak var subTotal: UILabel!//小计
    @IBOutlet weak var taxMoney: UILabel!//税额
    @IBOutlet weak var total: UILabel!//总计
    
    var showOrderDetail: ConfirmBlock?
    
    deinit {
        showOrderDetail = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func orderDetailClick() {
        if showOrderDetail != nil {
            showOrderDetail!(0)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
