//
//  CCCPlayerEmbeddedControlView.swift
//  EZPlayer
//
//  Created by John on 2018/9/12.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit
import SnapKit

open class HHHPlayerEmbeddedControlView: UIView {
    
    public weak var player: EZPlayer? {
        didSet {
            guard let player = player else {
                return
            }
            player.setControlsHidden(true, animated: true)
        }
    }
    
    private lazy var topBarView: UIView = {
        return UIView()
    }()
    
    private lazy var topBarMaskView: UIImageView = {
        return UIImageView(image: UIImage.bundleImage(named: "player_mask_top"))
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .left
        return titleLabel
    }()
    
    private lazy var bottomBarView: UIView = {
        return UIView()
    }()
    
    private lazy var bottomBarMaskView: UIImageView = {
        return UIImageView(image: UIImage.bundleImage(named: "player_mask_bottom"))
    }()
    
    private lazy var playTimeLabel: UILabel = {
        let playTimeLabel = UILabel()
        playTimeLabel.font = UIFont.systemFont(ofSize: 12)
        playTimeLabel.text = "00:00"
        playTimeLabel.textColor = UIColor.white
        playTimeLabel.textAlignment = .center
        return playTimeLabel
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let totalTimeLabel = UILabel()
        totalTimeLabel.font = UIFont.systemFont(ofSize: 12)
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textColor = UIColor.white
        totalTimeLabel.textAlignment = .center
        return totalTimeLabel
    }()
    
    private lazy var progressSlider: UISlider = {
        let progressSlider = UISlider()
        progressSlider.value = 0
        progressSlider.minimumValue = 0
        progressSlider.isContinuous = false
        progressSlider.minimumTrackTintColor = UIColor.clear
        progressSlider.setThumbImage(UIImage.bundleImage(named: "fullplayer_progress_point"), for: .normal)
        return progressSlider
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = UIColor.white
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.33)
        return progressView
    }()
    
    private lazy var enterFullScreenButton: UIButton = {
        let fullScreenButton = UIButton()
        fullScreenButton.tintColor = UIColor.white
        fullScreenButton.setImage(UIImage.bundleImage(named: "player_icon_fullscreen"), for: .normal)
        return fullScreenButton
    }()
    
    private lazy var coverImageView: UIImageView = {
        return UIImageView()
    }()
    
    private lazy var centerPlayOrPauseButton: UIButton = {
        let centerPlayOrPauseButton = UIButton()
        centerPlayOrPauseButton.tintColor = UIColor.white
        centerPlayOrPauseButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        centerPlayOrPauseButton.setImage(UIImage.bundleImage(named: "player_icon_play"), for: .normal)
        centerPlayOrPauseButton.clipsToBounds = true
        centerPlayOrPauseButton.layer.cornerRadius = 25
        return centerPlayOrPauseButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// MARK: UI 设置
extension HHHPlayerEmbeddedControlView {
    
    fileprivate func setupUI() {
        self.addSubview(self.topBarView)
        self.topBarView.addSubview(self.topBarMaskView);
        self.topBarView.addSubview(self.titleLabel)
        self.addSubview(self.bottomBarView)
        self.bottomBarView.addSubview(self.bottomBarMaskView)
        self.bottomBarView.addSubview(self.playTimeLabel)
        self.bottomBarView.addSubview(self.progressView)
        self.bottomBarView.addSubview(self.progressSlider)
        self.bottomBarView.addSubview(self.totalTimeLabel)
        self.bottomBarView.addSubview(self.enterFullScreenButton)
        self.addSubview(self.coverImageView)
        self.addSubview(centerPlayOrPauseButton)

        self.topBarView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(44)
        }

        self.topBarMaskView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.topBarView)
        }

        self.titleLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self.topBarView)
        }

        self.bottomBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(50)
        }

        self.bottomBarMaskView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.bottomBarView)
        }

        self.playTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.left.equalTo(self.bottomBarView)
            make.width.equalTo(50)
        }

        self.enterFullScreenButton.snp.makeConstraints { (make) in
            make.top.bottom.right.equalTo(self.bottomBarView)
            make.width.equalTo(40)
        }

        self.totalTimeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(self.bottomBarView)
            make.right.equalTo(self.enterFullScreenButton.snp.left)
            make.width.equalTo(50)
        }

        self.progressSlider.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.bottomBarView)
            make.left.equalTo(self.playTimeLabel.snp.right).offset(2)
            make.right.equalTo(self.totalTimeLabel.snp.left).offset(-2)
        }

        self.progressView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.progressSlider)
            make.centerY.equalTo(self.progressSlider).offset(0.5)
        }

        self.coverImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }

        self.centerPlayOrPauseButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(50)
        }
    }
}
