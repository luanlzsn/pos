//
//  RegisterController.swift
//  pos
//
//  Created by luan on 2017/8/24.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

class RegisterController: AntController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createPasswordRightView(passwordField)
    }

    @IBAction func registerClick(_ sender: UIButton) {
        kWindow?.endEditing(true)
        if emailField.text!.isEmpty {
            AntManage.showDelayToast(message: NSLocalizedString("邮箱不能为空", comment: ""))
            return
        }
        if passwordField.text!.isEmpty {
            AntManage.showDelayToast(message: NSLocalizedString("密码不能为空", comment: ""))
            return
        }
        weak var weakSelf = self
        AntManage.iphonePostRequest(path: "route=rest/register/register", params: ["email":emailField.text!, "password":passwordField.text!, "firstname":"1", "lastname":"2", "confirm":passwordField.text!, "telephone":"18900000000", "city":"123", "address_1":"123", "country_id":"123", "zone_id":"1"], successResult: { (response) in
            AntManage.showDelayToast(message: NSLocalizedString("注册成功", comment: ""))
            AntManage.userModel = UserModel.mj_object(withKeyValues: response["data"])
            AntManage.isLogin = true
            UserDefaults.standard.set(weakSelf!.emailField.text!, forKey: kUserName)
            UserDefaults.standard.set(weakSelf!.passwordField.text!, forKey: kPassWord)
            UserDefaults.standard.synchronize()
            weakSelf?.dismiss(animated: true, completion: nil)
        }, failureResult: {})
    }
    
    @IBAction func backLoginClick(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func checkPassword(_ button: UIButton) {
        button.isSelected = !button.isSelected
        passwordField.isSecureTextEntry = !button.isSelected
    }
    
    func createPasswordRightView(_ textField: UITextField) {
        let rightBtn = UIButton(type: .custom)
        rightBtn.setImage(UIImage(named: "hide_password"), for: .normal)
        rightBtn.setImage(UIImage(named: "show_password"), for: .selected)
        rightBtn.frame = CGRect(x: 0, y: 0, width: textField.height, height: textField.height)
        rightBtn.addTarget(self, action: #selector(checkPassword(_:)), for: .touchUpInside)
        textField.rightView = rightBtn
        textField.rightViewMode = .always
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
