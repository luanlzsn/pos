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
    @IBOutlet weak var comboTitle: UILabel!
    @IBOutlet weak var comboCollection: UICollectionView!
    @IBOutlet weak var comboHeight: NSLayoutConstraint!
    @IBOutlet weak var comboBottom: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    var tasteArray = [TasteModel]()
    var selectArray = [TasteModel]()
    var comboArray = [TasteModel]()
    var selectTaste: ConfirmBlock?
    var existingTasteIdArray = [Int]()//现有的口味id
    var combId = 0
    var instructions = ""//特别说明
    var combNum = 0
    
    
    deinit {
        selectTaste = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tasteHeight.constant = 0
        selectHeight.constant = 0
        textField.text = instructions
        if combId == 0 {
            comboTitle.isHidden = true
            comboHeight.constant = 0
            comboBottom.constant = -30
        } else {
            comboTitle.isHidden = false
            comboBottom.constant = 10
        }
        getAllExtraCategories()
        getAllExtras()
    }
    
    @IBAction func cancelClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveClick(_ sender: UIButton) {
        if combId != 0 && comboArray.count != combNum {
            AntManage.showDelayToast(message: NSLocalizedString("请选择", comment: "") + "\(combNum)" + NSLocalizedString("种拼盘", comment: ""))
            return
        }
        if selectTaste != nil {
            var extraIdList = [Int]()
            for model in selectArray {
                extraIdList.append(model.tasteId)
            }
            for model in comboArray {
                extraIdList.append(model.tasteId)
            }
            selectTaste!(["ExtraIdList":extraIdList, "Special":textField.text!])
        }
        cancelClick()
    }
    
    func getAllExtraCategories() {
        weak var weakSelf = self
        AntManage.postRequest(path: "tables/getAllExtraCategories", params: ["status":"A", "access_token":AntManage.userModel!.token], successResult: { (response) in
            let array = response["data"] as! [[String : Any]]
            for dic in array {
                let model = ExtraCategoryModel.mj_object(withKeyValues: dic["Extrascategory"])!
                if model.categoryId == ((weakSelf?.combId == 0) ? 1 : weakSelf!.combId) {
                    weakSelf?.combNum = model.extras_num
                    return
                }
            }
        }, failureResult: {})
    }
    
    func getAllExtras() {
        weak var weakSelf = self
        AntManage.postRequest(path: "tables/getAllExtras", params: ["status":"A", "access_token":AntManage.userModel!.token], successResult: { (response) in
            let array = response["data"] as! [[String : Any]]
            var allExtra = [TasteModel]()
            for dic in array {
                let model = TasteModel.mj_object(withKeyValues: dic["Extra"])!
                allExtra.append(model)
                if model.category_id == ((weakSelf?.combId == 0) ? 1 : weakSelf!.combId) {
                    weakSelf?.tasteArray.append(model)
                }
            }
            var height = CGFloat(ceil(Double(weakSelf!.tasteArray.count) / 9.0) * 60.0 - 10.0)
            if weakSelf?.combId != 0 {
                height += (weakSelf!.comboArray.count > 0) ? 90 : 20
            }
            if height + 300 > kScreenHeight {
                weakSelf?.tasteHeight.constant = kScreenHeight - 300
            } else {
                weakSelf?.tasteHeight.constant = height
            }
            weakSelf?.tasteCollection.reloadData()
            weakSelf?.checkExistingTaste(allExtra: allExtra)
        }, failureResult: {
            weakSelf?.dismiss(animated: true, completion: nil)
        })
    }
    
    func checkExistingTaste(allExtra: [TasteModel]) {
        if existingTasteIdArray.count > 0 {
            for model in allExtra {
                if existingTasteIdArray.contains(model.tasteId) {
                    if model.category_id == 1 {
                        selectArray.append(model)
                    } else {
                        comboArray.append(model)
                    }
                }
            }
        }
        checkSelectCollectionHeight()
    }
    
    func checkSelectCollectionHeight() {
        let height = CGFloat(ceil(Double(selectArray.count) / 9.0) * 60.0 - 10.0)
        var changeHeight: CGFloat = 0.0
        if combId != 0 {
            comboHeight.constant = (comboArray.count > 0) ? 50 : 0
            changeHeight = 40.0
        }
        if height + tasteHeight.constant + 250 + comboHeight.constant + changeHeight > kScreenHeight {
            selectHeight.constant = kScreenHeight - tasteHeight.constant - 250 - comboHeight.constant - changeHeight
        } else {
            selectHeight.constant = height
        }
        selectCollection.reloadData()
        comboCollection.reloadData()
    }
    
    // MARK: UICollectionViewDelegate,UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tasteCollection {
            return tasteArray.count
        } else if collectionView == selectCollection {
            return selectArray.count
        } else {
            return comboArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TasteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TasteCell", for: indexPath) as! TasteCell
        let model: TasteModel!
        if collectionView == tasteCollection {
            model = tasteArray[indexPath.row]
        } else if collectionView == selectCollection {
            model = selectArray[indexPath.row]
        } else {
            model = comboArray[indexPath.row]
        }
        cell.tasteLabel.text = (LanguageManager.currentLanguageString() == "zh-Hans") ? model.name_zh : model.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == tasteCollection {
            let model = tasteArray[indexPath.row]
            if combId == 0 {
                selectArray.append(model)
            } else {
                if comboArray.count >= combNum {
                    return
                }
                comboArray.append(model)
            }
        } else if collectionView == selectCollection {
            selectArray.remove(at: indexPath.row)
        } else {
            comboArray.remove(at: indexPath.row)
        }
        checkSelectCollectionHeight()
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
