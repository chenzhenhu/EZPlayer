//
//  RateModel.swift
//  EZPlayer
//
//  Created by 陈振虎 on 2018/9/15.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

struct RateModel {
    var title: String?
    var rate: Float = 1
}

open class SelectionsModel: NSObject {
    var title: String?
    var id: String?
    var url: String?
    
    convenience public init(dict: [String: Any]) {
        self.init()
        setValuesForKeys(dict)
    }
    
    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
}
