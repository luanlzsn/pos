//
//  MergeBillController.swift
//  pos
//
//  Created by luan on 2017/5/30.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class MergeBillController: AntController {
    
    var orderIdArray = [Int]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

//        getMergeBillInfo()
    }
    
    func getMergeBillInfo() {
        weak var weakSelf = self
        AntManage.postRequest(path: "print/printMergeBill", params: ["restaurant_id":AntManage.userModel!.restaurant_id, "order_ids":orderIdArray, "access_token":AntManage.userModel!.token], successResult: { (response) in
            
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
