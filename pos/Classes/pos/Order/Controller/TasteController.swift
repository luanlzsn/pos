//
//  TasteController.swift
//  pos
//
//  Created by luan on 2017/5/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class TasteController: AntController,UICollectionViewDelegate,UICollectionViewDataSource {

    @IBOutlet weak var tasteCollection: UICollectionView!
    @IBOutlet weak var tasteHeight: NSLayoutConstraint!
    @IBOutlet weak var selectCollection: UICollectionView!
    @IBOutlet weak var selectHeight: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    var tasteArray = [TasteModel]()
    var selectArray = [TasteModel]()
    var selectTaste: ConfirmBlock?
    
    deinit {
        selectTaste = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tasteHeight.constant = 0
        selectHeight.constant = 0
        getAllExtras()
    }
    
    @IBAction func cancelClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClick(_ sender: UIButton) {
        if selectArray.count == 0 {
            AntManage.showDelayToast(message: NSLocalizedString("请选择味道", comment: ""))
            return
        }
        if selectTaste != nil {
            var extraIdList = [Int]()
            for model in selectArray {
                extraIdList.append(model.tasteId)
            }
            selectTaste!(["ExtraIdList":extraIdList, "Special":textField.text!])
        }
        cancelClick()
    }
    
    func getAllExtras() {
        weak var weakSelf = self
        AntManage.postRequest(path: "tables/getAllExtras", params: ["status":"A", "access_token":AntManage.userModel!.token], successResult: { (response) in
            let array = response["data"] as! [[String : Any]]
            for dic in array {
                let model = TasteModel.mj_object(withKeyValues: dic["Extra"])!
                if model.category_id == 1 {
                    weakSelf?.tasteArray.append(model)
                }
            }
            let height = CGFloat(ceil(Double(weakSelf!.tasteArray.count) / 9.0) * 60.0 - 10.0)
            
            if height + 300 > kScreenHeight {
                weakSelf?.tasteHeight.constant = kScreenHeight - 300
            } else {
                weakSelf?.tasteHeight.constant = height
            }
            weakSelf?.tasteCollection.reloadData()
        }, failureResult: {
            weakSelf?.dismiss(animated: true, completion: nil)
        })
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionView == tasteCollection) ? tasteArray.count : selectArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TasteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TasteCell", for: indexPath) as! TasteCell
        let model: TasteModel!
        if collectionView == tasteCollection {
            model = tasteArray[indexPath.row]
        } else {
            model = selectArray[indexPath.row]
        }
        cell.tasteLabel.text = (LanguageManager.currentLanguageString() == "中文") ? model.name_zh : model.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tasteCollection {
            let model = tasteArray[indexPath.row]
            if !selectArray.contains(model) {
                selectArray.append(model)
            }
        } else {
            selectArray.remove(at: indexPath.row)
        }
        let height = CGFloat(ceil(Double(selectArray.count) / 9.0) * 60.0 - 10.0)
        if height + tasteHeight.constant + 250 > kScreenHeight {
            selectHeight.constant = kScreenHeight - tasteHeight.constant - 250
        } else {
            selectHeight.constant = height
        }
        selectCollection.reloadData()
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
