//
//  ShopCartController.swift
//  pos
//
//  Created by luan on 2017/5/14.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ShopCartController: AntController,UITableViewDelegate,UITableViewDataSource,ShopCartCell_Delegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var productPriceTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var taxPriceTitle: UILabel!
    @IBOutlet weak var taxPrice: UILabel!
    @IBOutlet weak var orderPriceTitle: UILabel!
    @IBOutlet weak var orderPrice: UILabel!
    var shopCartModel: ShopCartModel?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(getShopCartInfo), name: NSNotification.Name(kAddShopCartSuccess), object: nil)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(getShopCartInfo))
        getShopCartInfo()
    }
    
    func getShopCartInfo() {
        weak var weakSelf = self
        AntManage.iphoneGetRequest(path: "route=rest/cart/cart", params: nil, successResult: { (response) in
            weakSelf?.shopCartModel = ShopCartModel.mj_object(withKeyValues: response["data"])
            weakSelf?.tableView.mj_header.endRefreshing()
            weakSelf?.tableView.reloadData()
            weakSelf?.refreshPrice()
        }, failureResult: {})
    }
    
    func refreshPrice() {
        if shopCartModel != nil, shopCartModel!.totals.count >= 3 {
            if let productPriceInfo = shopCartModel?.totals.first {
                productPriceTitle.text = productPriceInfo.title
                productPrice.text = productPriceInfo.text
            }
            if let taxPriceInfo = shopCartModel?.totals[1] {
                taxPriceTitle.text = taxPriceInfo.title
                taxPrice.text = taxPriceInfo.text
            }
            if let orderPriceInfo = shopCartModel?.totals.last {
                orderPriceTitle.text = orderPriceInfo.title
                orderPrice.text = orderPriceInfo.text
            }
        }
    }

    @IBAction func checkOutClick(_ sender: UIButton) {
        
    }
    
    // MARK: - ShopCartCell_Delegate
    func deleteShopCart(_ row: Int) {
        let product = shopCartModel!.products[row]
        weak var weakSelf = self
        AntManage.iphoneDeleteRequest(path: "route=rest/cart/cart", params: ["key":product.key], successResult: { (_) in
            weakSelf?.getShopCartInfo()
        }, failureResult: {})
    }
    
    // MARK: - UITableViewDelegate,UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopCartModel?.products.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ShopCartCell = tableView.dequeueReusableCell(withIdentifier: "ShopCartCell", for: indexPath) as! ShopCartCell
        let product = shopCartModel!.products[indexPath.row]
        cell.delegate = self
        cell.tag = indexPath.row
        cell.productName.text = product.name
        cell.productImage?.sd_setImage(with: URL(string: product.image), placeholderImage: UIImage(named: "default_image"))
        var optionDic = [String : [String]]()
        for option in product.option {
            if optionDic.keys.contains(option.name) {
                optionDic[option.name]?.append(option.value)
            } else {
                optionDic[option.name] = [String]()
                optionDic[option.name]?.append(option.value)
            }
        }
        if optionDic.count > 0 {
            cell.taste.isHidden = false
            var tasteStr = ""
            for (tasteName, tasteValue) in optionDic {
                tasteStr.append("\(tasteName):")
                for str in tasteValue {
                    tasteStr.append("\(str),")
                }
                tasteStr.remove(at: tasteStr.index(before: tasteStr.endIndex))
                tasteStr += "\n"
            }
            tasteStr.remove(at: tasteStr.index(before: tasteStr.endIndex))
            cell.taste.text = tasteStr
        } else {
            cell.taste.isHidden = true
            cell.taste.text = ""
        }
        cell.number.text = "Qty: \(product.quantity)"
        cell.price.text = NSLocalizedString("单价：", comment: "") + product.price
        cell.total.text = NSLocalizedString("总计：", comment: "") + product.total
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
