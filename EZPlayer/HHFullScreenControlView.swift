//
//  HHFullScreenControlView.swift
//  EZPlayer
//
//  Created by John on 2018/9/13.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

public let constraintLeft: CGFloat = 44

open class HHFullScreenControlView: UIView {
    
    public weak var player: EZPlayer? {
        didSet {
            player?.setControlsHidden(false, animated: true)
            self.autoHideControlView()
        }
    }
    
    var hideControlViewTask: Task?
    var loadingView: EZPlayerLoading = EZPlayerLoading()
    public var autohidedControlViews = [UIView]()
    fileprivate var isSliding: Bool = false

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
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var seekToLabel: UILabel!
    
    @IBOutlet weak var bottomBarViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var exitFullScreenButtonConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var moreButtonConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var progressViewConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var progressSliderConstraintLeft: NSLayoutConstraint!
    @IBOutlet weak var progressSliderConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var progressViewConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var resolutionButtonConstraintRight: NSLayoutConstraint!
    @IBOutlet weak var playOrPauseConstraintLeft: NSLayoutConstraint!
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.previewView.isHidden = true
        self.progressSlider.value = 0
        self.progressSlider.setThumbImage(UIImage(named: "fullplayer_progress_point", in: Bundle(for: HHFullScreenControlView.self), compatibleWith: nil), for: .normal)
        self.progressView.progress = 0
        
        self.autohidedControlViews = [self.topBarView, self.bottomBarView]
        
        if EZPlayerUtils.isPhoneX {
            
            self.bottomBarViewConstraintHeight.constant = 70
            self.exitFullScreenButtonConstraintLeft.constant = constraintLeft
            self.moreButtonConstraintRight.constant = constraintLeft
            self.progressViewConstraintLeft.constant = constraintLeft
            self.progressViewConstraintRight.constant = constraintLeft
            self.progressSliderConstraintLeft.constant = constraintLeft
            self.progressSliderConstraintRight.constant = constraintLeft
            self.playOrPauseConstraintLeft.constant = constraintLeft
            self.resolutionButtonConstraintRight.constant = constraintLeft
        }
    }
}

extension HHFullScreenControlView {
    
    @IBAction public func progressSliderTouchBegan(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        self.player(player, progressWillChange: TimeInterval(self.progressSlider.value))
    }
    
    @IBAction func progressSliderValueChanged(_ sender: Any) {
        guard let player = self.player else {
            return
        }
        
        self.player(player, progressChanging: TimeInterval(self.progressSlider.value))
        
    }
    
    @IBAction func progressSliderTouchEnd(_ sender: Any) {
        guard let player = self.player else { return }
        self.player(player, progressDidChange: TimeInterval(self.progressSlider.value))
        self.previewView.isHidden = true
        self.previewImageView.image = nil
        self.seekToLabel.text = ""
    }
    
    @IBAction func clickMoreButton(_ sender: Any) {
        
    }
    
    @IBAction func clickNextButton(_ sender: Any) {
        
    }
    
    @IBAction func clickSpeedButton(_ sender: Any) {
        
    }
    
    @IBAction func clickSelectionsButton(_ sender: Any) {
        
    }
    
    @IBAction func clickResolutionButton(_ sender: Any) {
        
    }
    
}

extension HHFullScreenControlView {
    fileprivate func autoHideControlView() {
        guard let player = self.player, player.autohiddenTimeInterval > 0 else { return }
        
        cancel(self.hideControlViewTask)
        self.hideControlViewTask = delay(5, task: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.player?.setControlsHidden(true, animated: true)
        })
    }
    
    fileprivate func hideControlView(_ animated: Bool) {
        if animated {
            UIView.setAnimationsEnabled(false)
            UIView.animate(withDuration: HHAnimatedDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.autohidedControlViews.forEach({ (view) in
                    view.alpha = 0
                })
            }) { (finished) in
                self.autohidedControlViews.forEach({ (view) in
                    view.isHidden = true
                })
                UIView.setAnimationsEnabled(true)
            }
        } else {
            self.autohidedControlViews.forEach { (view) in
                view.alpha = 0
                view.isHidden = true
            }
        }
    }
    
    fileprivate func showControlView(_ animated: Bool) {
        
        if animated {
            UIView.setAnimationsEnabled(false)
            self.autohidedControlViews.forEach { (view) in
                view.isHidden = false
            }
            
            UIView.animate(withDuration: HHAnimatedDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.autohidedControlViews.forEach({ (view) in
                    view.alpha = 1
                })
            }) { (finished) in
                self.autoHideControlView()
                UIView.setAnimationsEnabled(true)
            }
        } else {
            self.autohidedControlViews.forEach { (view) in
                view.isHidden = false
                view.alpha = 1
            }
        }
    }
}

