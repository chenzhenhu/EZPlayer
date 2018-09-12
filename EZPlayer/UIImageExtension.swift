//
//  BundleExtension.swift
//  EZPlayer
//
//  Created by John on 2018/9/12.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

extension UIImage {

    class func bundleImage(named: String) -> UIImage? {
        return UIImage(named: named, in: Bundle(path: "EZPlayer.bundle"), compatibleWith: nil)
    }
}
