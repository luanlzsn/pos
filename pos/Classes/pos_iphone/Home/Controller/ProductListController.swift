//
//  ProductListController.swift
//  pos
//
//  Created by luan on 2017/8/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ProductListController: AntController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ProductCell_Delegate {
    
    @IBOutlet weak var collection: UICollectionView!
    var categoryModel: CategoriesModel!
    var productArray = [ProductModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = categoryModel.name
        collection.register(UINib(nibName: "ProductCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ProductCell")
        getProductArray()
    }
    
    func getProductArray() {
        weak var weakSelf = self
        AntManage.iphoneGetRequest(path: "route=feed/rest_api/products", params: ["category":categoryModel.category_id], successResult: { (response) in
            weakSelf?.productArray = ProductModel.mj_objectArray(withKeyValuesArray: response["data"]) as! [ProductModel]
            weakSelf?.collection.reloadData()
        }, failureResult: {})
    }
    
    // MARK: - 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductDetail" {
            let productDetail = segue.destination as! ProductDetailController
            productDetail.productModel = sender as? ProductModel
        }
    }
    
    // MARK: - ProductCell_Delegate
    func addShopCart(_ row: Int) {
        let model = productArray[row]
        for optionModel in model.options {
            if optionModel.required {
                performSegue(withIdentifier: "ProductDetail", sender: model)
                return
            }
        }
        AntManage.iphonePostRequest(path: "route=rest/cart/cart", params: ["product_id":model.product_id, "quantity":1], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("成功: 添加 ", comment: "") + model.name + NSLocalizedString(" 到您的 购物车 ！", comment: ""))
            NotificationCenter.default.post(name: NSNotification.Name("kAddShopCartSuccess"), object: nil)
        }, failureResult: {})
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (kScreenWidth - 30) / 2.0
        return CGSize(width: cellWidth, height: cellWidth + 110)
    }
    
    // MARK: - UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        let model = productArray[indexPath.row]
        cell.delegate = self
        cell.tag = indexPath.row
        cell.productImage.sd_setImage(with: URL(string: model.image), placeholderImage: UIImage(named: "default_image"))
        cell.productName.text = model.name
        cell.productDesc.text = model.desc
        if model.special == 0 {
            cell.price.text = model.price_formated
            cell.exTax.text = NSLocalizedString("不含税", comment: "") + ": $\(model.price_excluding_tax)"
            cell.originalPrice.isHidden = true
        } else {
            cell.price.text = model.special_formated
            cell.exTax.text = NSLocalizedString("不含税", comment: "") + ": $\(model.special_excluding_tax)"
            cell.originalPrice.isHidden = false
            cell.originalPrice.attributedText = NSAttributedString(string: model.price_formated, attributes: [NSStrikethroughStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ProductDetail", sender: productArray[indexPath.row])
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