extension HHFullScreenControlView: EZPlayerCustom {
    public func player(_ player: EZPlayer, playerStateDidChange state: EZPlayerState) {
        switch state {
        case .playing, .buffering:
            self.playOrPauseButton.setImage(UIImage(named: "player_icon_pause", in: Bundle(for: HHFullScreenControlView.self), compatibleWith: nil), for: .normal)
            
        case .seekingForward, .seekingBackward:
            break
        default:
            self.playOrPauseButton.setImage(UIImage(named: "player_icon_play", in: Bundle(for: HHFullScreenControlView.self), compatibleWith: nil), for: .normal)
        }
    }
    
    public func player(_ player: EZPlayer, playerDisplayModeDidChange displayMode: EZPlayerDisplayMode) {
        // ignore
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
        
        self.progressSlider.isEnabled = !duration.isNaN
        self.progressSlider.maximumValue = duration.isNaN ? Float(currentTime) : Float(duration)
        self.progressSlider.value = Float(currentTime)
        self.timeLabel.text = EZPlayerUtils.formatTime(position: currentTime, duration: duration)
        self.titleLabel.text = player.contentItem?.title ?? ""
    }
    
    public func playerHeartbeat(_ player: EZPlayer) {
        // ignore
    }
    
    public func player(_ player: EZPlayer, showLoading: Bool) {
        if showLoading {
            self.loadingView.start()
        } else {
            self.loadingView.stop()
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
    
    public func fullEmbeddedScreenButtonPressed(_ sender: Any) {
        // ignore
    }
    
    public func audioSubtitleCCButtonPressed(_ sender: Any) {
        // ignore
    }
    
    @IBAction public func backButtonPressed(_ sender: Any) {
        guard let player = self.player else { return }
        player.toEmbedded()
    }
    
    public func player(_ player: EZPlayer, progressWillChange value: TimeInterval) {
        if player.isLive ?? true {
            return
        }
        cancel(self.hideControlViewTask)
        self.isSliding = true
    }
    
    public func player(_ player: EZPlayer, progressChanging value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.timeLabel.text = EZPlayerUtils.formatTime(position: value, duration: player.duration ?? 0)
        if !self.progressSlider.isTracking {
            self.progressSlider.value = Float(value)
        }
        if !player.isM3U8 {
            self.previewView.isHidden = false
            self.seekToLabel.text = EZPlayerUtils.formatTime(position: TimeInterval(self.progressSlider.value))
            player.generateThumbnails(times:  [ TimeInterval(self.progressSlider.value)],maximumSize:CGSize(width: self.previewImageView.bounds.size.width, height: self.previewImageView.bounds.size.height)) { (thumbnails) in
                
                if thumbnails.count > 0 {
                    let thumbnail = thumbnails[0]
                    if thumbnail.result == .succeeded {
                        self.previewImageView.image = thumbnail.image
                    }
                }
            }
        }
    }
    
    public func player(_ player: EZPlayer, progressDidChange value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.autoHideControlView()
        player.seek(to: value) { (isFinished) in
            self.isSliding = false
        }
    }
    
    public func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer) {
        player.setControlsHidden(!player.controlsHidden, animated: true)
    }
    
    public func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
        self.playPauseButtonPressed(doubleTap)
    }
    
    
}
