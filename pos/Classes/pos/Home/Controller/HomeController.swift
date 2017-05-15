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
    var dineDic = [NSNumber : OrderModel]()//堂食字典,key为餐桌号,value为餐桌信息
    var takeoutDic = [NSNumber : OrderModel]()//外卖字典,key为餐桌号,value为餐桌信息
    var deliveryDic = [NSNumber : OrderModel]()//送餐字典,key为餐桌号,value为餐桌信息
    var dineNum = 0//堂食餐桌数量
    var takeoutNum = 0//外卖餐桌数量
    var deliveryNum = 0//送餐餐桌数量
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        collection.register(UINib(nibName: "HomeCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCell")
        takeoutCollection.register(UINib(nibName: "HomeCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCell")
        deliveryCollection.register(UINib(nibName: "HomeCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HomeCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !AntManage.isLogin {
            let login = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()!
            present(login, animated: true, completion: nil)
        } else {
            if dineNum == 0 {
                getTableNos()
                getTablesInfoWithType(type: "D")
                getTablesInfoWithType(type: "T")
                getTablesInfoWithType(type: "W")
            }
        }
    }

    // MARK: 主页
    @IBAction func homeClick() {
        
    }
    
    // MARK: 管理员
    @IBAction func managerClick() {
        
    }
    
    // MARK: 语言
    @IBAction func languageClick() {
        
    }
    
    // MARK: 签入
    @IBAction func checkInClick() {
        
    }
    
    // MARK: 签出
    @IBAction func checkOutClick() {
        
    }
    
    // MARK: 登出
    @IBAction func logoutClick() {
        
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
    
    //MARK: - UICollectionViewDelegateFlowLayout
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
        if collectionView == collection {
            cell.numberLabel.text = NSLocalizedString("堂食", comment: "") + " \(indexPath.row + 1)"
            model = dineDic[NSNumber(integerLiteral: indexPath.row + 1)]
        } else if collectionView == takeoutCollection {
            cell.numberLabel.text = NSLocalizedString("Out", comment: "") + " \(indexPath.row + 1)"
            model = takeoutDic[NSNumber(integerLiteral: indexPath.row + 1)]
        } else {
            cell.numberLabel.text = NSLocalizedString("Deliv", comment: "") + " \(indexPath.row + 1)"
            model = deliveryDic[NSNumber(integerLiteral: indexPath.row + 1)]
        }
        if model != nil {
            cell.contentView.backgroundColor = UIColor.init(rgb: 0xFF8400)
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
