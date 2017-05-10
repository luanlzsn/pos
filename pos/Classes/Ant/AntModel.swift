//
//  AntModel.swift
//  pos
//
//  Created by luan on 2017/5/10.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit
import MJExtension

class AntModel: NSObject {

}

class UserModel: AntModel {
    var userId = 0
    var email = ""//邮箱/账号
    var password = ""//密码
    var ip = ""//ip
    var created = ""//创建时间
    var modified = ""//修改时间
    var token = ""//token
    var cashier_id = 0//收银员ID
    var restaurant_id = 0//餐厅ID
    
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["userId":"id"]
    }
}
