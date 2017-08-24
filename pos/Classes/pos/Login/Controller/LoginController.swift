//
//  LoginController.swift
//  pos
//
//  Created by luan on 2017/5/7.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class LoginController: AntController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
        if (UserDefaults.standard.object(forKey: kUserName) != nil) {
            userName.text = UserDefaults.standard.object(forKey: kUserName) as? String
            passWord.text = UserDefaults.standard.object(forKey: kPassWord) as? String
            loginClick()
        }
    }
    
    @IBAction func loginClick() {
        UIApplication.shared.keyWindow?.endEditing(true)
        if !Common.isValidateEmail(email: userName.text!) {
            AntManage.showDelayToast(message: NSLocalizedString("请输入正确的邮箱地址！", comment: ""))
            return
        }
        if (passWord.text?.isEmpty)! {
            AntManage.showDelayToast(message: NSLocalizedString("请输入密码", comment: ""))
            return
        }
        weak var weakSelf = self
        AntManage.postRequest(path: "access/generateToken", params: ["email":userName.text!,"password":passWord.text!], successResult: { (response) in
            AntManage.userModel = UserModel.mj_object(withKeyValues: response["Api"])
            AntManage.isLogin = true
            UserDefaults.standard.set(weakSelf?.userName.text, forKey: kUserName)
            UserDefaults.standard.set(weakSelf?.passWord.text, forKey: kPassWord)
            UserDefaults.standard.synchronize()
            AntManage.showDelayToast(message: NSLocalizedString("登录成功！", comment: ""))
            weakSelf?.dismiss(animated: true, completion: nil)
        }, failureResult: {
            AntManage.showDelayToast(message: NSLocalizedString("用户名或密码错误", comment: ""))
        })
    }
    
    @IBAction func checkInClick(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("签入", comment: ""), message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: ""), style: .default, handler: { (_) in
            AntLog(message: alert.textFields?.first?.text)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
