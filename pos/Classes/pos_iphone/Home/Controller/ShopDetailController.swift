//
//  ShopDetailController.swift
//  pos
//
//  Created by luan on 2017/9/4.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ShopDetailController: AntController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ProductCell_Delegate {

    @IBOutlet weak var collection: UICollectionView!
    var shopModel: HomeShopModel?
    let sectionTitleArray = ["分类","特色商品"]
    var categoriesArray = [CategoriesModel]()
    var featuredArray = [ProductModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.register(UINib(nibName: "ProductCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ProductCell")
        if shopModel != nil {
            navigationItem.title = shopModel!.name
            getCategories()
            getFeaturedProduct()
        } else {
            AntManage.showDelayToast(message: NSLocalizedString("没有店铺信息！", comment: ""))
            navigationController?.popViewController(animated: true)
        }
    }
    
    func getCategories() {
        weak var weakSelf = self
        AntManage.manager.requestSerializer.setValue("\(shopModel!.store_id)", forHTTPHeaderField: "Store-Id")
        AntManage.iphoneGetRequest(path: "route=feed/rest_api/categories", params: nil, successResult: { (response) in
            weakSelf?.categoriesArray = CategoriesModel.mj_objectArray(withKeyValuesArray: response["data"]) as! [CategoriesModel]
            weakSelf?.collection.reloadData()
        }, failureResult: {})
    }
    
    func getFeaturedProduct() {
        weak var weakSelf = self
        AntManage.manager.requestSerializer.setValue("\(shopModel!.store_id)", forHTTPHeaderField: "Store-Id")
        AntManage.iphoneGetRequest(path: "route=feed/rest_api/featured", params: nil, successResult: { (response) in
            if let data = response["data"] as? [[String : Any]] {
                if let products = data.first {
                    weakSelf?.featuredArray = ProductModel.mj_objectArray(withKeyValuesArray: products["products"]) as! [ProductModel]
                    weakSelf?.collection.reloadData()
                }
            }
        }, failureResult: {})
    }
    
    // MARK: - 跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductDetail" {
            let productDetail = segue.destination as! ProductDetailController
            productDetail.productModel = sender as? ProductModel
        } else if segue.identifier == "ProductList" {
            let productList = segue.destination as! ProductListController
            productList.categoryModel = sender as! CategoriesModel
        }
    }
    
    // MARK: - ProductCell_Delegate
    func addShopCart(_ row: Int) {
        let model = featuredArray[row]
        AntManage.iphonePostRequest(path: "route=rest/cart/cart", params: ["product_id":model.product_id, "quantity":1], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("成功: 添加 ", comment: "") + model.name + NSLocalizedString(" 到您的 购物车 ！", comment: ""))
        }, failureResult: {})
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section % 2 == 0 {
            return CGSize(width: kScreenWidth, height: 50)
        } else if indexPath.section == sectionTitleArray.count * 2 - 1 {
            let cellWidth = (kScreenWidth - 30) / 2.0
            return CGSize(width: cellWidth, height: cellWidth + 110)
        } else {
            return CGSize(width: kScreenWidth, height: 50)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == sectionTitleArray.count * 2 - 1 {
            return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    // MARK: - UICollectionViewDelegate,UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionTitleArray.count * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (section == sectionTitleArray.count * 2 - 1) ? featuredArray.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section % 2 == 0 {
            let cell: ProductSectionTitleCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductSectionTitleCell", for: indexPath) as! ProductSectionTitleCell
            cell.categoriesTitle.text = NSLocalizedString(sectionTitleArray[indexPath.section / 2], comment: "")
            return cell
        } else if indexPath.section == sectionTitleArray.count * 2 - 1 {
            let cell: ProductCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            let model = featuredArray[indexPath.row]
            cell.delegate = self
            cell.productImage.sd_setImage(with: URL(string: model.image), placeholderImage: UIImage(named: "default_image"))
            cell.productName.text = model.name
            cell.productDesc.text = model.desc
            if model.special == 0 {
                cell.price.text = model.price_formated
                cell.exTax.text = "Ex Tax: $\(model.price_excluding_tax)"
                cell.originalPrice.isHidden = true
            } else {
                cell.price.text = model.special_formated
                cell.exTax.text = "Ex Tax: $\(model.special_excluding_tax)"
                cell.originalPrice.isHidden = false
                cell.originalPrice.attributedText = NSAttributedString(string: model.price_formated, attributes: [NSStrikethroughStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue])
            }
            return cell
        } else {
            let cell: ProductCategoriesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCategoriesCell", for: indexPath) as! ProductCategoriesCell
            cell.refreshCategories(categoriesArray)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == sectionTitleArray.count * 2 - 1 {
            performSegue(withIdentifier: "ProductDetail", sender: featuredArray[indexPath.row])
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
