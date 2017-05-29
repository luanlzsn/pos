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

// MARK: 用户信息
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

// MARK: 订单信息
class OrderModel : AntModel {
    var orderId = 0//订单id
    var created = ""//创建时间
    var order_no = ""//订单号
    var order_type = ""//订单状态
    var table_no: NSNumber = 0//餐桌号
    var table_status = ""//餐桌状态
    var fix_discount = 0.0//固定折扣
    var percent_discount = 0//%的折扣
    var promocode = ""//优惠码
    var discount_value = 0.0//折扣值
    var after_discount = ""//折扣后
    var cashier_id = 0//收银员ID
    var change = 0.0//找零
    var cooking_status = ""//烹饪状态UNCOOKED
    var counter_id = 0//柜台的ID
    var hide_no = false//是否隐藏
    var is_completed = ""//是否完成N
    var is_hide = ""//P
    var is_kitchen = ""//是否厨房N
    var merge_id = 0//合并ID
    var message = ""
    var paid = false//是否支付
    var paid_by = ""
    var reason = ""//原因
    var reorder_no = false//
    var subtotal = 0.0//小计
    var tax = 0//税
    var tax_amount = 0.0//税额
    var total = 0.0//总计
    var tip = 0.0
    var tip_paid_by = ""
    var phone = ""//电话
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["orderId":"id"]
    }
}

class ExtraModel: AntModel {
    var extraId = 0
    var category_id = 0
    var price = ""
    var name = ""
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["extraId":"id"]
    }
}

// MARK: 已点菜单信息
class OrderItemModel : AntModel {
    var orderItemId = 0//id
    var all_extras = ""//所有额外
    var category_id = 0//类别ID
    var comb_id = 0
    var created = ""//创建时间
    var extras_amount = 0.0;//附加金额
    var is_done = ""//N是否完成
    var is_kitchen = ""//厨房
    var is_print = ""//打印
    var is_takeout = ""//是否外卖
    var item_id = 0//项目ID
    var name_en = ""//英文名
    var name_xh = ""//中文名
    var order_id = 0//订单id
    var price = ""//价格
    var qty = 0//数量
    var selected_extras = [ExtraModel]()//
    var tax = 0.0//税
    var tax_amount = ""//税额
    var special_instruction = ""//特殊说明
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["orderItemId":"id"]
    }
    
    override static func mj_objectClassInArray() -> [AnyHashable : Any]! {
        return ["selected_extras":ExtraModel.classForCoder()]
    }
}

// MARK: 菜单分类信息
class CategoryModel: AntModel {
    var categoryId = 0//id
    var en = ""//英文
    var zh = ""//中文
    var status = ""//状态
    var printer = ""//打印机
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["categoryId":"id"]
    }
}

// MARK: 菜信息
class CousineModel: AntModel {
    var cousineId = 0
    var en = ""//英文
    var zh = ""//中文
    var price = ""//价格
    var status = ""//状态
    var image = ""//图片
    var casier_id = 0
    var category_id = 0//菜单类别ID
    var comb_num = 0
    var is_tax = ""//是否有税
    var popular = 0
    var restaurant_id = 0//餐厅的ID
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["cousineId":"id"]
    }
}

// MARK: 味道信息
class TasteModel: AntModel {
    var category_id = 0//类别id
    var cousine_id = 0//
    var created = ""//创建时间
    var tasteId = 0//味道id
    var name = ""//英文名
    var name_zh = ""//中文名
    var price = 0.0//价格
    var status = ""//状态
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["tasteId":"id"]
    }
}
