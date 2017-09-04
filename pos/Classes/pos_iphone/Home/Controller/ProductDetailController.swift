//
//  ProductDetailController.swift
//  pos
//
//  Created by luan on 2017/8/30.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ProductDetailController: AntController {
    
    var productModel: ProductModel?

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
        AntManage.iphoneGetRequest(path: "route=feed/rest_api/products&id=\(productModel!.product_id)", params: nil, successResult: { (response) in
            
        }, failureResult: {
            weakSelf?.navigationController?.popViewController(animated: true)
        })
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
