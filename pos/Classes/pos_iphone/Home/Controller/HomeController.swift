//
//  HomeController.swift
//  pos
//
//  Created by luan on 2017/6/5.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class HomeController: AntController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collection: UICollectionView!
    var shopArray = [HomeShopModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !AntManage.isLogin {
            let loginNav = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()
            present(loginNav!, animated: true, completion: nil)
        } else if shopArray.count == 0 {
            weak var weakSelf = self
            AntManage.iphoneGetRequest(path: "route=feed/rest_api/stores", params: nil, successResult: { (response) in
                weakSelf?.shopArray = HomeShopModel.mj_objectArray(withKeyValuesArray: response["data"]) as! [HomeShopModel]
                weakSelf?.collection.reloadData()
            }, failureResult: {})
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (kScreenWidth - 30) / 2.0
        return CGSize(width: cellWidth, height: cellWidth + 40)
    }
    
    // MARK: - UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HomeShopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeShopCell", for: indexPath) as! HomeShopCell
        let model = shopArray[indexPath.row]
        cell.shopName.text = model.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
