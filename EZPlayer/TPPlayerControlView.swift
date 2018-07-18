//
//  TPPlayerControlView.swift
//  EZPlayer
//
//  Created by John on 2018/7/18.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit

class TPPlayerControlView: UIView {

    
    @IBOutlet weak var navBarContainer: UIView!
    @IBOutlet weak var navBarContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolBarContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var toolBarContainer: UIView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fullEmbeddedScreenButton: UIButton!
    @IBOutlet weak var fullEmbeddedScreenButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewImage: UIImageView!
    

}
