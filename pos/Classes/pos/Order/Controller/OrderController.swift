//
//  OrderController.swift
//  pos
//
//  Created by luan on 2017/5/21.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class OrderController: AntController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,OrderFoodLayout_Delegate {

    @IBOutlet weak var menuCollection: UICollectionView!//菜单分类
    @IBOutlet weak var foodCollection: UICollectionView!//菜单信息
    @IBOutlet weak var foodLayout: OrderFoodLayout!
    @IBOutlet weak var orderNum: UILabel!//订单
    @IBOutlet weak var searchView: UISearchBar!//搜索
    @IBOutlet weak var alreadyTableView: UITableView!//已点信息
    @IBOutlet weak var billTableView: UITableView!//账单信息
    @IBOutlet weak var billTableHeight: NSLayoutConstraint!
    @IBOutlet weak var billHeaderView: UIView!//账单表头
    @IBOutlet weak var discountView: UIView!//折扣信息
    @IBOutlet weak var addDiscountBtn: UIButton!//添加折扣按钮
    @IBOutlet weak var fixDiscount: UITextField!//固定折扣
    @IBOutlet weak var percDiscount: UITextField!//百分比折扣
    @IBOutlet weak var promoCode: UITextField!//优惠码
    @IBOutlet weak var functionView: UIView!
    let functionBtnColorArray: [UInt32] = [0x5BC0DE,0xD9534F,0xF0AD4E,0x5BC0DE,0x5BC0DE,0xF0AD4E,0x5BC0DE,0x337AB7,0x5CB85C,0x5BC0DE]
    
    var tableNo = 0//餐桌号
    var tableType = ""//餐桌类别
    var orderModel: OrderModel?//订单信息
    var orderItemArray = [OrderItemModel]()//已点数组
    var categoryArray = [CategoryModel]()//菜单
    var selectMenu = CategoryModel()//当前选择的菜单类别
    var cousinesDic = [Int : [CousineModel]]()//菜单字典：key为菜单类别，value为菜单类别对应的菜
    var selectFoodArray = [OrderItemModel]()//选择的餐数组
    
    override func viewDidLoad() {
        super.viewDidLoad()

        billHeaderView.height = 40
        discountView.isHidden = true
        alreadyTableView.separatorInset = UIEdgeInsets.zero
        alreadyTableView.layoutMargins = UIEdgeInsets.zero
        alreadyTableView.estimatedRowHeight = 55
        alreadyTableView.rowHeight = UITableViewAutomaticDimension
        billTableView.separatorInset = UIEdgeInsets.zero
        billTableView.layoutMargins = UIEdgeInsets.zero
        foodLayout.delegate = self
        getOrderInfo()
        getAllCousineCategories()
    }
    
    @IBAction func homeClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutClick() {
        AntManage.userModel = nil
        AntManage.isLogin = false
        UserDefaults.standard.removeObject(forKey: kUserName)
        UserDefaults.standard.removeObject(forKey: kPassWord)
        UserDefaults.standard.synchronize()
        navigationController?.popViewController(animated: true)
    }

    @IBAction func checkSelectClick(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            selectFoodArray.removeAll()
            selectFoodArray += orderItemArray
            break
        case 1:
            selectFoodArray.removeAll()
            for model in orderItemArray {
                if model.is_print == "N" {
                    selectFoodArray.append(model)
                }
            }
            break
        case 2:
            selectFoodArray.removeAll()
            for model in orderItemArray {
                if model.is_print == "Y" {
                    selectFoodArray.append(model)
                }
            }
            break
        case 3:
            var array = [OrderItemModel]()
            for model in orderItemArray {
                if !selectFoodArray.contains(model) {
                    array.append(model)
                }
            }
            selectFoodArray.removeAll()
            selectFoodArray += array
            break
        case 4:
            selectFoodArray.removeAll()
            break
        default: break
            
        }
        alreadyTableView.reloadData()
        checkFunctionButtonStatus()
    }
    
    // MARK: 添加折扣
    @IBAction func addDiscountClick(_ sender: UIButton) {
        if orderModel != nil {
            
        } else {
            
        }
    }
    
    // MARK: 折扣应用
    @IBAction func discountAppleClick(_ sender: UIButton) {
        
    }
    
    @IBAction func functionClick(_ sender: UIButton) {
        if selectFoodArray.count == 0 {
            if !(sender.tag == 70 || sender.tag == 80 || sender.tag == 90) {
                AntManage.showDelayToast(message: NSLocalizedString("没有选择菜", comment: ""))
                return
            }
        }
        switch sender.tag {
        case 10:
            break
        case 20:
            removeItem()
            break
        case 30:
            updateNumber()
            break
        case 40:
            takeout()
            break
        case 50:
            urgeItem()
            break
        case 60:
            updatePrice()
            break
        case 70:
            addPhone()
            break
        case 80:
            tokitchen()
            break
        case 90:
            break
        case 100:
            break
        default:
            break
        }
    }
    
    // MARK: 更改功能按钮的状态
    func checkFunctionButtonStatus() {
        var isKitchenCount = 0
        for model in selectFoodArray {
            if model.is_print == "Y" {
                isKitchenCount += 1
            }
        }
        let tagArray: [Int]!
        if isKitchenCount > 0 {
            AntManage.showDelayToast(message: NSLocalizedString("已选项中包含已送厨菜品，若要修改已送厨菜品，请删除后重新添加。", comment: ""))
            if isKitchenCount == selectFoodArray.count {
                tagArray = [2,5,6]
            } else {
                tagArray = [2,6]
            }
        } else {
            tagArray = [1,2,3,4,6,7,8,9,10]
        }
        for tag in 1...10 {
            let button: UIButton = functionView.viewWithTag(tag * 10) as! UIButton
            if tagArray.contains(tag) {
                button.isEnabled = true
                button.backgroundColor = UIColor.init(rgb: functionBtnColorArray[tag - 1])
            } else {
                button.isEnabled = false
                button.backgroundColor = UIColor.init(rgb: 0xC0C3C3)
            }
        }
    }
    
    // MARK: 获取订单信息
    func getOrderInfo() {
        weak var weakSelf = self
        AntManage.postRequest(path: "tables/getOrderInfoByTable", params: ["table":tableNo, "type":tableType, "access_token":AntManage.userModel!.token], successResult: { (response) in
            weakSelf?.orderModel = OrderModel.mj_object(withKeyValues: response["Order"])
            weakSelf?.orderItemArray = OrderItemModel.mj_objectArray(withKeyValuesArray: response["OrderItem"]) as! [OrderItemModel]
            var orderNumStr = NSLocalizedString("订单号", comment: "") + weakSelf!.orderModel!.order_no + "," + NSLocalizedString("桌号", comment: "") + "\(weakSelf!.tableNo)"
            if !(weakSelf?.orderModel?.phone.isEmpty)! {
                orderNumStr += "," + NSLocalizedString("电话", comment: "") + ":\(weakSelf!.orderModel!.phone)"
            }
            weakSelf?.orderNum.text = orderNumStr
            if weakSelf?.orderModel?.discount_value == 0 {
                weakSelf?.addDiscountBtn.isHidden = false
                weakSelf?.billTableHeight.constant = 172.0
            } else {
                weakSelf?.addDiscountBtn.isHidden = true
                weakSelf?.billTableHeight.constant = 216.0
            }
            weakSelf?.selectFoodArray.removeAll()
            weakSelf?.alreadyTableView.reloadData()
            weakSelf?.billTableView.reloadData()
            weakSelf?.checkFunctionButtonStatus()
        }, failureResult: {
            weakSelf?.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: 获取菜单类别信息
    func getAllCousineCategories() {
        weak var weakSelf = self
        AntManage.postRequest(path: "tables/getAllCousineCategories", params: ["status":"", "access_token":AntManage.userModel!.token], successResult: { (response) in
            for dic in response["data"] as! Array<NSDictionary> {
                let model = CategoryModel.mj_object(withKeyValues: dic["Category"])
                if model?.status == "A" {
                    weakSelf?.categoryArray.append(model!)
                }
            }
            weakSelf?.selectMenu = weakSelf!.categoryArray.first!
            weakSelf?.menuCollection.reloadData()
            weakSelf?.getCousinesByCategoryId()
        }, failureResult: {})
    }
    
    // MARK: 获取子菜单信息
    func getCousinesByCategoryId() {
        if cousinesDic.keys.contains(selectMenu.categoryId) {
            foodCollection.reloadData()
        } else {
            weak var weakSelf = self
            AntManage.postRequest(path: "tables/getCousinesByCategoryId", params: ["category_id":selectMenu.categoryId, "access_token":AntManage.userModel!.token], successResult: { (response) in
                var array = [CousineModel]()
                for dic in response["data"] as! Array<NSDictionary> {
                    let model = CousineModel.mj_object(withKeyValues: dic["Cousine"])
                    if model?.status == "A" {
                        array.append(model!)
                    }
                }
                weakSelf?.cousinesDic[weakSelf!.selectMenu.categoryId] = array
                weakSelf?.foodCollection.reloadData()
            }, failureResult: {})
        }
    }
    
    // MARK: 删除已点菜
    func removeItem() {
        var kitchenItemIdList = ""
        var itemIdList = ""
        for item in selectFoodArray {
            if item.is_print == "Y" {
                kitchenItemIdList += "\(item.item_id),"
            } else {
                itemIdList += "\(item.item_id),"
            }
        }
        weak var weakSelf = self
        if !kitchenItemIdList.isEmpty {
            kitchenItemIdList.remove(at: kitchenItemIdList.index(before: kitchenItemIdList.endIndex))
            AntManage.postRequest(path: "print/printKitchenRemoveItem", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_id":orderModel!.orderId, "item_id_list":kitchenItemIdList, "access_token":AntManage.userModel!.token], successResult: { (_) in
                weakSelf?.getOrderInfo()
            }, failureResult: {})
        }
        if !itemIdList.isEmpty {
            itemIdList.remove(at: itemIdList.index(before: itemIdList.endIndex))
            AntManage.postRequest(path: "orderHandler/removeItem", params: ["cashier_id":AntManage.userModel!.cashier_id, "order_no":orderModel!.order_no, "item_id_list":itemIdList, "access_token":AntManage.userModel!.token], successResult: { (_) in
                weakSelf?.getOrderInfo()
            }, failureResult: {})
        }
    }
    
    // MARK: 改数量
    func updateNumber() {
        weak var weakSelf = self
        let alert = UIAlertController(title: NSLocalizedString("改数量", comment: ""), message: NSLocalizedString("新数量", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("保存", comment: ""), style: .default, handler: { (_) in
            let textField = alert.textFields?.first!
            var itemIdList = ""
            for item in weakSelf!.selectFoodArray {
                itemIdList += "\(item.item_id),"
            }
            itemIdList.remove(at: itemIdList.index(before: itemIdList.endIndex))
            AntManage.postRequest(path: "orderHandler/changeQuantity", params: ["item_id_list":itemIdList, "type":weakSelf!.orderModel!.order_type, "table":weakSelf!.orderModel!.table_no, "order_no":weakSelf!.orderModel!.order_no, "quantity":textField!.text!, "access_token":AntManage.userModel!.token], successResult: { (_) in
                weakSelf?.getOrderInfo()
            }, failureResult: {})
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: 外卖
    func takeout() {
        weak var weakSelf = self
        var itemIdList = ""
        for item in selectFoodArray {
            itemIdList += "\(item.item_id),"
        }
        itemIdList.remove(at: itemIdList.index(before: itemIdList.endIndex))
        AntManage.postRequest(path: "print/printKitchenUrgeItem", params: ["item_id_list":itemIdList, "type":weakSelf!.orderModel!.order_type, "table":weakSelf!.orderModel!.table_no, "access_token":AntManage.userModel!.token], successResult: { (_) in
            weakSelf?.getOrderInfo()
        }, failureResult: {})
    }
    
    // MARK: 催菜
    func urgeItem() {
        var kitchenItemIdList = ""
        for item in selectFoodArray {
            kitchenItemIdList += "\(item.item_id),"
        }
        kitchenItemIdList.remove(at: kitchenItemIdList.index(before: kitchenItemIdList.endIndex))
        AntManage.postRequest(path: "print/printKitchenUrgeItem", params: ["item_id_list":kitchenItemIdList, "order_id":orderModel!.orderId, "restaurant_id":AntManage.userModel!.restaurant_id, "access_token":AntManage.userModel!.token], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("厨房已收到您的催菜提醒", comment: ""))
        }, failureResult: {})
    }
    
    // MARK: 改价格
    func updatePrice() {
        weak var weakSelf = self
        let alert = UIAlertController(title: NSLocalizedString("改价格", comment: ""), message: NSLocalizedString("新价格", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "eg. 0.00"
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("保存", comment: ""), style: .default, handler: { (_) in
            let textField = alert.textFields?.first!
            var itemIdList = ""
            for item in weakSelf!.selectFoodArray {
                itemIdList += "\(item.item_id),"
            }
            itemIdList.remove(at: itemIdList.index(before: itemIdList.endIndex))
            AntManage.postRequest(path: "orderHandler/changePrice", params: ["item_id_list":itemIdList, "type":weakSelf!.orderModel!.order_type, "table":weakSelf!.orderModel!.table_no, "order_no":weakSelf!.orderModel!.order_no, "price":textField!.text!, "access_token":AntManage.userModel!.token], successResult: { (_) in
                weakSelf?.getOrderInfo()
            }, failureResult: {})
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: 加号码
    func addPhone() {
        weak var weakSelf = self
        let alert = UIAlertController(title: NSLocalizedString("加号码", comment: ""), message: NSLocalizedString("号码", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("保存", comment: ""), style: .default, handler: { (_) in
            let textField = alert.textFields?.first!
            AntManage.postRequest(path: "orderHandler/editphone", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_no":weakSelf!.orderModel!.order_no, "phone":textField!.text!, "access_token":AntManage.userModel!.token], successResult: { (_) in
                weakSelf?.getOrderInfo()
            }, failureResult: {})
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: 送厨
    func tokitchen() {
        weak var weakSelf = self
        AntManage.postRequest(path: "print/printTokitchen", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_id":orderModel!.orderId, "access_token":AntManage.userModel!.token], successResult: { (_) in
            weakSelf?.getOrderInfo()
        }, failureResult: {})
    }
    
    // MARK: UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == alreadyTableView {
            return orderItemArray.count
        } else {
            if orderModel != nil {
                if orderModel!.discount_value == 0 {
                    return 4
                } else {
                    return 3
                }
            } else {
                return 3
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == alreadyTableView ? tableView.rowHeight : 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == alreadyTableView {
            let cell: OrderAlreadyFoodCell = tableView.dequeueReusableCell(withIdentifier: "OrderAlreadyFoodCell", for: indexPath) as! OrderAlreadyFoodCell
            let model = orderItemArray[indexPath.row]
            if selectFoodArray.contains(model) {
                cell.contentView.backgroundColor = UIColor.init(rgb: 0xe03636)
            } else {
                cell.contentView.backgroundColor = model.is_print == "Y" ? UIColor.init(rgb: 0xece7e7) : UIColor.white
            }
            cell.foodName.text = model.name_en
            cell.price.text = "$\(model.price)"
            cell.number.text = "x\(model.qty)"
            var zhName = ""
            if model.is_takeout == "Y" {
                zhName += "(\(NSLocalizedString("外卖", comment: "")))\(model.name_xh)"
            } else {
                zhName += model.name_xh
            }
            if model.selected_extras.count > 0 {
                zhName += "\n"
                for extras in model.selected_extras {
                    if extras == model.selected_extras.last {
                        zhName += extras.name
                    } else {
                        zhName += "\(extras.name),"
                    }
                }
            }
            cell.note.text = zhName
            return cell
        } else {
            let cell: OrderPriceCell = tableView.dequeueReusableCell(withIdentifier: "OrderPriceCell", for: indexPath) as! OrderPriceCell
            var isDiscount = false
            if orderModel != nil, orderModel!.discount_value != 0 {
                isDiscount = true
            }
            cell.cancelBtn.isHidden = true
            cell.priceRight.constant = 2.0
            if indexPath.row == 0 {
                cell.titleLabel.text = NSLocalizedString("小计", comment: "")
                if orderModel != nil {
                    cell.priceLabel.text = "$" + String(format: "%.2f", orderModel!.subtotal)
                } else {
                    cell.priceLabel.text = "$0.00"
                }
            } else if indexPath.row == 1 + (isDiscount ? 1 : 0) {
                if orderModel != nil {
                    cell.titleLabel.text = NSLocalizedString("税", comment: "") + "\(orderModel!.tax)%"
                    cell.priceLabel.text = "$" + String(format: "%.2f", orderModel!.tax_amount)
                } else {
                    cell.titleLabel.text = NSLocalizedString("税", comment: "") + "0%"
                    cell.priceLabel.text = "$0.00"
                }
            } else if indexPath.row == 2 + (isDiscount ? 1 : 0) {
                cell.titleLabel.text = NSLocalizedString("合计", comment: "")
                if orderModel != nil {
                    cell.priceLabel.text = "$" + String(format: "%.2f", orderModel!.total)
                } else {
                    cell.priceLabel.text = "$0.00"
                }
            } else {
                cell.titleLabel.text = NSLocalizedString("折扣", comment: "")
                if orderModel!.fix_discount != 0 {
                    cell.priceLabel.text = "$" + String(format: "%.2f", orderModel!.discount_value)
                } else if orderModel!.percent_discount != 0 {
                    cell.priceLabel.text = "$" + String(format: "%.2f", orderModel!.discount_value) + "(\(orderModel!.percent_discount)%)"
                } else {
                    cell.priceLabel.text = "$" + String(format: "%.2f", orderModel!.discount_value) + "(\(orderModel!.promocode))"
                }
                cell.cancelBtn.isHidden = false
                cell.priceRight.constant = 40
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == alreadyTableView {
            let model = orderItemArray[indexPath.row]
            if selectFoodArray.contains(model) {
                selectFoodArray.remove(at: selectFoodArray.index(of: model)!)
            } else {
                selectFoodArray.append(model)
            }
            tableView.reloadRow(at: indexPath, with: .none)
            checkFunctionButtonStatus()
        }
    }
    
    // MARK: OrderFoodLayout_Delegate
    func collectionView(collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
        if cousinesDic.keys.contains(selectMenu.categoryId) {
            let model = cousinesDic[selectMenu.categoryId]![indexPath.row]
            return ("\(model.en)\n\(model.zh)" as NSString).width(for: UIFont.systemFont(ofSize: 14)) + 35 + ("$\(model.price)" as NSString).width(for: UIFont.systemFont(ofSize: 14))
        } else {
            return 0
        }
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = categoryArray[indexPath.row]
        let width = ("\(model.en)\n\(model.zh)" as NSString).width(for: UIFont.systemFont(ofSize: 16)) + 40
        return CGSize(width: width, height: 75)
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == menuCollection {
            return categoryArray.count
        } else {
            if cousinesDic.keys.contains(selectMenu.categoryId) {
                return (cousinesDic[selectMenu.categoryId]?.count)!
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == menuCollection {
            let cell: OrderMenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderMenuCell", for: indexPath) as! OrderMenuCell
            let model = categoryArray[indexPath.row]
            cell.menuLabel.text = "\(model.en)\n\(model.zh)"
            cell.menuLabel.textColor = (selectMenu == model ? UIColor.black : UIColor.white)
            cell.backgroundColor = (selectMenu == model ? UIColor.white : UIColor.init(rgb: 0xC30E22))
            return cell
        } else {
            let cell: OrderFoodCell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderFoodCell", for: indexPath) as! OrderFoodCell
            let model = cousinesDic[selectMenu.categoryId]![indexPath.row]
            cell.name.text = "\(model.en)\n\(model.zh)"
            cell.price.text = "$\(model.price)"
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == menuCollection {
            selectMenu = categoryArray[indexPath.row]
            collectionView.reloadData()
            getCousinesByCategoryId()
        } else {
            let model = cousinesDic[selectMenu.categoryId]![indexPath.row]
            weak var weakSelf = self
            AntManage.postRequest(path: "orderHandler/addItem", params: ["item_id":model.cousineId, "table":orderModel!.table_no, "type":orderModel!.order_type, "cashier_id":AntManage.userModel!.cashier_id, "access_token":AntManage.userModel!.token], successResult: { (response) in
                weakSelf?.getOrderInfo()
            }, failureResult: {})
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
