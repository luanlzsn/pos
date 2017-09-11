//
//  ProductDetailController.swift
//  pos
//
//  Created by luan on 2017/8/30.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ProductDetailController: AntController {
    
    var productModel: ProductModel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productCode: UILabel!
    @IBOutlet weak var availability: UILabel!//库存
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var originalPrice: UILabel!
    @IBOutlet weak var exTax: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if productModel != nil {
            navigationItem.title = productModel?.name
            getProductDetail()
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("没有商品信息！", comment: ""))
            navigationController?.popViewController(animated: true)
        }
    }
    
    func getProductDetail() {
        var productId = 0
        if productModel.product_id != 0 {
            productId = productModel.product_id
        } else if productModel.productId != 0 {
            productId = productModel.productId
        }
        if productId != 0 {
            weak var weakSelf = self
            AntManage.iphoneGetRequest(path: "route=feed/rest_api/products", params: ["id":productId], successResult: { (response) in
                if let data = response["data"] {
                    weakSelf?.productModel = ProductModel.mj_object(withKeyValues: data)
                    weakSelf?.refreshProductInfo()
                }
            }, failureResult: {
                weakSelf?.navigationController?.popViewController(animated: true)
            })
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("商品信息错误", comment: ""))
            navigationController?.popViewController(animated: true)
        }
    }
    
    func refreshProductInfo() {
        productImage.sd_setImage(with: URL(string: productModel.image), placeholderImage: UIImage(named: "default_image"))
        productName.text = productModel.name
        productCode.text = productModel.model
        availability.text = NSLocalizedString((productModel.quantity > 0) ? "有存货" : "无存货", comment: "")
        if productModel.special == 0 {
            price.text = productModel.price_formated
            exTax.text = "$\(productModel.price_excluding_tax)"
            originalPrice.isHidden = true
        } else {
            price.text = productModel.special_formated
            exTax.text = "$\(productModel.special_excluding_tax)"
            originalPrice.isHidden = false
            originalPrice.attributedText = NSAttributedString(string: productModel.price_formated, attributes: [NSStrikethroughStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue])
        }
    }
    
    @IBAction func addShopCartClick(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("数量", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = "1"
            textField.keyboardType = .numberPad
        }
        weak var weakSelf = self
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (_) in
            let textField = alert.textFields!.first!
            if Common.isValidateNumber(numberStr: textField.text!) {
                weakSelf?.checkRequest(number: Int(textField.text!)!)
            } else {
                AntManage.showDelayToast(message: NSLocalizedString("数量必须是数字", comment: ""))
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func checkRequest(number: Int) {
        var productId = 0
        if productModel.product_id != 0 {
            productId = productModel.product_id
        } else if productModel.productId != 0 {
            productId = productModel.productId
        }
        if productId != 0 {
            var selectOption = [String : [String]]()
            for optionModel in productModel.options {
                var optionValueArray = [String]()
                for option_value in optionModel.option_value {
                    if option_value.isSelect {
                        optionValueArray.append("\(option_value.product_option_value_id)")
                    }
                }
                if optionValueArray.count > 0 {
                    selectOption["\(optionModel.product_option_id)"] = optionValueArray
                } else if optionModel.required {
                    AntManage.showDelayToast(message: NSLocalizedString("必须输入\(optionModel.name)!", comment: ""))
                    performSegue(withIdentifier: "AvailableOptions", sender: nil)
                    return
                }
            }
            weak var weakSelf = self
            AntManage.iphonePostRequest(path: "route=rest/cart/cart", params: ["product_id":productId, "quantity":number, "option":selectOption], successResult: { (_) in
                AntManage.showDelayToast(message: NSLocalizedString("成功: 添加 ", comment: "") + weakSelf!.productModel.name + NSLocalizedString(" 到您的 购物车 ！", comment: ""))
                NotificationCenter.default.post(name: NSNotification.Name("kAddShopCartSuccess"), object: nil)
            }, failureResult: {})
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("商品信息错误", comment: ""))
        }
    }
    
    // MARK: - 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AvailableOptions" {
            let availableOptions = segue.destination as! AvailableOptionsController
            availableOptions.optionArray = productModel.options
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
