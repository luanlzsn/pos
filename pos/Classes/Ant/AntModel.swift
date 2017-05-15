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

//订单信息
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
    var tax_amount = 0//税额
    var total = 0.0//总计
    var tip = 0.0
    var tip_paid_by = ""
    
    override static func mj_replacedKeyFromPropertyName() -> [AnyHashable : Any]! {
        return ["orderId":"id"]
    }
    
}
