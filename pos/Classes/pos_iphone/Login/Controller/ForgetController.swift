//
//  ForgetController.swift
//  pos
//
//  Created by luan on 2017/8/24.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ForgetController: AntController {

    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func resetClick(_ sender: UIButton) {
        kWindow?.endEditing(true)
        if emailField.text!.isEmpty {
            AntManage.showDelayToast(message: NSLocalizedString("邮箱不能为空", comment: ""))
            return
        }
        weak var weakSelf = self
        AntManage.iphonePostRequest(path: "route=rest/forgotten/forgotten", params: ["email":emailField.text!], successResult: { (_) in
            AntManage.showDelayToast(message: NSLocalizedString("密码已发至邮箱，请查收！", comment: ""))
            weakSelf?.navigationController?.popViewController(animated: true)
        }, failureResult: {})
    }
    
    @IBAction func backLoginClick(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
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
