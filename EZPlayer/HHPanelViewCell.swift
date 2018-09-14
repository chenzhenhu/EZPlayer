//
//  PanelViewCell.swift
//  EZPlayer
//
//  Created by 陈振虎 on 2018/9/14.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

class HHPanelViewCell: UITableViewCell {
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
