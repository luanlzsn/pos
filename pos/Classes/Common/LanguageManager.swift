//
//  LanguageManager.swift
//  Traber
//
//  Created by luan on 2017/4/29.
//  Copyright © 2017年 luan. All rights reserved.
//

import UIKit

let LanguageSaveKey = "CurrentLanguageKey"

class LanguageManager: NSObject {
    
    class func setupCurrentLanguage() {
        var currentLanguage = UserDefaults.standard.object(forKey: LanguageSaveKey)
        if currentLanguage == nil {
            currentLanguage = "en"
            UserDefaults.standard.set(currentLanguage, forKey: LanguageSaveKey)
            UserDefaults.standard.synchronize()
        }
        Bundle.setLanguage(currentLanguage as! String)
    }
    
    class func currentLanguageString() -> String {
        return UserDefaults.standard.object(forKey: LanguageSaveKey) as! String
    }
    
    class func saveLanguage(languageString: String) {
        UserDefaults.standard.set(languageString, forKey: LanguageSaveKey)
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(languageString)
    }
    
}

