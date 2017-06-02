//
//  MergeBillController.swift
//  pos
//
//  Created by luan on 2017/5/30.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class MergeBillController: AntController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var orderNum: UILabel!//订单号
    @IBOutlet weak var orderTableView: UITableView!//点单信息
    @IBOutlet weak var billTableView: UITableView!//账单信息
    @IBOutlet weak var inputLabel: UILabel!//输入
    @IBOutlet weak var subTotal: UILabel!//小计
    @IBOutlet weak var discountView: UIView!//折扣信息
    @IBOutlet weak var discount: UILabel!//折扣
    @IBOutlet weak var afterDiscount: UILabel!//折后价
    @IBOutlet weak var taxLabel: UILabel!//税率
    @IBOutlet weak var taxTop: NSLayoutConstraint!
    @IBOutlet weak var taxMoney: UILabel!//税额
    @IBOutlet weak var total: UILabel!//总计
    @IBOutlet weak var receive: UILabel!//收到
    @IBOutlet weak var cashMoney: UILabel!//现金
    @IBOutlet weak var cardMoney: UILabel!//卡
    @IBOutlet weak var remainingTitle: UILabel!//剩余、找零
    @IBOutlet weak var remaining: UILabel!//剩余、找零
    @IBOutlet weak var tipMoney: UILabel!//小费
    @IBOutlet weak var cardBtn: UIButton!//卡按钮
    @IBOutlet weak var cashBtn: UIButton!//现金按钮
    @IBOutlet weak var calculatorCollection: UICollectionView!
    
    var tableNoArray = [Int]()
    var modelDic = [Int : OrderModel]()//订单信息
    var orderItemDic = [Int : [OrderItemModel]]()//已点数组
    let calculatorArray = ["1","2","3","4","5","6","7","8","9","0",".","Back",NSLocalizedString("默认", comment: ""),NSLocalizedString("清空", comment: ""),NSLocalizedString("输入", comment: "")]

    override func viewDidLoad() {
        super.viewDidLoad()

        orderTableView.separatorInset = UIEdgeInsets.zero
        orderTableView.layoutMargins = UIEdgeInsets.zero
        orderTableView.rowHeight = UITableViewAutomaticDimension
        orderTableView.estimatedRowHeight = 60
        
        billTableView.rowHeight = UITableViewAutomaticDimension
        billTableView.estimatedRowHeight = 60
        
        for tableNo in tableNoArray {
            getOrderInfo(tableNo: tableNo)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatorCollection.reloadData()
        billTableView.reloadData()
    }
    
    @IBAction func homeClick() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: 获取订单信息
    func getOrderInfo(tableNo: Int) {
        weak var weakSelf = self
        AntManage.postRequest(path: "tables/getOrderInfoByTable", params: ["table":tableNo, "type":"D", "access_token":AntManage.userModel!.token], successResult: { (response) in
            weakSelf?.modelDic[tableNo] = OrderModel.mj_object(withKeyValues: response["Order"])
            weakSelf?.orderItemDic[tableNo] = OrderItemModel.mj_objectArray(withKeyValuesArray: response["OrderItem"]) as? [OrderItemModel]
            weakSelf?.refreshOrderInfo()
        }, failureResult: {
            weakSelf?.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: 应用折扣
    func discountApple(orderModel: OrderModel) {
        UIApplication.shared.keyWindow?.endEditing(true)
        let discount = orderModel.inputDiscount
        let type = orderModel.inputDiscountType
        if !discount.isEmpty {
            weak var weakSelf = self
            AntManage.postRequest(path: "discountHandler/addDiscount", params: ["order_no":orderModel.order_no, "access_token":AntManage.userModel!.token, "discountType":type, "discountValue":discount, "cashier_id":AntManage.userModel!.cashier_id], successResult: { (_) in
                weakSelf?.getOrderInfo(tableNo: orderModel.table_no)
            }, failureResult: {})
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("请输入折扣。", comment: ""))
        }
    }
    
    // MARK: 删除折扣
    func removeDiscount(orderModel: OrderModel) {
        weak var weakSelf = self
        AntManage.postRequest(path: "discountHandler/removeDiscount", params: ["order_no":orderModel.order_no, "access_token":AntManage.userModel!.token], successResult: { (_) in
            weakSelf?.getOrderInfo(tableNo: orderModel.table_no)
        }, failureResult: {})
    }

    // MARK: 打印收据
    @IBAction func printPayBillClick() {
        var order_ids = [Int]()
        for model in modelDic.values {
            order_ids.append(model.orderId)
        }
        AntManage.postRequest(path: "print/printMergeBill", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_ids":order_ids, "access_token":AntManage.userModel!.token], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("打印收据成功。", comment: ""))
        }, failureResult: {})
    }
    
    // MARK: 选择卡支付
    @IBAction func cardClick() {
        cardBtn.isSelected = true
        cashBtn.isSelected = false
        cardBtn.backgroundColor = UIColor.init(rgb: 0xC30E22)
        cashBtn.backgroundColor = UIColor.init(rgb: 0xF4D6D5)
        inputLabel.text = ""
    }
    
    // MARK: 选择现金支付
    @IBAction func cashClick() {
        cardBtn.isSelected = false
        cashBtn.isSelected = true
        cardBtn.backgroundColor = UIColor.init(rgb: 0xF4D6D5)
        cashBtn.backgroundColor = UIColor.init(rgb: 0xC30E22)
        inputLabel.text = ""
    }
    
    // MARK: 确认支付
    @IBAction func confirmClick() {
        if !cardBtn.isSelected, !cashBtn.isSelected {
            AntManage.showDelayToast(message: NSLocalizedString("请选择卡或现金付款方式。", comment: ""))
            return
        }
        if remainingTitle.text == NSLocalizedString("找零", comment: "") {
            var order_ids = [Int]()
            var table_merge = ""
            
            for model in modelDic.values {
                order_ids.append(model.orderId)
                table_merge += "\(model.table_no),"
            }
            table_merge.remove(at: table_merge.index(before: table_merge.endIndex))
            let main_order_id = modelDic[tableNoArray.first!]!.orderId
            var params: [String : Any] = ["order_ids":order_ids, "table":tableNoArray.first!, "cashier_id":AntManage.userModel!.cashier_id, "restaurant_id":AntManage.userModel!.restaurant_id, "access_token":AntManage.userModel!.token, "main_order_id":main_order_id, "table_merge":table_merge]
            params["paid_by"] = cardBtn.isSelected ? "card" : "cash"
            params["pay"] = receive.text!.components(separatedBy: "$").last!
            if remaining.text!.components(separatedBy: "$").last! == "0.00" {
                params["change"] = ""
            } else {
                params["change"] = remaining.text!.components(separatedBy: "$").last!
            }
            params["card_val"] = cardMoney.text!.components(separatedBy: "$").last!
            params["cash_val"] = cashMoney.text!.components(separatedBy: "$").last!
            if tipMoney.text!.components(separatedBy: "$").last! == "0.00" {
                params["tip_paid_by"] = ""
                params["tip_val"] = ""
            } else {
                params["tip_paid_by"] = "CARD"
                params["tip_val"] = tipMoney.text!.components(separatedBy: "$").last!
            }
            weak var weakSelf = self
            AntManage.postRequest(path: "payHandler/completeMergeOrder", params: params, successResult: { (_) in
                weakSelf?.printMergeReceipt(orderIds: order_ids)
            }, failureResult: {})
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("金额无效，请检查再次验证。", comment: ""))
        }
    }
    
    func printMergeReceipt(orderIds: [Int]) {
        weak var weakSelf = self
        AntManage.postRequest(path: "payHandler/completeMergeOrder", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_ids":orderIds, "access_token":AntManage.userModel!.token], successResult: { (_) in
            weakSelf?.homeClick()
        }, failureResult: {})
    }
    
    func refreshOrderInfo() {
        var orderNo = ""//订单号
        var tableNo = ""//餐桌号
        var subtotal = 0.0
        var tax = 0
        var tax_amount = 0.0
        var totalFloat = 0.0
        var remainingFloat = 0.0
        var discount_value = 0.0
        var after_discount = 0.0
        
        for tableNumber in tableNoArray {
            if let orderModel = modelDic[tableNumber] {
                orderNo += orderModel.order_no + " "
                subtotal += orderModel.subtotal
                tax = orderModel.tax
                tax_amount += orderModel.tax_amount
                totalFloat += orderModel.total
                remainingFloat += orderModel.total
                discount_value += orderModel.discount_value
                after_discount += orderModel.after_discount
            }
            if tableNumber == tableNoArray.first {
                tableNo += "#\(tableNumber) " + NSLocalizedString("和", comment: "")
            } else {
                tableNo += "#\(tableNumber) "
            }
        }
        orderNo.remove(at: orderNo.index(before: orderNo.endIndex))
        let orderNumStr = NSLocalizedString("订单号", comment: "") + " \(orderNo)," + NSLocalizedString("桌", comment: "") + "[[\(NSLocalizedString("堂食", comment: ""))]]\(tableNo)" + NSLocalizedString("合并", comment: "")
        orderNum.text = orderNumStr
        
        subTotal.text = "$" + String(format: "%.2f", subtotal)
        taxLabel.text = NSLocalizedString("税", comment: "") + "(\(tax)%)"
        taxMoney.text = "$" + String(format: "%.2f", tax_amount)
        total.text = "$" + String(format: "%.2f", totalFloat)
        remaining.text = "$" + String(format: "%.2f", remainingFloat)
        if discount_value > 0 {
            taxTop.constant = 61
            discountView.isHidden = false
            discount.text = "$" + String(format: "%.2f", discount_value)
            afterDiscount.text = "$" + String(format: "%.2f", after_discount)
        } else {
            taxTop.constant = 0
            discountView.isHidden = true
        }
        
        orderTableView.reloadData()
        billTableView.reloadData()
    }
    
    // MARK: 处理收到的金额
    func checkReceiveMoney() {
        let card = (cardMoney.text!.components(separatedBy: "$").last! as NSString).doubleValue
        let cash = (cashMoney.text!.components(separatedBy: "$").last! as NSString).doubleValue
        receive.text = "$" + String(format: "%.2f", card + cash)
        let totalDouble = (total.text!.substring(from: total.text!.index(after: total.text!.startIndex)) as NSString).doubleValue
        let tip = (String(format: "%.2f", card - totalDouble) as NSString).floatValue
        if tip >= 0 {
            tipMoney.text = "$" + String(format: "%.2f", fabs(card - totalDouble))
            remainingTitle.text = NSLocalizedString("找零", comment: "")
            remaining.text = "$" + String(format: "%.2f", cash)
        } else {
            tipMoney.text = "$0.00"
            let remainingF = (String(format: "%.2f", card + cash - totalDouble) as NSString).floatValue
            if remainingF >= 0 {
                remainingTitle.text = NSLocalizedString("找零", comment: "")
                remaining.text = "$" + String(format: "%.2f", fabs(card + cash - totalDouble))
            } else {
                remainingTitle.text = NSLocalizedString("剩余", comment: "")
                remaining.text = "$" + String(format: "%.2f", totalDouble - (card + cash))
            }
        }
    }
    
    // MARK: UITableViewDelegate,UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableNoArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == orderTableView {
            if orderItemDic.keys.contains(tableNoArray[section]) {
                return orderItemDic[tableNoArray[section]]!.count
            } else {
                return 0
            }
        } else {
            if modelDic.keys.contains(tableNoArray[section]) {
                return 1
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == orderTableView {
            return 30
        } else {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == orderTableView {
            return 0.01
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == orderTableView {
            return tableView.rowHeight
        } else {
            let model = modelDic[tableNoArray[indexPath.section]]!
            if model.discount_value > 0.0 {
                return 210
            } else {
                if model.isAddDiscount {
                    return 250
                } else {
                    return 160
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == orderTableView {
            return "#\(tableNoArray[section]) BILL"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == orderTableView {
            let cell: PaymentOrderCell = tableView.dequeueReusableCell(withIdentifier: "PaymentOrderCell", for: indexPath) as! PaymentOrderCell
            let model = orderItemDic[tableNoArray[indexPath.section]]![indexPath.row]
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
        } else {
            let cell: MergeBillCell = tableView.dequeueReusableCell(withIdentifier: "MergeBillCell", for: indexPath) as! MergeBillCell
            let model = modelDic[tableNoArray[indexPath.section]]!
            cell.refreshOrderBill(model: model)
            weak var weakSelf = self
            cell.checkDiscount = { (type) in
                if (type as! Int) == 1 {
                    if model.discount_value > 0 {
                        weakSelf?.removeDiscount(orderModel: model)
                    } else {
                        model.isAddDiscount = !model.isAddDiscount
                        tableView.reloadData()
                    }
                } else {
                    weakSelf?.discountApple(orderModel: model)
                }
            }
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (collectionView.height - 4.0) / 5.0
        let width = (collectionView.width - 2.0) / 3.0
        return CGSize(width: width, height: height)
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calculatorArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CalculatorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalculatorCell", for: indexPath) as! CalculatorCell
        cell.calculatorTitle.text = calculatorArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cardBtn.isSelected || cashBtn.isSelected {
            if indexPath.row <= 9 {
                inputLabel.text! += calculatorArray[indexPath.row]
            } else if indexPath.row == 10 {
                if !inputLabel.text!.contains(calculatorArray[indexPath.row]) {
                    inputLabel.text! += calculatorArray[indexPath.row]
                }
            } else if indexPath.row == 11 {
                if !inputLabel.text!.isEmpty {
                    inputLabel.text!.remove(at: inputLabel.text!.index(before: inputLabel.text!.endIndex))
                }
            } else if indexPath.row == 12 {
                let totalDouble = (total.text!.substring(from: total.text!.index(after: total.text!.startIndex)) as NSString).doubleValue
                inputLabel.text = String(format: "%.2f", totalDouble)
            } else if indexPath.row == 13 {
                if cardBtn.isSelected {
                    cardMoney.text = NSLocalizedString("卡", comment: "") + ":$0.00"
                } else {
                    cashMoney.text = NSLocalizedString("现金", comment: "") + ":$0.00"
                }
                inputLabel.text = ""
                checkReceiveMoney()
            } else if indexPath.row == 14 {
                if cardBtn.isSelected {
                    cardMoney.text = NSLocalizedString("卡", comment: "") + String(format: ":$%.2f", (inputLabel.text! as NSString).floatValue)
                } else {
                    cashMoney.text = NSLocalizedString("现金", comment: "") + String(format: ":$%.2f", (inputLabel.text! as NSString).floatValue)
                }
                checkReceiveMoney()
            }
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("请选择支付方式 卡/现金。", comment: ""))
        }
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
