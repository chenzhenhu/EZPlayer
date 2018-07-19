//
//  TPPlayerControlView.swift
//  EZPlayer
//
//  Created by John on 2018/7/18.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

open class TPPlayerControlView: UIView {
    
    weak public var player: EZPlayer? {
        didSet {
            player?.setControlsHidden(false, animated: true)
            self.autohideControlView()
        }
    }

    var hideControlViewTask: Task?
    public var autohidedControlViews = [UIView]()
    
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
    @IBOutlet weak var timeSlider: TPPlayerSlider!
    @IBOutlet weak var loading: EZPlayerLoading!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewImageView: UIImageView!
    
    var coverImageView: UIImageView = UIImageView.init()
    
    
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.timeSlider.setThumbImage(UIImage(named: "slider_point"), for: .normal)
        self.timeSlider.value = 0
        self.progressView.progress = 0
        self.progressView.progressTintColor = UIColor.lightGray
        self.progressView.trackTintColor = UIColor.clear
        self.progressView.backgroundColor = UIColor.clear
        
        self.previewView.isHidden = true
        
        self.autohidedControlViews = [self.navBarContainer, self.toolBarContainer]
        coverImageView.frame = self.bounds
        self.addSubview(coverImageView)
    }
    
    fileprivate var isProgressSliderSliding = false {
        didSet{
            if !(self.player?.isM3U8 ?? true) {
                //
            }
        }
    }
    
    
    @IBAction public func progressSliderTouchBegan(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        self.player(player, progressWillChange: TimeInterval(self.timeSlider.value))
    }
    
    @IBAction public func progressSliderValueChanged(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        
        self.player(player, progressChanging: TimeInterval(self.timeSlider.value))
        
        if !player.isM3U8 {
            self.previewView.isHidden = false
            player.generateThumbnails(times: [TimeInterval(self.timeSlider.value)], maximumSize: CGSize(width: self.previewImageView.bounds.size.width, height: self.previewImageView.bounds.size.height), completionHandler: { (thumbnails) in
                let trackRect = self.timeSlider.convert(self.timeSlider.bounds, to: nil)
                let thumbRect = self.timeSlider.thumbRect(forBounds: self.timeSlider.bounds, trackRect: trackRect, value: self.timeSlider.value)
                var lead = thumbRect.origin.x + thumbRect.size.width/2 - self.previewView.bounds.size.width/2
                if lead < 0 {
                    lead = 0
                } else if lead + self.previewView.bounds.size.width > player.view.bounds.width {
                    lead = player.view.bounds.width - self.previewView.bounds.size.width
                }
                self.previewViewLeadingConstraint.constant = lead
                if thumbnails.count > 0 {
                    let thumbnail = thumbnails[0]
                    if thumbnail.result == .succeeded {
                        self.previewImageView.image = thumbnail.image
                    }
                }
            })
        }
    }
    
    @IBAction public func progressSliderTouchEnd(_ sender: Any) {
        self.previewView.isHidden = true
        guard let player = self.player else {
            return
        }
        self.player(player, progressDidChange: TimeInterval(self.timeSlider.value))
    }
    
    
    fileprivate func hideControlView(_ animated: Bool) {
        if animated {
            UIView.setAnimationsEnabled(false)
            UIView.animate(withDuration: EZPlayerAnimatedDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.autohidedControlViews.forEach({
                    $0.alpha = 0
                })
            }) { (finished) in
                self.autohidedControlViews.forEach({
                    $0.isHidden = true
                })
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    fileprivate func showControlView(_ animated: Bool) {
        if animated {
            UIView.setAnimationsEnabled(false)
            self.autohidedControlViews.forEach { (view) in
                view.isHidden = false
            }
            UIView.animate(withDuration: EZPlayerAnimatedDuration, delay: 0, options: .curveEaseInOut, animations: {
                if self.player?.displayMode == .fullscreen {
                    self.navBarContainerTopConstraint.constant = EZPlayerUtils.isPhoneX && self.player?.fullScreenMode == .landscape ? 0 : EZPlayerUtils.statusBarHeight
                    self.toolBarContainerBottomConstraint.constant = EZPlayerUtils.isPhoneX ? self.player?.fullScreenMode == .portrait ? 34 : 21 : 0
                } else {
                    
                    self.navBarContainerTopConstraint.constant = 0
                    self.toolBarContainerBottomConstraint.constant = 0
                }
                self.autohidedControlViews.forEach({ (view) in
                    view.alpha = 1
                })
            }) { (finished) in
                self.autohideControlView()
                UIView.setAnimationsEnabled(true)
            }
        } else {
            self.autohidedControlViews.forEach { (view) in
                view.isHidden = false
                view.alpha = 1
            }
            if self.player?.displayMode == .fullscreen {
                self.navBarContainerTopConstraint.constant = EZPlayerUtils.isPhoneX && self.player?.fullScreenMode == .landscape ? 0 : EZPlayerUtils.statusBarHeight
                self.toolBarContainerBottomConstraint.constant = EZPlayerUtils.isPhoneX ? self.player?.fullScreenMode == .portrait ? 34 : 21 : 0
            } else {
                self.navBarContainerTopConstraint.constant = 0
            }
            self.autohideControlView()
        }
    }
    
    fileprivate func autohideControlView() {
        guard let player = self.player, player.autohiddenTimeInterval > 0 else {
            return
        }
        cancel(self.hideControlViewTask)
        self.hideControlViewTask = delay(5, task: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.player?.setControlsHidden(true, animated: true)
        })
    }
    
}

