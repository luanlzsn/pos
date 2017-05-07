//
//  LeomanSingleton.swift
//  MoFan
//
//  Created by luan on 2017/1/4.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit
import MBProgressHUD

let kRequestTimeOut = 10.0
let AntManage = AntSingleton.sharedInstance

class AntSingleton: NSObject {
    
    static let sharedInstance = AntSingleton()
    var progress : MBProgressHUD?
    var progressCount = 0//转圈数量
    var requestBaseUrl = "http://pos.auroraeducationonline.info/api/"
    var isLogin = false//是否登录
    
    private override init () {
        
    }
    
    
    // MARK: - 显示提示
    func showMessage(message : String) {
        if progress == nil {
            progressCount = 0
            progress = MBProgressHUD.showAdded(to: kWindow!, animated: true)
            progress?.label.text = message
        }
        progressCount += 1
    }
    
    // MARK: - 隐藏提示
    func hideMessage() {
        progressCount -= 1
        if progressCount < 0 {
            progressCount = 0
        }
        if (progress != nil) && progressCount == 0 {
            progress?.hide(animated: true)
            progress?.removeFromSuperview()
            progress = nil
        }
    }
    
    // MARK: - 显示固定时间的提示
    func showDelayToast(message : String) {
        let hud = MBProgressHUD.showAdded(to: kWindow!, animated: true)
        hud.detailsLabel.text = message
        hud.mode = .text
        hud.hide(animated: true, afterDelay: 2)
    }
    
    // MARK: - 校验默认请求地址
    func checkBaseRequestAddress() {
        let baseRequestAddress = UserDefaults.standard.object(forKey: "BaseRequestAddress")
        AntLog(message: baseRequestAddress)
        let beforeUrl = requestBaseUrl
        if let address = baseRequestAddress as? String {
            if Common.isValidateURL(urlStr: address) {
                if address.hasSuffix("/") {
                    requestBaseUrl = address + "api/"
                } else {
                    requestBaseUrl = address + "/api/"
                }
            }
        }
        if beforeUrl != requestBaseUrl {
            UserDefaults.standard.removeObject(forKey: kUserName)
            UserDefaults.standard.removeObject(forKey: kPassWord)
            UserDefaults.standard.synchronize()
            showDelayToast(message: NSLocalizedString("服务器地址变更，请重新登录！", comment: ""))
        }
    }
    
}
