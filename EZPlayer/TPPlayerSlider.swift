//
//  TPPlayerSlider.swift
//  EZPlayer
//
//  Created by John on 2018/7/19.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

class TPPlayerSlider: UISlider {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setThumbImage(UIImage(named: "silder_point"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
