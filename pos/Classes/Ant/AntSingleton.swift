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
    var requestBaseUrl = (UIDevice.current.userInterfaceIdiom == .pad) ? "http://pos.auroraeducationonline.info/api/" : "http://posonline.auroraeducationonline.info/index.php?"
    var progress : MBProgressHUD?
    var progressCount = 0//转圈数量
    var isLogin = false//是否登录
    var userModel: UserModel?
    var iphoneToken = ""
    
    private override init () {
        if UIDevice.current.userInterfaceIdiom == .phone {
            manager.requestSerializer = AFJSONRequestSerializer()
            manager.requestSerializer.httpMethodsEncodingParametersInURI = Set.init(arrayLiteral: "GET", "HEAD")
        }
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
    
    //MARK: - iphone post请求
    func iphonePostRequest(path:String, params:[String : Any]?, successResult:@escaping ([String : Any]) -> Void, failureResult:@escaping () -> Void) {
        AntLog(message: "请求接口：\(path),请求参数：\(String(describing: params))")
        if path != "route=feed/rest_api/gettoken&grant_type=client_credentials" {
            showMessage(message: "")
        }
        
        weak var weakSelf = self

        if iphoneToken.isEmpty {
            manager.requestSerializer.setValue("Basic cG9zb25saW5lOlBvTCMxMjA5", forHTTPHeaderField: "Authorization")
        } else {
            manager.requestSerializer.setValue("BEARER \(iphoneToken)", forHTTPHeaderField: "Authorization")
        }
        manager.requestSerializer.setValue((LanguageManager.currentLanguageString() == "en") ? "en" : "zh", forHTTPHeaderField: "Accept-Language")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.httpShouldHandleCookies = false
        manager.post(requestBaseUrl + path, parameters: params, progress: nil, success: { (task, response) in
            weakSelf?.iphoneRequestSuccess(response: response, successResult: successResult, failureResult: failureResult)
        }) { (task, error) in
            if path != "route=feed/rest_api/gettoken&grant_type=client_credentials" {
                weakSelf?.iphoneRequestFail(error: error, failureResult: failureResult)
            }
        }
    }
    
    //MARK: - iphone get请求
    func iphoneGetRequest(path:String, params:[String : Any]?, successResult:@escaping ([String : Any]) -> Void, failureResult:@escaping () -> Void) {
        AntLog(message: "请求接口：\(path),请求参数：\(String(describing: params))")
        showMessage(message: "")
        weak var weakSelf = self
        
        if iphoneToken.isEmpty {
            manager.requestSerializer.setValue("Basic cG9zb25saW5lOlBvTCMxMjA5", forHTTPHeaderField: "Authorization")
        } else {
            manager.requestSerializer.setValue("BEARER \(iphoneToken)", forHTTPHeaderField: "Authorization")
        }
        manager.requestSerializer.setValue((LanguageManager.currentLanguageString() == "en") ? "en" : "zh", forHTTPHeaderField: "Accept-Language")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.httpShouldHandleCookies = false
        manager.get(requestBaseUrl + path, parameters: params, progress: nil, success: { (task, response) in
            weakSelf?.iphoneRequestSuccess(response: response, successResult: successResult, failureResult: failureResult)
        }) { (task, error) in
            weakSelf?.iphoneRequestFail(error: error, failureResult: failureResult)
        }
    }
    
    //MARK: - iphone get请求
    func iphoneDeleteRequest(path:String, params:[String : Any]?, successResult:@escaping ([String : Any]) -> Void, failureResult:@escaping () -> Void) {
        AntLog(message: "请求接口：\(path),请求参数：\(String(describing: params))")
        showMessage(message: "")
        weak var weakSelf = self
        
        if iphoneToken.isEmpty {
            manager.requestSerializer.setValue("Basic cG9zb25saW5lOlBvTCMxMjA5", forHTTPHeaderField: "Authorization")
        } else {
            manager.requestSerializer.setValue("BEARER \(iphoneToken)", forHTTPHeaderField: "Authorization")
        }
        manager.requestSerializer.setValue((LanguageManager.currentLanguageString() == "en") ? "en" : "zh", forHTTPHeaderField: "Accept-Language")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.httpShouldHandleCookies = false
        manager.delete(requestBaseUrl + path, parameters: params, success: { (task, response) in
            weakSelf?.iphoneRequestSuccess(response: response, successResult: successResult, failureResult: failureResult)
        }) { (task, error) in
            weakSelf?.iphoneRequestFail(error: error, failureResult: failureResult)
        }
    }
    
    //MARK: - 请求成功回调
    func iphoneRequestSuccess(response: Any?, successResult:@escaping ([String : Any]) -> Void, failureResult:@escaping () -> Void) {
        AntLog(message: "接口返回数据：\(String(describing: response))")
        hideMessage()
        if let data = response as? [String : Any] {
            if let success = data["success"] as? Bool {
                if success {
                    successResult(data)
                } else {
                    failureResult()
                    if let error = data["error"] as? [String : Any] {
                        for value in error.values {
                            if let message = value as? String {
                                showDelayToast(message: message)
                            }
                        }
                    } else if let error = data["error"] as? String {
                        showDelayToast(message: error)
                    }
                }
            } else {
                successResult(data)
            }
        } else {
            failureResult()
        }
    }
    
    // MARK: - iPhone请求错误回调
    func iphoneRequestFail(error: Error, failureResult:@escaping () -> Void) {
        hideMessage()
        failureResult()
        if let responseData = (error as NSError).userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] as? Data {
            if let responseDict = try! JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String : Any] {
                if let errorArray = responseDict["error"] as? [String] {
                    if let errorStr = errorArray.first {
                        showDelayToast(message: errorStr)
                        return
                    }
                }
            }
        }
        AntManage.showDelayToast(message: NSLocalizedString("未知错误，请重试！", comment: ""))
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
    func checkBaseRequestAddress(isStartUp: Bool) {
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
        if beforeUrl != requestBaseUrl, !isStartUp {
            NotificationCenter.default.post(name: NSNotification.Name("RequestAddressUpdate"), object: nil)
        }
    }
    
}
