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
    var model: OrderModel?
    var tableType: String!//餐桌类型
    var tableNo = 0//餐桌号
    weak var home: HomeController?
    var menuTitleArray = [String]()//菜单数组
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if tableType == "D" {
            titleLabel.text = NSLocalizedString("堂食", comment: "") + " \(tableNo)"
            menuTitleArray += [NSLocalizedString("订单", comment: ""),NSLocalizedString("换桌", comment: ""),NSLocalizedString("付款", comment: ""),NSLocalizedString("变空桌", comment: ""),NSLocalizedString("合单", comment: ""),NSLocalizedString("分单", comment: ""),NSLocalizedString("历史订单", comment: "")]
        } else if tableType == "T" {
            titleLabel.text = NSLocalizedString("外卖", comment: "") + " \(tableNo)"
            menuTitleArray += [NSLocalizedString("订单", comment: ""),NSLocalizedString("换桌", comment: ""),NSLocalizedString("付款", comment: ""),NSLocalizedString("变空桌", comment: ""),NSLocalizedString("历史订单", comment: "")]
        } else {
            titleLabel.text = NSLocalizedString("送餐", comment: "") + " \(tableNo)"
            menuTitleArray += [NSLocalizedString("订单", comment: ""),NSLocalizedString("换桌", comment: ""),NSLocalizedString("付款", comment: ""),NSLocalizedString("清空", comment: "")]
        }
        if model != nil {
            menuTitleArray.append(NSLocalizedString("Receipt", comment: ""))
        }
        if menuTitleArray.count % 2 == 1 {
            menuTitleArray.append("")
        }
        viewHeight.constant = CGFloat(55 + (menuTitleArray.count / 2) * 51 + 1)
    }
    
    @IBAction func dismissMenuClick(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == bgView || touch.view?.className() == "UIButton" {
            return false
        }
        return true
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuTitleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MenuCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.menuBtn.setTitle(menuTitleArray[indexPath.row], for: .normal)
        cell.menuBtn.setTitleColor(UIColor.white, for: .normal)
        if model == nil {
            if !(menuTitleArray[indexPath.row] == NSLocalizedString("订单", comment: "") ||
                menuTitleArray[indexPath.row] == NSLocalizedString("历史订单", comment: "")) {
                cell.menuBtn.setTitleColor(UIColor.init(rgb: 0x808080), for: .normal)
            }
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
