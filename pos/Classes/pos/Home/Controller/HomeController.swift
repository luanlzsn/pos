//
//  HomeController.swift
//  pos
//
//  Created by luan on 2017/5/7.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class HomeController: AntController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var takeoutCollection: UICollectionView!
    @IBOutlet weak var deliveryCollection: UICollectionView!
    var dineDic = [Int : OrderModel]()//堂食字典,key为餐桌号,value为餐桌信息
    var takeoutDic = [Int : OrderModel]()//外卖字典,key为餐桌号,value为餐桌信息
    var deliveryDic = [Int : OrderModel]()//送餐字典,key为餐桌号,value为餐桌信息
    var dineNum = 0//堂食餐桌数量
    var takeoutNum = 0//外卖餐桌数量
    var deliveryNum = 0//送餐餐桌数量
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(requestAddressUpdate), name: NSNotification.Name("RequestAddressUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(homeClick), name: NSNotification.Name(rawValue: "ChangeTableSuccsee"), object: nil)
        collection.register(UINib(nibName: "HomeCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCell")
        takeoutCollection.register(UINib(nibName: "HomeCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCell")
        deliveryCollection.register(UINib(nibName: "HomeCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !AntManage.isLogin {
            let login = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()!
            present(login, animated: true, completion: nil)
        } else {
            getTableNos()
            getTablesInfoWithType(type: "D")
            getTablesInfoWithType(type: "T")
            getTablesInfoWithType(type: "W")
        }
    }

    // MARK: 主页
    @IBAction func homeClick() {
        getTableNos()
        getTablesInfoWithType(type: "D")
        getTablesInfoWithType(type: "T")
        getTablesInfoWithType(type: "W")
    }
    
    // MARK: 语言
    @IBAction func languageClick(_ sender: SpinnerButton) {
        weak var weakSelf = self
        sender.show(view: view, array: ["English","中文"]) { (languageStr) in
            let language: String!
            if languageStr == "English" {
                language = "en"
            } else {
                language = "zh-Hans"
            }
            if language != LanguageManager.currentLanguageString() {
                LanguageManager.saveLanguage(languageString: language)
                weakSelf?.reloadRootViewController()
            }
        }
    }
    
    // MARK: 重载视图
    func reloadRootViewController() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        delegate.window?.rootViewController = storyboard.instantiateInitialViewController()
    }
    
    // MARK: 签入
    @IBAction func checkInClick() {
        let alert = UIAlertController(title: NSLocalizedString("签入", comment: ""), message: NSLocalizedString("请输入你的id", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("确认", comment: ""), style: .default, handler: { (_) in
            let textField = alert.textFields?.first!
            AntManage.postRequest(path: "access/checkin", params: ["access_token":AntManage.userModel!.token, "userid":textField!.text!], successResult: { (_) in
                AntManage.showDelayToast(message: NSLocalizedString("签入成功", comment: ""))
            }, failureResult: {})
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: 签出
    @IBAction func checkOutClick() {
        let alert = UIAlertController(title: NSLocalizedString("签出", comment: ""), message: NSLocalizedString("请输入你的id", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("确认", comment: ""), style: .default, handler: { (_) in
            let textField = alert.textFields?.first!
            AntManage.postRequest(path: "access/checkout", params: ["access_token":AntManage.userModel!.token, "userid":textField!.text!], successResult: { (_) in
                AntManage.showDelayToast(message: NSLocalizedString("签出成功", comment: ""))
            }, failureResult: {})
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: 登出
    @IBAction func logoutClick() {
        AntManage.userModel = nil
        AntManage.isLogin = false
        UserDefaults.standard.removeObject(forKey: kUserName)
        UserDefaults.standard.removeObject(forKey: kPassWord)
        UserDefaults.standard.synchronize()
        let login = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()!
        present(login, animated: true, completion: nil)
    }
    
    // MARK: - 服务器地址更改
    func requestAddressUpdate() {
        if AntManage.isLogin {
            AntManage.showDelayToast(message: NSLocalizedString("服务器地址变更，请重新登录！", comment: ""))
            navigationController?.popToRootViewController(animated: false)
            logoutClick()
        }
    }
    
    // MARK: 获取餐桌数量
    func getTableNos() {
        weak var weakSelf = self
        AntManage.getRequest(path: "tables/getTableNos", params: ["access_token":AntManage.userModel!.token,"restaurant_id":AntManage.userModel!.restaurant_id], successResult: { (response) in
            weakSelf?.dineNum = (response["dineIn"] as! NSString).integerValue
            weakSelf?.takeoutNum = (response["takeout"] as! NSString).integerValue
            weakSelf?.deliveryNum = (response["waiting"] as! NSString).integerValue
            weakSelf?.collection.reloadData()
            weakSelf?.takeoutCollection.reloadData()
            weakSelf?.deliveryCollection.reloadData()
        }, failureResult: {})
    }
    
    // MARK: 根据状态获取对应餐桌的信息
    func getTablesInfoWithType(type: String) {
        weak var weakSelf = self
        AntManage.getRequest(path: "tables/getTablesSummaryByType", params: ["access_token":AntManage.userModel!.token,"type":type], successResult: { (response) in
            let modelArray = response["data"] as! Array<NSDictionary>
            if type == "D" {
                weakSelf?.dineDic.removeAll()
                for dic in modelArray {
                    if let order = OrderModel.mj_object(withKeyValues: dic["Order"]) {
                        weakSelf?.dineDic[order.table_no] = order
                    }
                }
                weakSelf?.collection.reloadData()
            } else if type == "T" {
                weakSelf?.takeoutDic.removeAll()
                for dic in modelArray {
                    if let order = OrderModel.mj_object(withKeyValues: dic["Order"]) {
                        weakSelf?.takeoutDic[order.table_no] = order
                    }
                }
                weakSelf?.takeoutCollection.reloadData()
            } else {
                weakSelf?.deliveryDic.removeAll()
                for dic in modelArray {
                    if let order = OrderModel.mj_object(withKeyValues: dic["Order"]) {
                        weakSelf?.deliveryDic[order.table_no] = order
                    }
                }
                weakSelf?.deliveryCollection.reloadData()
            }
        }, failureResult: {})
    }
    
    // MARK: 变空桌提示
    func makeAvaliableAlert(tableDic: [String : Any]) {
        let alert = UIAlertController(title: nil, message: NSLocalizedString("请输入密码", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        weak var weakSelf = self
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (_) in
            let textField = alert.textFields?.first!
            weakSelf?.checkAdminPassword(password: textField!.text!, tableDic: tableDic)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: 校验管理员密码
    func checkAdminPassword(password: String, tableDic: [String : Any]) {
        weak var weakSelf = self
        AntManage.postRequest(path: "access/isAdminPassword", params: ["access_token":AntManage.userModel!.token, "password":password], successResult: { (response) in
            weakSelf?.makeAvaliable(tableDic: tableDic)
        }, failureResult: {})
    }
    
    // MARK: 变空桌
    func makeAvaliable(tableDic: [String : Any]) {
        weak var weakSelf = self
        let order = tableDic["OrderModel"] as! OrderModel
        AntManage.postRequest(path: "orderHandler/makeavailable", params: ["order_no":order.order_no, "access_token":AntManage.userModel!.token], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("成功清空本桌", comment: ""))
            let type = tableDic["TableType"] as! String
            let tableNo = tableDic["TableNo"] as! Int
            if type == "D" {
                weakSelf?.dineDic.removeValue(forKey: tableNo)
                weakSelf?.collection.reloadData()
            } else if type == "T" {
                weakSelf?.takeoutDic.removeValue(forKey: tableNo)
                weakSelf?.takeoutCollection.reloadData()
            } else {
                weakSelf?.deliveryDic.removeValue(forKey: tableNo)
                weakSelf?.deliveryCollection.reloadData()
            }
        }, failureResult: {})
    }
    
    // MARK: 打印收据
    func printPayBill(tableDic: [String : Any]) {
        weak var weakSelf = self
        let order = tableDic["OrderModel"] as! OrderModel
        AntManage.postRequest(path: "print/printPayBill", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_id":order.orderId, "access_token":AntManage.userModel!.token], successResult: { (_) in
            let type = tableDic["TableType"] as! String
            weakSelf?.getTablesInfoWithType(type: type)
        }, failureResult: {})
    }
    
    // MARK: 菜单点击
    func checkMenu(menu: String, tableDic: [String : Any]) {
        if menu == NSLocalizedString("订单", comment: "") {
            performSegue(withIdentifier: "Order", sender: tableDic)
        } else if menu == NSLocalizedString("换桌", comment: "") {
            
        } else if menu == NSLocalizedString("付款", comment: "") {
            performSegue(withIdentifier: "Payment", sender: tableDic)
        } else if menu == NSLocalizedString("变空桌", comment: "") {
            perform(#selector(makeAvaliableAlert(tableDic:)), with: tableDic, afterDelay: 0.01)
        } else if menu == NSLocalizedString("合单", comment: "") {
            
        } else if menu == NSLocalizedString("分单", comment: "") {
            
        } else if menu == NSLocalizedString("历史订单", comment: "") {
            performSegue(withIdentifier: "History", sender: tableDic)
        } else if menu == NSLocalizedString("打印收据", comment: "") {
            printPayBill(tableDic: tableDic)
        }
    }
    
    // MARK: 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Menu" {
            let menu: MenuController = segue.destination as! MenuController
            menu.model = (sender as! [String : Any])["OrderModel"] as? OrderModel
            menu.tableType = (sender as! [String : Any])["TableType"] as! String
            menu.tableNo = (sender as! [String : Any])["TableNo"] as! Int
            menu.home = self
            weak var weakSelf = self
            menu.confirmMenu = { (menuStr) -> () in
                AntLog(message: menuStr)
                weakSelf?.checkMenu(menu: menuStr as! String, tableDic: sender as! [String : Any])
            }
        } else if segue.identifier == "Order" {
            let order: OrderController = segue.destination as! OrderController
            order.isOrder = ((sender as! [String : Any])["OrderModel"] as? OrderModel) != nil
            order.tableType = (sender as! [String : Any])["TableType"] as! String
            order.tableNo = (sender as! [String : Any])["TableNo"] as! Int
        } else if segue.identifier == "Payment" {
            let payment: PaymentController = segue.destination as! PaymentController
            payment.tableType = (sender as! [String : Any])["TableType"] as! String
            payment.tableNo = (sender as! [String : Any])["TableNo"] as! Int
        } else if segue.identifier == "MergeBill" {
            let mergeBill: MergeBillController = segue.destination as! MergeBillController
            mergeBill.tableNoArray = sender as! [Int]
        } else if segue.identifier == "History" {
            let history: HistoryController = segue.destination as! HistoryController
            history.tableType = (sender as! [String : Any])["TableType"] as! String
            history.tableNo = (sender as! [String : Any])["TableNo"] as! Int
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collection {
            return CGSize(width: 100, height: 80)
        } else {
            return CGSize(width: collectionView.width - 40, height: 80)
        }
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection {
            return dineNum
        } else if collectionView == takeoutCollection {
            return takeoutNum
        } else {
            return deliveryNum
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : HomeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath) as! HomeCell
        let model: OrderModel?
        cell.lineView.isHidden = false
        if collectionView == collection {
            cell.numberLabel.text = NSLocalizedString("堂食", comment: "") + " \(indexPath.row + 1)"
            model = dineDic[indexPath.row + 1]
            cell.lineView.isHidden = true
        } else if collectionView == takeoutCollection {
            cell.numberLabel.text = NSLocalizedString("外卖", comment: "") + " \(indexPath.row + 1)"
            model = takeoutDic[indexPath.row + 1]
        } else {
            cell.numberLabel.text = NSLocalizedString("送餐", comment: "") + " \(indexPath.row + 1)"
            model = deliveryDic[indexPath.row + 1]
        }
        if model != nil {
            cell.contentView.backgroundColor = (model!.table_status == "R" ? UIColor.init(rgb: 0xB15BFF) : UIColor.init(rgb: 0xFF8400))
            if collectionView == collection {
                cell.moneyLabel.text = "$" + String(format: "%.2f", model!.total)
            } else {
                cell.moneyLabel.text = model!.order_no
            }
            cell.timeLabel.text = Common.obtainStringWithDate(date: Common.obtainDateWithStr(str: model!.created, formatterStr: "yyyy-MM-dd HH:mm:ss"), formatterStr: "HH:mm")
        } else {
            cell.contentView.backgroundColor = UIColor.init(rgb: 0xE3E3E4)
            cell.moneyLabel.text = ""
            cell.timeLabel.text = ""
        }
        cell.lineWidth.constant = (cell.moneyLabel.text! as NSString).width(for: cell.moneyLabel.font)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model: OrderModel?
        let tableType: String!
        if collectionView == collection {
            model = dineDic[indexPath.row + 1]
            tableType = "D"
        } else if collectionView == takeoutCollection {
            model = takeoutDic[indexPath.row + 1]
            tableType = "T"
        } else {
            model = deliveryDic[indexPath.row + 1]
            tableType = "W"
        }
        if model != nil {
            performSegue(withIdentifier: "Menu", sender: ["OrderModel":model!,"TableType":tableType,"TableNo":indexPath.row + 1])
        } else {
            performSegue(withIdentifier: "Menu", sender: ["TableType":tableType,"TableNo":indexPath.row + 1])
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
