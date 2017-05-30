//
//  ChangeTableController.swift
//  pos
//
//  Created by luan on 2017/5/30.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ChangeTableController: AntController,UICollectionViewDelegate,UICollectionViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var changeView: UIView!
    @IBOutlet weak var changeHeight: NSLayoutConstraint!
    @IBOutlet weak var changeCollection: UICollectionView!
    var changeTable: ConfirmBlock?
    
    var changeArray = [[String : [NSNumber]]]()//可以被换桌的信息
    
    deinit {
        changeTable = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        checkChangeTableData()
    }

    @IBAction func cancelClick() {
        if changeTable != nil {
            changeTable = nil
        }
        dismiss(animated: true, completion: nil)
    }
    
    func checkChangeTableData() {
        var height = 0.0
        let home = ((UIApplication.shared.delegate as! AppDelegate).window!.rootViewController as! UINavigationController).viewControllers.first as! HomeController
        
        var dineSet = Set<NSNumber>()
        for i in 1...home.dineNum {
            dineSet.insert(NSNumber(integerLiteral: i))
        }
        let dineArray = [NSNumber](dineSet.subtracting(Set((home.dineDic as NSDictionary).allKeys as! [NSNumber]))).sorted { (num1, num2) -> Bool in
            num1.intValue < num2.intValue
        }
        if dineArray.count > 0 {
            changeArray.append([NSLocalizedString("堂食", comment: "") : dineArray])
            height += 45.0 * (ceil(Double(dineArray.count) / 3.0) + 1)
        }
        
        var takeoutSet = Set<NSNumber>()
        for i in 1...home.takeoutNum {
            takeoutSet.insert(NSNumber(integerLiteral: i))
        }
        let takeoutArray = [NSNumber](takeoutSet.subtracting(Set((home.takeoutDic as NSDictionary).allKeys as! [NSNumber]))).sorted { (num1, num2) -> Bool in
            num1.intValue < num2.intValue
        }
        if takeoutArray.count > 0 {
            changeArray.append([NSLocalizedString("外卖", comment: "") : takeoutArray])
            height += 45.0 * (ceil(Double(takeoutArray.count) / 3.0) + 1)
        }
        
        var deliverySet = Set<NSNumber>()
        for i in 1...home.deliveryNum {
            deliverySet.insert(NSNumber(integerLiteral: i))
        }
        let deliveryArray = [NSNumber](deliverySet.subtracting(Set((home.deliveryDic as NSDictionary).allKeys as! [NSNumber]))).sorted { (num1, num2) -> Bool in
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
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == changeView || touch.view?.className() == "UIButton" {
            return false
        }
        return true
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return changeArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ((changeArray[section].values.first != nil) ? changeArray[section].values.first!.count : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header: ChangeTableHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ChangeTableHeaderView", for: indexPath) as! ChangeTableHeaderView
            header.headerTitle.text = changeArray[indexPath.section].keys.first
            return header
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ChangeTableCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChangeTableCell", for: indexPath) as! ChangeTableCell
        cell.changeNumBtn.setTitle("\(changeArray[indexPath.section].values.first![indexPath.row])", for: .normal)
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
            if weakSelf!.changeTable != nil {
                weakSelf!.changeTable!(["TableNo":tableNo, "TableType":tableType])
            }
            weakSelf?.cancelClick()
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
