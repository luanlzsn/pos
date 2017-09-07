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
        weak var weakSelf = self
        AntManage.iphoneGetRequest(path: "route=feed/rest_api/products&id=\(productModel.product_id)", params: nil, successResult: { (response) in
            if let data = response["data"] {
                weakSelf?.productModel = ProductModel.mj_object(withKeyValues: data)
                weakSelf?.refreshProductInfo()
            }
        }, failureResult: {
            weakSelf?.navigationController?.popViewController(animated: true)
        })
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

    @IBAction func availableOptionsClick(_ sender: UIButton) {
        
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
        weak var weakSelf = self
        AntManage.iphonePostRequest(path: "route=rest/cart/cart", params: ["product_id":productModel.productId, "quantity":number], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("成功: 添加 ", comment: "") + weakSelf!.productModel.name + NSLocalizedString(" 到您的 购物车 ！", comment: ""))
            NotificationCenter.default.post(name: NSNotification.Name("kAddShopCartSuccess"), object: nil)
        }, failureResult: {})
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
