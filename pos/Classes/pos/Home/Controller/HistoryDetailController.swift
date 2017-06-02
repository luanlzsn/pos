//
//  HistoryDetailController.swift
//  pos
//
//  Created by luan on 2017/5/31.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class HistoryDetailController: AntController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var orderNum: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subTotal: UITextField!//小计
    @IBOutlet weak var taxLabel: UILabel!//税率
    @IBOutlet weak var taxMoney: UILabel!//税额
    @IBOutlet weak var discount: UITextField!//折扣
    @IBOutlet weak var total: UITextField!//总计
    @IBOutlet weak var receive: UITextField!//收到
    @IBOutlet weak var cash: UITextField!//现金
    @IBOutlet weak var card: UITextField!//卡
    @IBOutlet weak var change: UITextField!//找零
    @IBOutlet weak var tip: UITextField!//小费
    
    var tableNo = 0//餐桌号
    var tableType = ""//餐桌类别
    var historyModel: HistoryModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorInset = UIEdgeInsets.zero
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        let type: String!
        if tableType == "D" {
            type = NSLocalizedString("堂食", comment: "")
        } else if tableType == "T" {
            type = NSLocalizedString("外卖", comment: "")
        } else {
            type = NSLocalizedString("送餐", comment: "")
        }
        orderNum.text = NSLocalizedString("订单号", comment: "") + "#\(historyModel.orderInfo.order_no)," + NSLocalizedString("桌", comment: "") + "[[\(type!)]]#\(tableNo), @ \(historyModel.orderInfo.created)"
        subTotal.text = String(format: "%.2f", historyModel.orderInfo.subtotal)
        taxLabel.text = NSLocalizedString("税", comment:"") + "(\(historyModel.orderInfo.tax)%)"
        taxMoney.text = String(format: "%.2f", historyModel.orderInfo.tax_amount)
        discount.text = String(format: "%.2f", historyModel.orderInfo.discount_value)
        total.text = String(format: "%.2f", historyModel.orderInfo.total)
        receive.text = String(format: "%.2f", historyModel.orderInfo.paid)
        cash.text = String(format: "%.2f", historyModel.orderInfo.cash_val)
        card.text = String(format: "%.2f", historyModel.orderInfo.card_val)
        change.text = String(format: "%.2f", historyModel.orderInfo.change)
        tip.text = String(format: "%.2f", historyModel.orderInfo.tip)
    }
    
    @IBAction func homeClick() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: 弹回订单
    @IBAction func restoreOrderClick() {
        weak var weakSelf = self
        AntManage.postRequest(path: "orderHandler/tableRestore", params: ["order_id":historyModel.orderInfo.orderId, "access_token":AntManage.userModel!.token], successResult: { (_) in
            weakSelf?.homeClick()
        }, failureResult: {})
    }
    
    // MARK: 修改订单
    @IBAction func updateOrderClick() {
        UIApplication.shared.keyWindow?.endEditing(true)
        weak var weakSelf = self
        AntManage.postRequest(path: "orderHandler/tableHisupdate", params: ["order_id":historyModel.orderInfo.orderId, "subtotal":subTotal.text!, "discount_value":discount.text!, "total":total.text!, "paid":receive.text!, "cash_val":cash.text!, "card_val":card.text!, "change":change.text!, "tip":tip.text!, "access_token":AntManage.userModel!.token], successResult: { (_) in
            weakSelf?.navigationController?.popViewController(animated: true)
        }, failureResult: {})
    }
    
    // MARK: UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyModel.orderItemArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PaymentOrderCell = tableView.dequeueReusableCell(withIdentifier: "PaymentOrderCell", for: indexPath) as! PaymentOrderCell
        let model = historyModel.orderItemArray[indexPath.row]
        cell.nameLabel.text = model.name_en + "\n" + model.name_xh
        var extrasStr = ""
        if model.selected_extras.count > 0 {
            for extras in model.selected_extras {
                if extras == model.selected_extras.last {
                    extrasStr += extras.name
                } else {
                    extrasStr += "\(extras.name),"
                }
            }
        }
        cell.extrasLabel.text = extrasStr
        if model.qty > 1 {
            cell.priceLabel.text = "$\(model.price)x\(model.qty)"
        } else {
            cell.priceLabel.text = "$\(model.price)"
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
