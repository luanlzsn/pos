//
//  ForgetController.swift
//  pos
//
//  Created by luan on 2017/5/10.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class ForgetController: AntController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func uploadClick() {
        UIApplication.shared.keyWindow?.endEditing(true)
        if !Common.isValidateEmail(email: email.text!) {
            AntManage.showDelayToast(message: NSLocalizedString("请输入正确的邮箱地址！", comment: ""))
            return
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func alreadyRegisteredClick() {
        _ = navigationController?.popViewController(animated: true)
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
