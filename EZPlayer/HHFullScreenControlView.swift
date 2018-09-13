//
//  HHFullScreenControlView.swift
//  EZPlayer
//
//  Created by John on 2018/9/13.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

class HHFullScreenControlView: UIView {

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topBarMaskView: UIImageView!
    @IBOutlet weak var exitFullScreenButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var bottomBarMaskView: UIImageView!
    @IBOutlet weak var playOrPauseButton: UIButton!
    @IBOutlet weak var resolutionButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var selectionsButton: UIButton!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var seekToLabel: UILabel!
}
