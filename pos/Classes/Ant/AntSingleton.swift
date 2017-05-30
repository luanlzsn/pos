//
//  LeomanSingleton.swift
//  MoFan
//
//  Created by luan on 2017/1/4.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

let kRequestTimeOut = 20.0
let AntManage = AntSingleton.sharedInstance

class AntSingleton: NSObject {
    
    static let sharedInstance = AntSingleton()
    var manager = AFHTTPSessionManager()
    var requestBaseUrl = "http://pos.auroraeducationonline.info/api/"
    var progress : MBProgressHUD?
    var progressCount = 0//转圈数量
    var isLogin = false//是否登录
    var userModel: UserModel?
    
    private override init () {
        manager.responseSerializer.acceptableContentTypes = Set(arrayLiteral: "application/json","text/json","text/javascript","text/html")
        manager.requestSerializer.timeoutInterval = kRequestTimeOut
    }
    
    //MARK: - post请求
    func postRequest(path:String, params:[String : Any]?, successResult:@escaping ([String : Any]) -> Void, failureResult:@escaping () -> Void) {
        AntLog(message: "请求接口：\(path),请求参数：\(String(describing: params))")
        showMessage(message: "")
        weak var weakSelf = self
        
        manager.post(requestBaseUrl + path, parameters: params, progress: nil, success: { (task, response) in
            weakSelf?.requestSuccess(response: response, successResult: successResult, failureResult: failureResult)
        }) { (task, error) in
            weakSelf?.hideMessage()
            weakSelf?.showDelayToast(message: "未知错误，请重试！")
            failureResult()
        }
    }
    
    //MARK: - get请求
    func getRequest(path:String, params:[String : Any]?, successResult:@escaping ([String : Any]) -> Void, failureResult:@escaping () -> Void) {
        AntLog(message: "请求接口：\(path),请求参数：\(String(describing: params))")
        showMessage(message: "")
        weak var weakSelf = self
        
        manager.get(requestBaseUrl + path, parameters: params, progress: nil, success: { (task, response) in
            weakSelf?.requestSuccess(response: response, successResult: successResult, failureResult: failureResult)
        }) { (task, error) in
            weakSelf?.hideMessage()
            weakSelf?.showDelayToast(message: "未知错误，请重试！")
            failureResult()
        }
    }
    
    //MARK: - 请求成功回调
    func requestSuccess(response: Any?, successResult:@escaping ([String : Any]) -> Void, failureResult:@escaping () -> Void) {
        AntLog(message: "接口返回数据：\(String(describing: response))")
        hideMessage()
        if let data = response as? [String : Any] {
            if let status = data["status"] {
                if status as! String == "success" {
                    if let success = data["data"] as? [String : Any] {
                        successResult(success)
                    } else {
                        successResult(data)
                    }
                } else {
                    if let error = data["data"] as? [String : Any] {
                        if let message = error["message"] as? String {
                            showDelayToast(message: message)
                        }
                    } else if let message = data["message"] as? String {
                        showDelayToast(message: message)
                    }
                    failureResult()
                }
            } else {
                failureResult()
            }
        } else {
            failureResult()
        }
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
            userModel = nil
            UserDefaults.standard.removeObject(forKey: kUserName)
            UserDefaults.standard.removeObject(forKey: kPassWord)
            UserDefaults.standard.synchronize()
            showDelayToast(message: NSLocalizedString("服务器地址变更，请重新登录！", comment: ""))
        }
    }
    
}
