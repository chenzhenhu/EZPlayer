//
//  RateViewCell.swift
//  EZPlayer
//
//  Created by John on 2018/9/14.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

class RateViewCell: UITableViewCell {
    
    var title: String? {
        didSet {
            guard let title = title else { return  }
            self.titleLabel.text = title
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
}
