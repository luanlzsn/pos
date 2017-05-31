//
//  PaymentController.swift
//  pos
//
//  Created by luan on 2017/5/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class PaymentController: AntController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var orderNum: UILabel!
    @IBOutlet weak var paymentBtn: UIButton!//是否支付按钮
    @IBOutlet weak var orderTable: UITableView!
    @IBOutlet weak var addDiscountBtn: UIButton!//添加折扣按钮
    @IBOutlet weak var addDiscountView: UIView!//折扣信息
    @IBOutlet weak var fixDiscount: UITextField!//固定折扣
    @IBOutlet weak var percDiscount: UITextField!//百分比折扣
    @IBOutlet weak var promoCode: UITextField!//优惠码
    @IBOutlet weak var discountView: UIView!//折扣信息
    @IBOutlet weak var discountMoney: UILabel!//折扣金额
    @IBOutlet weak var afterDiscount: UILabel!//折后价
    @IBOutlet weak var calculatorCollection: UICollectionView!
    @IBOutlet weak var subtotal: UILabel!//小计
    @IBOutlet weak var taxTop: NSLayoutConstraint!//税top
    @IBOutlet weak var tax: UILabel!//税比较
    @IBOutlet weak var taxMoney: UILabel!//税金额
    @IBOutlet weak var total: UILabel!//总计
    @IBOutlet weak var receive: UILabel!//收到金额
    @IBOutlet weak var cashMoney: UILabel!//现金
    @IBOutlet weak var cardMoney: UILabel!//卡
    @IBOutlet weak var remainingTitle: UILabel!
    @IBOutlet weak var remaining: UILabel!//剩余
    @IBOutlet weak var tipMoney: UILabel!//小费
    @IBOutlet weak var cardBtn: UIButton!//卡按钮
    @IBOutlet weak var cashBtn: UIButton!//现金按钮
    @IBOutlet weak var inputLabel: UILabel!//输入的金额
    
    var tableNo = 0//餐桌号
    var tableType = ""//餐桌类别
    var orderModel: OrderModel?//订单信息
    var orderItemArray = [OrderItemModel]()//已点数组
    let calculatorArray = ["1","2","3","4","5","6","7","8","9","0",".","Back",NSLocalizedString("默认", comment: ""),NSLocalizedString("清空", comment: ""),NSLocalizedString("输入", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        orderTable.separatorInset = UIEdgeInsets.zero
        orderTable.layoutMargins = UIEdgeInsets.zero
        orderTable.rowHeight = UITableViewAutomaticDimension
        orderTable.estimatedRowHeight = 60
        getOrderInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatorCollection.reloadData()
    }

    @IBAction func homeClick() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func logoutClick() {
        AntManage.userModel = nil
        AntManage.isLogin = false
        UserDefaults.standard.removeObject(forKey: kUserName)
        UserDefaults.standard.removeObject(forKey: kPassWord)
        UserDefaults.standard.synchronize()
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: 打印收据
    @IBAction func printPayBillClick() {
        AntManage.postRequest(path: "print/printPayBill", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_id":orderModel!.orderId, "access_token":AntManage.userModel!.token], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("打印收据成功。", comment: ""))
        }, failureResult: {})
    }
    
    // MARK: 添加折扣
    @IBAction func addDiscountClick() {
        addDiscountBtn.isSelected = !addDiscountBtn.isSelected
        if addDiscountBtn.isSelected {
            addDiscountView.isHidden = false
            taxTop.constant = 50
        } else {
            addDiscountView.isHidden = true
            taxTop.constant = 0
        }
    }
    
    // MARK: 删除折扣
    @IBAction func removeDiscountClick() {
        weak var weakSelf = self
        AntManage.postRequest(path: "discountHandler/removeDiscount", params: ["order_no":orderModel!.order_no, "access_token":AntManage.userModel!.token], successResult: { (_) in
            weakSelf?.getOrderInfo()
        }, failureResult: {})
    }
    
    // MARK: 应用折扣
    @IBAction func discountAppleClick() {
        UIApplication.shared.keyWindow?.endEditing(true)
        var discount = ""
        var type = ""
        if !fixDiscount.text!.isEmpty {
            discount = fixDiscount.text!
            type = "fix_discount"
        } else if !percDiscount.text!.isEmpty {
            discount = percDiscount.text!
            type = "percent_discount"
        } else if !promoCode.text!.isEmpty {
            discount = promoCode.text!
            type = "promocode"
        }
        if !discount.isEmpty {
            weak var weakSelf = self
            AntManage.postRequest(path: "discountHandler/addDiscount", params: ["order_no":orderModel!.order_no, "access_token":AntManage.userModel!.token, "discountType":type, "discountValue":discount, "cashier_id":AntManage.userModel!.cashier_id], successResult: { (_) in
                weakSelf?.getOrderInfo()
            }, failureResult: {})
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("请输入折扣。", comment: ""))
        }
    }
    
    // MARK: 卡
    @IBAction func cardClick() {
        cardBtn.isSelected = true
        cashBtn.isSelected = false
        cardBtn.backgroundColor = UIColor.init(rgb: 0xC30E22)
        cashBtn.backgroundColor = UIColor.init(rgb: 0xF4D6D5)
        inputLabel.text = ""
    }
    
    // MARK: 现金
    @IBAction func cashClick() {
        cardBtn.isSelected = false
        cashBtn.isSelected = true
        cardBtn.backgroundColor = UIColor.init(rgb: 0xF4D6D5)
        cashBtn.backgroundColor = UIColor.init(rgb: 0xC30E22)
        inputLabel.text = ""
    }
    
    // MARK: 确认
    @IBAction func confirmClick() {
        if !cardBtn.isSelected, !cashBtn.isSelected {
            AntManage.showDelayToast(message: NSLocalizedString("请选择卡或现金付款方式。", comment: ""))
            return
        }
        if remainingTitle.text == NSLocalizedString("找零", comment: "") {
            var params: [String : Any] = ["order_id":orderModel!.orderId, "type":tableType, "table":tableNo, "cashier_id":AntManage.userModel!.cashier_id, "restaurant_id":AntManage.userModel!.restaurant_id, "access_token":AntManage.userModel!.token]
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
                params["tip"] = ""
            } else {
                params["tip_paid_by"] = "CARD"
                params["tip"] = tipMoney.text!.components(separatedBy: "$").last!
            }
            weak var weakSelf = self
            AntManage.postRequest(path: "payHandler/completeOrder", params: params, successResult: { (_) in
                AntManage.showDelayToast(message: NSLocalizedString("订单成功完成。", comment: ""))
                weakSelf?.homeClick()
            }, failureResult: {})
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("金额无效，请检查再次验证。", comment: ""))
        }
    }
    
    @IBAction func discountChange(_ sender: UITextField) {
        if !(sender.text?.isEmpty)! {
            if sender == fixDiscount {
                percDiscount.isEnabled = false
                promoCode.isEnabled = false
            } else if sender == percDiscount {
                fixDiscount.isEnabled = false
                promoCode.isEnabled = false
            } else {
                fixDiscount.isEnabled = false
                percDiscount.isEnabled = false
            }
        } else {
            fixDiscount.isEnabled = true
            percDiscount.isEnabled = true
            promoCode.isEnabled = true
        }
    }
    
    // MARK: 获取订单信息
    func getOrderInfo() {
        weak var weakSelf = self
        AntManage.postRequest(path: "tables/getOrderInfoByTable", params: ["table":tableNo, "type":tableType, "access_token":AntManage.userModel!.token], successResult: { (response) in
            weakSelf?.orderModel = OrderModel.mj_object(withKeyValues: response["Order"])
            weakSelf?.orderItemArray = OrderItemModel.mj_objectArray(withKeyValuesArray: response["OrderItem"]) as! [OrderItemModel]
            weakSelf?.refreshOrderInfo()
        }, failureResult: {
            weakSelf?.navigationController?.popViewController(animated: true)
        })
    }
    
    func refreshOrderInfo() {
        paymentBtn.isSelected = orderModel?.is_completed == "Y"
        let type: String!
        if tableType == "D" {
            type = NSLocalizedString("堂食", comment: "")
        } else if tableType == "T" {
            type = NSLocalizedString("外卖", comment: "")
        } else {
            type = NSLocalizedString("送餐", comment: "")
        }
        let orderNumStr = NSLocalizedString("订单号", comment: "") + orderModel!.order_no + "\n" + NSLocalizedString("桌", comment: "") + "[[\(type!)]]#\(tableNo)"
        orderNum.text = orderNumStr
        
        subtotal.text = "$" + String(format: "%.2f", orderModel!.subtotal)
        tax.text = NSLocalizedString("税", comment: "") + "(\(orderModel!.tax)%)"
        taxMoney.text = "$" + String(format: "%.2f", orderModel!.tax_amount)
        total.text = "$" + String(format: "%.2f", orderModel!.total)
        remaining.text = "$" + String(format: "%.2f", orderModel!.total)
        addDiscountView.isHidden = true
        if orderModel!.discount_value != 0 {
            addDiscountBtn.isHidden = true
            taxTop.constant = 61
            discountView.isHidden = false
            if orderModel!.fix_discount != 0 {
                discountMoney.text = "$" + String(format: "%.2f", orderModel!.discount_value)
            } else if orderModel!.percent_discount != 0 {
                discountMoney.text = "$" + String(format: "%.2f", orderModel!.discount_value) + "(\(orderModel!.percent_discount)%)"
            } else {
                discountMoney.text = "$" + String(format: "%.2f", orderModel!.discount_value) + "(\(orderModel!.promocode))"
            }
            afterDiscount.text = "$" + String(format: "%.2f", orderModel!.after_discount)
        } else {
            addDiscountBtn.isHidden = false
            taxTop.constant = 0
            discountView.isHidden = true
        }
        
        orderTable.reloadData()
    }
    
    // MARK: 处理收到的金额
    func checkReceiveMoney() {
        let card = (cardMoney.text!.components(separatedBy: "$").last! as NSString).doubleValue
        let cash = (cashMoney.text!.components(separatedBy: "$").last! as NSString).doubleValue
        receive.text = "$" + String(format: "%.2f", card + cash)
        let tip = (String(format: "%.2f", card - orderModel!.total) as NSString).floatValue
        if tip >= 0 {
            tipMoney.text = "$" + String(format: "%.2f", fabs(card - orderModel!.total))
            remainingTitle.text = NSLocalizedString("找零", comment: "")
            remaining.text = "$" + String(format: "%.2f", cash)
        } else {
            tipMoney.text = "$0.00"
            let remainingF = (String(format: "%.2f", card + cash - orderModel!.total) as NSString).floatValue
            if remainingF >= 0 {
                remainingTitle.text = NSLocalizedString("找零", comment: "")
                remaining.text = "$" + String(format: "%.2f", fabs(card + cash - orderModel!.total))
            } else {
                remainingTitle.text = NSLocalizedString("剩余", comment: "")
                remaining.text = "$" + String(format: "%.2f", orderModel!.total - (card + cash))
            }
        }
    }
    
    // MARK: 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChangeTable" {
            let change: ChangeTableController = segue.destination as! ChangeTableController
            weak var weakSelf = self
            change.changeTable = { (tableDic) in
                AntManage.postRequest(path: "orderHandler/moveOrder", params: ["type":(tableDic as! [String : Any])["TableType"]!, "table":(tableDic as! [String : Any])["TableNo"]!, "order_no":weakSelf!.orderModel!.order_no, "access_token":AntManage.userModel!.token], successResult: { (response) in
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeTableSuccsee"), object: nil)
                    weakSelf?.tableNo = (tableDic as! [String : Any])["TableNo"] as! Int
                    weakSelf?.tableType = (tableDic as! [String : Any])["TableType"] as! String
                    let type: String!
                    if weakSelf?.tableType == "D" {
                        type = NSLocalizedString("堂食", comment: "")
                    } else if weakSelf?.tableType == "T" {
                        type = NSLocalizedString("外卖", comment: "")
                    } else {
                        type = NSLocalizedString("送餐", comment: "")
                    }
                    let orderNumStr = NSLocalizedString("订单号", comment: "") + weakSelf!.orderModel!.order_no + "\n" + NSLocalizedString("桌", comment: "") + "[[\(type!)]]#\(weakSelf!.tableNo)"
                    weakSelf?.orderNum.text = orderNumStr
                }) {
                    AntManage.showDelayToast(message: NSLocalizedString("换桌失败，请重试！", comment: ""))
                }
            }
        }
    }
    
    // MARK: UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItemArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PaymentOrderCell = tableView.dequeueReusableCell(withIdentifier: "PaymentOrderCell", for: indexPath) as! PaymentOrderCell
        let model = orderItemArray[indexPath.row]
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
                inputLabel.text = String(format: "%.2f", orderModel!.total)
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