extension TPPlayerControlView : EZPlayerCustom {
    
    public func player(_ player: EZPlayer, playerStateDidChange state: EZPlayerState) {
        switch state {
        case .playing, .buffering:
            self.playPauseButton.setImage(UIImage(named: "btn_pause", in: Bundle(for: TPPlayerControlView.self), compatibleWith: nil), for: .normal)
        case .seekingForward, .seekingBackward:
            break
        default:
            self.playPauseButton.setImage(UIImage(named: "btn_play", in: Bundle(for: TPPlayerControlView.self), compatibleWith: nil), for: .normal)
        }
    }
    
    public func player(_ player: EZPlayer, playerDisplayModeDidChange displayMode: EZPlayerDisplayMode) {
        switch displayMode {
        case .none:
            break
        case .embedded:
            self.fullEmbeddedScreenButtonWidthConstraint.constant = 50
            self.fullEmbeddedScreenButton.setImage(UIImage(named: "btn_fullscreen", in: Bundle(for: TPPlayerControlView.self), compatibleWith: nil), for: .normal)
        case .fullscreen:
            self.fullEmbeddedScreenButtonWidthConstraint.constant = 50
            self.fullEmbeddedScreenButton.setImage(UIImage(named: "btn_normalscreen", in: Bundle(for: TPPlayerControlView.self), compatibleWith: nil), for: .normal)
        case .float:
            break
        }
    }
    
    public func player(_ player: EZPlayer, playerControlsHiddenDidChange controlsHidden: Bool, animated: Bool) {
        if controlsHidden {
            self.hideControlView(animated)
        } else {
            self.showControlView(animated)
        }
    }
    
    public func player(_ player: EZPlayer, bufferDurationDidChange bufferDuration: TimeInterval, totalDuration: TimeInterval) {
        if totalDuration.isNaN || bufferDuration.isNaN || totalDuration == 0 || bufferDuration == 0 {
            self.progressView.progress = 0
        } else {
            self.progressView.progress = Float(bufferDuration/totalDuration)
        }
    }
    
    public func player(_ player: EZPlayer, currentTime: TimeInterval, duration: TimeInterval) {
        if currentTime.isNaN || (currentTime == 0 && duration.isNaN) {
            return
        }
        self.timeSlider.isEnabled = !duration.isNaN
        self.timeSlider.minimumValue = 0
        self.timeSlider.maximumValue = duration.isNaN ? Float(currentTime) : Float(duration)
        self.titleLabel.text = player.contentItem?.title ?? player.playerasset?.title
        if !self.isProgressSliderSliding {
            self.timeSlider.value = Float(currentTime)
            self.timeLabel.text = duration.isNaN ? "Live" : EZPlayerUtils.formatTime(position: currentTime, duration: duration)
        }
    }
    
    public func playerHeartbeat(_ player: EZPlayer) {
        if let asset = player.playerasset, let playerItem = player.playerItem, playerItem.status == .readyToPlay {
            if asset.audios != nil || asset.subtitles != nil || asset.closedCaption != nil {
                
            }
        }
    }
    
    public func player(_ player: EZPlayer, showLoading: Bool) {
        if showLoading {
            self.loading.start()
        } else {
            self.loading.stop()
        }
    }
    
    @IBAction public func playPauseButtonPressed(_ sender: Any) {
        guard let player = self.player else { return }
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    @IBAction public func fullEmbeddedScreenButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        switch player.displayMode {
        case .embedded:
            player.toFull()
        case .fullscreen:
            if player.lastDisplayMode == .embedded {
                player.toEmbedded()
            } else if player.lastDisplayMode == .float {
                player.toFull()
            }
        default:
            break
        }
    }
    
    @IBAction public func audioSubtitleCCButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction public func backButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        let displayMode = player.displayMode
        if displayMode == .fullscreen {
            if player.lastDisplayMode == .embedded {
                player.toEmbedded()
            } else if player.lastDisplayMode == .float {
                player.toFloat()
            }
        }
        player.backButtonBlock?(displayMode)
    }
    
    @IBAction public func shareButtonPressed(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        player.share();
    }
    
    public func player(_ player: EZPlayer, progressWillChange value: TimeInterval) {
        if player.isLive ?? true {
            return
        }
        cancel(self.hideControlViewTask)
        self.isProgressSliderSliding = true
    }
    
    public func player(_ player: EZPlayer, progressChanging value: TimeInterval) {
        if player.isLive ?? true {
            return
        }
        self.timeLabel.text = EZPlayerUtils.formatTime(position: value, duration: self.player?.duration ?? 0)
        if !self.timeSlider.isTracking {
            self.timeSlider.value = Float(value)
        }
    }
    
    public func player(_ player: EZPlayer, progressDidChange value: TimeInterval) {
        if player.isLive ?? true {
            return
        }
        self.autohideControlView()
        self.player?.seek(to: value, completionHandler: { (isFinished) in
            self.isProgressSliderSliding = false
        })
    }
    
    public func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer) {
        player.setControlsHidden(!player.controlsHidden, animated: true)
    }
    
    public func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
        self.playPauseButtonPressed(doubleTap)
    }
}
