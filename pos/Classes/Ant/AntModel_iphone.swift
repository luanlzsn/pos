//
//  AntModel_iphone.swift
//  pos
//
//  Created by luan on 2017/5/14.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit
import MJExtension

class AntModel_iphone: NSObject {

}

class UserModel: AntModel_iphone {
    var account_custom_field = ""
    var address_id = 0
    var approved = 0
    var cart = [Any]()
    var code = ""
    var custom_fields = [String : Any]()
    var customer_group_id = 0
    var customer_id = 0
    var date_added = ""
    var email = ""
    var fax = ""
    var firstname = ""
    var ip = ""
    var language_id = 1
    var lastname = ""
    var newsvarter = 0
    var safe = 0
    var status = 0
    var store_id = 0
    var telephone = ""
    var wishlist = ""
}

class HomeShopModel: AntModel_iphone {
    var name = ""
    var store_id = -1
}
