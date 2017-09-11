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

class CategoriesModel: AntModel_iphone {
    var categories = ""
    var category_id = 0
    var filters = [String : Any]()
    var image = ""
    var name = ""
    var original_image = ""
    var parent_id = -1
}

class OptionItemModel: AntModel_iphone {
    var name = ""
    var image = ""
    var option_value_id = 0
    var price = 0
    var price_excluding_tax = "0.00"
    var price_formated = "$0.00"
    var price_prefix = "0.00"
    var product_option_value_id = 0
    var quantity = 0
    var isSelect = false
}

class OptionModel: AntModel_iphone {
    var name = ""
    var option_id = 0
    var product_option_id = 0
    var required = false
    var type = ""
    var value = ""
    var option_value = [OptionItemModel]()
    var isSelect = false
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["option_value":OptionItemModel.classForCoder()]
    }
}

class ProductModel: AntModel_iphone {
    var desc = ""
    var discounts = [Any]()
    var name = ""
    var price = "0.00"
    var price_excluding_tax = "0.00"
    var price_formated = "$0.00"
    var product_id = 0
    var productId = 0
    var rating = 0
    var special = 0.0
    var special_excluding_tax = "0.00"
    var special_formated = "0.00"
    var thumb = ""
    var image = ""
    var quantity = 0
    var options = [OptionModel]()
    var option = [OptionModel]()
    var key = 0
    var model = ""
    var total = ""
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["desc":"description", "productId":"id"]
    }
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["options":OptionModel.classForCoder(), "option":OptionModel.classForCoder()]
    }
    
}

class TotalModel: AntModel_iphone {
    var text = ""
    var title = ""
    var value = ""
}

class ShopCartModel: AntModel_iphone {
    var products = [ProductModel]()
    var reward = ""
    var reward_status = 0
    var total = ""
    var total_product_count = 0
    var total_raw = ""
    var voucher = ""
    var voucher_status = 0
    var totals = [TotalModel]()
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["products":ProductModel.classForCoder(), "totals":TotalModel.classForCoder()]
    }
    
}
