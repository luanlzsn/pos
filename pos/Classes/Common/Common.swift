//
//  Common.swift
//  MoFan
//
//  Created by luan on 2016/12/8.
//  Copyright © 2016年 luan. All rights reserved.
//

import UIKit
import YYCategories

class Common: NSObject {
    
    //MARK: - 根据十六进制颜色值获取颜色
    class func colorWithHexString(colorStr:String) -> UIColor {
        var color = UIColor.red
        var cStr : String = colorStr.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if cStr.hasPrefix("#") {
            let index = cStr.index(after: cStr.startIndex)
            cStr = cStr.substring(from: index)
        }
        if cStr.characters.count != 6 {
            return UIColor.black
        }
        //两种不同截取字符串的方法
        let rRange = cStr.startIndex ..< cStr.index(cStr.startIndex, offsetBy: 2)
        let rStr = cStr.substring(with: rRange)
        
        let gRange = cStr.index(cStr.startIndex, offsetBy: 2) ..< cStr.index(cStr.startIndex, offsetBy: 4)
        let gStr = cStr.substring(with: gRange)
        
        let bIndex = cStr.index(cStr.endIndex, offsetBy: -2)
        let bStr = cStr.substring(from: bIndex)
        
        color = UIColor.init(colorLiteralRed: Float(changeToInt(numStr: rStr)) / 255, green: Float(changeToInt(numStr: gStr)) / 255, blue: Float(changeToInt(numStr: bStr)) / 255, alpha: 1)
        return color
    }
    
    class func changeToInt(numStr: String) -> Int {
        
        let str = numStr.uppercased()
        var sum = 0
        for i in str.utf8 {
            //0-9 从48开始
            sum = sum * 16 + Int(i) - 48
            if i >= 65 {
                //A~Z 从65开始，但初始值为10
                sum -= 7
            }
        }
        return sum
    }
    
    //MARK: - 中文转拼音
    class func chineseToPinyin(chinese: String) -> String {
        let mutableString = NSMutableString(string: chinese)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        return mutableString.replacingOccurrences(of: " ", with: "")
    }
    
    // MARK: - 校验手机号
    class func isValidateMobile(mobile: String) -> Bool {
        do {
            let pattern = "^((13[0-9])|(15[^4,\\D])|(17[0,0-9])|(18[0,0-9]))\\d{8}$"
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.numberOfMatches(in: mobile, options: [.reportProgress], range: NSMakeRange(0, mobile.characters.count))
            return matches > 0
        }
        catch {
            return false
        }
    }
    
    // MARK: - 校验邮箱
    class func isValidateEmail(email: String) -> Bool {
        do {
            let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-_]+\\.[A-Za-z]{2,4}"
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.numberOfMatches(in: email, options: [.reportProgress], range: NSMakeRange(0, email.characters.count))
            return matches > 0
        }
        catch {
            return false
        }
    }
    
    // MARK: - 校验邮箱
    class func isValidateURL(urlStr: String) -> Bool {
        do {
            let pattern = "http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?"
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.numberOfMatches(in: urlStr, options: [.reportProgress], range: NSMakeRange(0, urlStr.characters.count))
            return matches > 0
        }
        catch {
            return false
        }
    }
    
    // MARK: - 校验数字
    class func isValidateNumber(numberStr: String) -> Bool {
        do {
            let pattern = "^[0-9]*$"
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let matches = regex.numberOfMatches(in: numberStr, options: [.reportProgress], range: NSMakeRange(0, numberStr.characters.count))
            return matches > 0
        }
        catch {
            return false
        }
    }
    
    //MARK: - 将字符串根据格式转换为日期
    class func obtainDateWithStr(str: String, formatterStr: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = formatterStr
        let date = formatter.date(from: str)
        return (date != nil) ? date! : Date()
    }
    
    //MARK: - 根据日期和格式获取字符串
    class func obtainStringWithDate(date: Date, formatterStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatterStr
        return formatter.string(from: date)
    }
    
    //MARK: - md5加密
    class func md5String(str:String) -> String {
        let cStr = str.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
    
    // MARK: 根据属性对对象数组进行排序
    class func sortArray(array: [Any], descriptor: String, ascending: Bool) -> [Any] {
        let sortDescriptor = NSSortDescriptor.init(key: descriptor, ascending: ascending)
        return (array as NSArray).sortedArray(using: [sortDescriptor])
    }
    
    //MARK: - 需要登录之后才能执行的操作判断是否可以操作，返回YES可以继续操作，否则自动跳转到登录
    class func checkIsOperation(controller : UIViewController) -> Bool {
        if LeomanManager.isLogin {
            return true
        } else {
            let storyboard = UIStoryboard(name: "Login", bundle: Bundle.main)
            let login = storyboard.instantiateInitialViewController()
            controller.present(login!, animated: true, completion: nil)
            return false
        }
    }
    
    //MARK: - 永久闪烁的动画
    class func opacityForeverAnimation(time: Float) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.autoreverses = true
        animation.duration = CFTimeInterval(time)
        animation.repeatCount = MAXFLOAT
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)//没有的话是均匀的动画。
        return animation;
    }
    
    //MARK: - 是否是中文
    class func isIncludeChineseIn(string: String) -> Bool {
        for (_, value) in string.characters.enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }
    
    //MARK: - 校验是否是空字符串
    class func isBlankString(str: String?) -> Bool {
        if str == nil || str!.isEmpty {
            return true
        }
        if str!.trimmingCharacters(in: NSCharacterSet.controlCharacters).isEmpty {
            return true
        }
        return false
    }
    
}

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor {
        get {
            return self.borderColor
        }
        set {
            layer.borderColor = newValue.cgColor
        }
    }
}

extension UITextField {
    @IBInspectable
    var leftImage: UIImage {
        get {
            return self.leftImage
        }
        set {
            let imgView = UIImageView(image: newValue)
            imgView.contentMode = .right
            imgView.frame = CGRect(x: 0, y: 0, width: newValue.size.width + 8, height: height)
            leftView = imgView
            leftViewMode = .always
        }
    }
}
