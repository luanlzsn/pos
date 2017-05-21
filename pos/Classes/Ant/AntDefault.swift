//
//  LeomanDefault.swift
//  MoFan
//
//  Created by luan on 2016/12/8.
//  Copyright © 2016年 luan. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import YYCategories

func AntLog<N>(message:N,fileName:String = #file,methodName:String = #function,lineNumber:Int = #line){
    #if DEBUG
        print("类\(fileName as NSString)的\(methodName)方法第\(lineNumber)行:\(message)");
    #endif
}

let kWindow = UIApplication.shared.keyWindow
let kScreenBounds = UIScreen.main.bounds
let kScreenWidth = kScreenBounds.width
let kScreenHeight = kScreenBounds.height
let MainColor = Common.colorWithHexString(colorStr: "80D3CB")
let LeomanManager = AntSingleton.sharedInstance
let kIphone4 = kScreenHeight == 480
let kIpad = UIDevice.current.userInterfaceIdiom == .pad
let kAppDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
let kAppVersion_URL = "http://itunes.apple.com/lookup?id=1107512125"//获取版本信息
let kAppDownloadURL = "https://itunes.apple.com/cn/app/id1107512125"//下载地址

let kUserName = "kUserName"
let kPassWord = "kPassWord"


struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

typealias ConfirmBlock = (_ value: Any) ->()
typealias CancelBlock = () ->()

