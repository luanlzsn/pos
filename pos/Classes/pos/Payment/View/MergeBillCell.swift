//
//  MergeBillCell.swift
//  pos
//
//  Created by luan on 2017/6/2.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class MergeBillCell: UITableViewCell,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orderNum: UILabel!
    @IBOutlet weak var discountBtn: UIButton!
    @IBOutlet weak var addDiscountView: UIView!
    @IBOutlet weak var fixDiscount: UITextField!
    @IBOutlet weak var percDiscount: UITextField!
    @IBOutlet weak var promoCode: UITextField!
    
    var orderModel = OrderModel()
    var checkDiscount: ConfirmBlock?//返回1为添加、删除折扣，返回2为应用折扣
    
    deinit {
        checkDiscount = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func discountChange(_ sender: UITextField) {
        if !(sender.text?.isEmpty)! {
            if sender == fixDiscount {
                percDiscount.isEnabled = false
                promoCode.isEnabled = false
                orderModel.inputDiscountType = "fix_discount"
            } else if sender == percDiscount {
                fixDiscount.isEnabled = false
                promoCode.isEnabled = false
                orderModel.inputDiscountType = "percent_discount"
            } else {
                fixDiscount.isEnabled = false
                percDiscount.isEnabled = false
                orderModel.inputDiscountType = "promocode"
            }
        } else {
            fixDiscount.isEnabled = true
            percDiscount.isEnabled = true
            promoCode.isEnabled = true
            orderModel.inputDiscountType = ""
        }
        orderModel.inputDiscount = sender.text!
    }
    
    @IBAction func discountClick(_ sender: UIButton) {
        if checkDiscount != nil {
            checkDiscount!(1)
        }
    }
    
    @IBAction func applyDiscount(_ sender: UIButton) {
        if checkDiscount != nil {
            checkDiscount!(2)
        }
    }
    
    func refreshOrderBill(model: OrderModel) {
        orderModel = model
        orderNum.text = NSLocalizedString("订单号", comment: "") + " \(orderModel.order_no)," + NSLocalizedString("桌号", comment: "") + " \(orderModel.table_no)," + NSLocalizedString("类型", comment: "") + " D"
        if orderModel.discount_value > 0 {
            addDiscountView.isHidden = true
            discountBtn.setTitle(NSLocalizedString("删除折扣", comment: ""), for: .normal)
            discountBtn.backgroundColor = UIColor.init(rgb: 0xD9534F)
        } else {
            addDiscountView.isHidden = !orderModel.isAddDiscount
            discountBtn.setTitle(NSLocalizedString("加入折扣", comment: ""), for: .normal)
            discountBtn.backgroundColor = UIColor.init(rgb: 0x57AD12)
        }
        if orderModel.inputDiscountType == "fix_discount" {
            fixDiscount.isEnabled = true
            percDiscount.isEnabled = false
            promoCode.isEnabled = false
            fixDiscount.text = orderModel.inputDiscount
            percDiscount.text = ""
            promoCode.text = ""
        } else if orderModel.inputDiscountType == "percent_discount" {
            fixDiscount.isEnabled = false
            percDiscount.isEnabled = true
            promoCode.isEnabled = false
            fixDiscount.text = ""
            percDiscount.text = orderModel.inputDiscount
            promoCode.text = ""
        } else if orderModel.inputDiscountType == "promocode" {
            fixDiscount.isEnabled = false
            percDiscount.isEnabled = false
            promoCode.isEnabled = true
            fixDiscount.text = ""
            percDiscount.text = ""
            promoCode.text = orderModel.inputDiscount
        } else {
            fixDiscount.isEnabled = true
            percDiscount.isEnabled = true
            promoCode.isEnabled = true
            fixDiscount.text = ""
            percDiscount.text = ""
            promoCode.text = ""
        }
        tableView.reloadData()
    }
    
    // MARK: UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orderModel.discount_value > 0 {
            return 5
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MergeBillDetailCell = tableView.dequeueReusableCell(withIdentifier: "MergeBillDetailCell", for: indexPath) as! MergeBillDetailCell
        let tag: Int
        if orderModel.discount_value > 0 {
            tag = 2
        } else {
            tag = 0
        }
        if indexPath.row == 0 {
            cell.titleLabel.text = NSLocalizedString("小计", comment: "")
            cell.moneyLabel.text = "$ " + String(format: "%.2f", orderModel.subtotal)
        } else if indexPath.row == 1 + tag {
            cell.titleLabel.text = NSLocalizedString("税", comment: "") + "(\(orderModel.tax)%)"
            cell.moneyLabel.text = "$ " + String(format: "%.2f", orderModel.tax_amount)
        } else if indexPath.row == 2 + tag {
            cell.titleLabel.text = NSLocalizedString("总计", comment: "")
            cell.moneyLabel.text = "$ " + String(format: "%.2f", orderModel.total)
        } else if indexPath.row == 1 {
            cell.titleLabel.text = NSLocalizedString("折扣", comment: "")
            cell.moneyLabel.text = "$ " + String(format: "%.2f", orderModel.discount_value)
        } else if indexPath.row == 2 {
            cell.titleLabel.text = NSLocalizedString("折后价", comment: "")
            cell.moneyLabel.text = "$ " + String(format: "%.2f", orderModel.after_discount)
        }
        return cell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
