//
//  MenuController.swift
//  pos
//
//  Created by luan on 2017/5/20.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class MenuController: AntController,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var changeView: UIView!
    @IBOutlet weak var changeHeight: NSLayoutConstraint!
    @IBOutlet weak var changeCollection: UICollectionView!
    @IBOutlet weak var changeCollectionBottom: NSLayoutConstraint!
    @IBOutlet weak var mergeConfirmBtn: UIButton!
    
    var confirmMenu: ConfirmBlock?
    
    var model: OrderModel?
    var tableType: String!//餐桌类型
    var tableNo = 0//餐桌号
    weak var home: HomeController?
    var menuTitleArray = [String]()//菜单数组
    var changeArray = [[String : [NSNumber]]]()//可以被换桌的信息
    var isChangeTable = false//是否是换桌
    var mergeArray = [OrderModel]()//可合单的信息
    var selectMergeArray = [Int]()//选择的合单的餐桌
    
    deinit {
        confirmMenu = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkMenuData()
    }
    
    func checkMenuData() {
        if tableType == "D" {
            titleLabel.text = NSLocalizedString("堂食", comment: "") + " \(tableNo)"
            menuTitleArray += [NSLocalizedString("订单", comment: ""),NSLocalizedString("换桌", comment: ""),NSLocalizedString("付款", comment: ""),NSLocalizedString("变空桌", comment: ""),NSLocalizedString("合单", comment: ""),/*NSLocalizedString("分单", comment: ""),*/NSLocalizedString("历史订单", comment: "")]
        } else if tableType == "T" {
            titleLabel.text = NSLocalizedString("外卖", comment: "") + " \(tableNo)"
            menuTitleArray += [NSLocalizedString("订单", comment: ""),NSLocalizedString("换桌", comment: ""),NSLocalizedString("付款", comment: ""),NSLocalizedString("变空桌", comment: ""),NSLocalizedString("历史订单", comment: "")]
        } else {
            titleLabel.text = NSLocalizedString("送餐", comment: "") + " \(tableNo)"
            menuTitleArray += [NSLocalizedString("订单", comment: ""),NSLocalizedString("换桌", comment: ""),NSLocalizedString("付款", comment: ""),NSLocalizedString("清空", comment: "")]
        }
        if model != nil {
            menuTitleArray.append(NSLocalizedString("打印收据", comment: ""))
        }
        if menuTitleArray.count % 2 == 1 {
            menuTitleArray.append("")
        }
        viewHeight.constant = CGFloat(55 + (menuTitleArray.count / 2) * 51 + 1)
    }
    
    // MARK: 获取换桌信息
    func checkChangeTableData() {
        changeArray.removeAll()
        changeCollectionBottom.constant = 0
        mergeConfirmBtn.isHidden = true
        var height = 0.0
        
        var dineSet = Set<NSNumber>()
        for i in 1...home!.dineNum {
            dineSet.insert(NSNumber(integerLiteral: i))
        }
        let dineArray = [NSNumber](dineSet.subtracting(Set((home!.dineDic as NSDictionary).allKeys as! [NSNumber]))).sorted { (num1, num2) -> Bool in
            num1.intValue < num2.intValue
        }
        if dineArray.count > 0 {
            changeArray.append([NSLocalizedString("堂食", comment: "") : dineArray])
            height += 45.0 * (ceil(Double(dineArray.count) / 3.0) + 1)
        }
        
        var takeoutSet = Set<NSNumber>()
        for i in 1...home!.takeoutNum {
            takeoutSet.insert(NSNumber(integerLiteral: i))
        }
        let takeoutArray = [NSNumber](takeoutSet.subtracting(Set((home!.takeoutDic as NSDictionary).allKeys as! [NSNumber]))).sorted { (num1, num2) -> Bool in
            num1.intValue < num2.intValue
        }
        if takeoutArray.count > 0 {
            changeArray.append([NSLocalizedString("外卖", comment: "") : takeoutArray])
            height += 45.0 * (ceil(Double(takeoutArray.count) / 3.0) + 1)
        }
        
        var deliverySet = Set<NSNumber>()
        for i in 1...home!.deliveryNum {
            deliverySet.insert(NSNumber(integerLiteral: i))
        }
        let deliveryArray = [NSNumber](deliverySet.subtracting(Set((home!.deliveryDic as NSDictionary).allKeys as! [NSNumber]))).sorted { (num1, num2) -> Bool in
            num1.intValue < num2.intValue
        }
        if deliveryArray.count > 0 {
            changeArray.append([NSLocalizedString("送餐", comment: "") : deliveryArray])
            height += 45.0 * (ceil(Double(deliveryArray.count) / 3.0) + 1)
        }

        if height > Double(kScreenHeight - 75) {
            height = Double(kScreenHeight - 75)
        }
        changeHeight.constant = CGFloat(35.0 + height)
        changeCollection.reloadData()
    }
    
    // MAKR: 获取合单信息
    func checkMerge() {
        mergeArray.removeAll()
        changeCollectionBottom.constant = 55
        mergeConfirmBtn.isHidden = false
        var height = 0.0
        for (num, order) in home!.dineDic {
            if order.table_status != "R", num != tableNo {
                mergeArray.append(order)
            }
        }
        mergeArray.sort { (order1, order2) -> Bool in
            order1.table_no < order2.table_no
        }
        height += 45.0 * (ceil(Double(mergeArray.count) / 3.0) + 1) + 55
        
        if height > Double(kScreenHeight - 75) {
            height = Double(kScreenHeight - 75)
        }
        changeHeight.constant = CGFloat(35.0 + height)
        changeCollection.reloadData()
    }
    
    // MARK: 确认合单
    @IBAction func mergeConfirmClick() {
        var orderIdArray = selectMergeArray
        orderIdArray.insert(model!.table_no, at: 0)
        home!.performSegue(withIdentifier: "MergeBill", sender: orderIdArray)
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func cancelChangeViewClick() {
        changeView.isHidden = true
    }
    
    @IBAction func dismissMenuClick(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: 换桌
    func changeTable(tableNo: NSNumber, tableType: String) {
        weak var weakSelf = self
        AntManage.postRequest(path: "orderHandler/moveOrder", params: ["type":tableType, "table":tableNo, "order_no":model!.order_no, "access_token":AntManage.userModel!.token], successResult: { (response) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ChangeTableSuccsee"), object: nil)
            weakSelf?.dismiss(animated: true, completion: nil)
        }) { 
            AntManage.showDelayToast(message: NSLocalizedString("换桌失败，请重试！", comment: ""))
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == bgView || touch.view == changeView || touch.view?.className() == "UIButton" {
            return false
        }
        return true
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == collection {
            return 1
        } else {
            if isChangeTable {
                return changeArray.count
            } else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collection {
            return menuTitleArray.count
        } else {
            if isChangeTable {
                return ((changeArray[section].values.first != nil) ? changeArray[section].values.first!.count : 0)
            } else {
                return mergeArray.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == changeCollection, kind == UICollectionElementKindSectionHeader {
            let header: ChangeTableHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ChangeTableHeaderView", for: indexPath) as! ChangeTableHeaderView
            if isChangeTable {
                header.headerTitle.text = changeArray[indexPath.section].keys.first
            } else {
                header.headerTitle.text = NSLocalizedString("合单", comment: "")
            }
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collection {
            let cell: MenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCell
            cell.menuBtn.setTitle(menuTitleArray[indexPath.row], for: .normal)
            cell.menuBtn.setTitleColor(UIColor.white, for: .normal)
            weak var weakSelf = self
            cell.confirmMenu = {(_) -> () in
                if weakSelf?.menuTitleArray[indexPath.row] == NSLocalizedString("换桌", comment: "") {
                    weakSelf?.isChangeTable = true
                    weakSelf?.checkChangeTableData()
                    weakSelf?.changeView.isHidden = false
                } else if weakSelf?.menuTitleArray[indexPath.row] == NSLocalizedString("合单", comment: "") {
                    weakSelf?.isChangeTable = false
                    weakSelf?.selectMergeArray.removeAll()
                    weakSelf?.checkMerge()
                    weakSelf?.changeView.isHidden = false
                } else {
                    if weakSelf?.confirmMenu != nil {
                        weakSelf?.confirmMenu!(weakSelf!.menuTitleArray[indexPath.row])
                        weakSelf?.dismiss(animated: false, completion: nil)
                    }
                }
            }
            if model == nil {
                if !(menuTitleArray[indexPath.row] == NSLocalizedString("订单", comment: "") ||
                    menuTitleArray[indexPath.row] == NSLocalizedString("历史订单", comment: "")) {
                    cell.menuBtn.setTitleColor(UIColor.init(rgb: 0x808080), for: .normal)
                    cell.confirmMenu = nil
                }
            } else if model!.table_status == "R", (menuTitleArray[indexPath.row] == NSLocalizedString("变空桌", comment: "") || menuTitleArray[indexPath.row] == NSLocalizedString("合单", comment: "")) {
                cell.menuBtn.setTitleColor(UIColor.init(rgb: 0x808080), for: .normal)
                cell.confirmMenu = nil
            }
            return cell
        } else {
            let cell: ChangeTableCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChangeTableCell", for: indexPath) as! ChangeTableCell
            if isChangeTable {
                cell.changeNumBtn.setTitle("\(changeArray[indexPath.section].values.first![indexPath.row])", for: .normal)
                cell.changeNumBtn.layer.borderColor = UIColor.init(rgb: 0x808080).cgColor
                weak var weakSelf = self
                cell.changeTable = {(_) -> () in
                    let tableNo = (weakSelf?.changeArray[indexPath.section].values.first![indexPath.row])!
                    let tableType: String!
                    if weakSelf?.changeArray[indexPath.section].keys.first == NSLocalizedString("堂食", comment: "") {
                        tableType = "D"
                    } else if weakSelf?.changeArray[indexPath.section].keys.first == NSLocalizedString("外卖", comment: "") {
                        tableType = "T"
                    } else {
                        tableType = "W"
                    }
                    weakSelf?.changeTable(tableNo:tableNo , tableType:tableType )
                }
            } else {
                cell.changeNumBtn.setTitle("\(mergeArray[indexPath.row].table_no)", for: .normal)
                if selectMergeArray.contains(mergeArray[indexPath.row].table_no) {
                    cell.changeNumBtn.layer.borderColor = UIColor.init(rgb: 0x5BC0DE).cgColor
                } else {
                    cell.changeNumBtn.layer.borderColor = UIColor.init(rgb: 0x808080).cgColor
                }
                weak var weakSelf = self
                cell.changeTable = {(_) -> () in
                    if weakSelf!.selectMergeArray.contains(weakSelf!.mergeArray[indexPath.row].table_no) {
                        weakSelf?.selectMergeArray.remove(at: weakSelf!.selectMergeArray.index(of: weakSelf!.mergeArray[indexPath.row].table_no)!)
                    } else {
                        weakSelf?.selectMergeArray.append(weakSelf!.mergeArray[indexPath.row].table_no)
                    }
                    weakSelf?.changeCollection.reloadData()
                }
            }
            return cell
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
