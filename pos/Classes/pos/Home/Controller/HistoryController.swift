//
//  HistoryController.swift
//  pos
//
//  Created by luan on 2017/5/30.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class HistoryController: AntController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableNumLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var tableNo = 0//餐桌号
    var tableType = ""//餐桌类别
    var historyArray = [HistoryModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        let type: String!
        if tableType == "D" {
            type = NSLocalizedString("堂食", comment: "")
        } else if tableType == "T" {
            type = NSLocalizedString("外卖", comment: "")
        } else {
            type = NSLocalizedString("送餐", comment: "")
        }
        tableNumLabel.text = NSLocalizedString("桌", comment: "") + "[[\(type!)]]#\(tableNo)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getHistoryInfo()
    }

    @IBAction func homeClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func getHistoryInfo() {
        weak var weakSelf = self
        AntManage.postRequest(path: "orderHandler/tableHistory", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "table":tableNo, "type":tableType, "access_token":AntManage.userModel!.token], successResult: { (response) in
            let dic = (response["data"] as! NSString).mj_JSONObject() as! NSDictionary
            weakSelf?.historyArray = HistoryModel.mj_objectArray(withKeyValuesArray: dic["Order_detail"]) as! [HistoryModel]
            weakSelf?.tableView.reloadData()
        }, failureResult: {
            weakSelf?.homeClick()
        })
    }
    
    // MARK: 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HistoryDetail" {
            let detail: HistoryDetailController = segue.destination as! HistoryDetailController
            detail.historyModel = sender as! HistoryModel
            detail.tableType = tableType
            detail.tableNo = tableNo
        }
    }
    
    // MARK: UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HistoryCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let model = historyArray[historyArray.count - indexPath.row - 1].orderInfo!
        cell.orderTime.text = model.created
        cell.orderNum.text = model.order_no
        cell.subTotal.text = String(format: "%.2f", model.subtotal)
        cell.taxMoney.text = String(format: "%.2f", model.tax_amount)
        cell.total.text = String(format: "%.2f", model.total)
        weak var weakSelf = self
        cell.showOrderDetail = { _ in
            weakSelf?.performSegue(withIdentifier: "HistoryDetail", sender: weakSelf?.historyArray[(weakSelf?.historyArray.count)! - indexPath.row - 1])
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
