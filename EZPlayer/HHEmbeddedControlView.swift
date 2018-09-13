//
//  HHEmbeddedControlView.swift
//  EZPlayer
//
//  Created by John on 2018/9/13.
//  Copyright © 2018年 yangjun zhu. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

/// 动画时间
public var HHAnimatedDuration = 0.3

class HHEmbeddedControlView: UIView {
    
    public weak var player: EZPlayer? {
        didSet {
            player?.setControlsHidden(false, animated: true)
        }
    }
    
    var hideControlViewTask: Task?
    var loadingView: EZPlayerLoading = EZPlayerLoading()
    public var autohidedControlViews = [UIView]()
    fileprivate var isSliding: Bool = false

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topBarMaskView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var enterFullScreenButton: UIButton!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var bottomBarMaskView: UIImageView!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var centerPlayOrPauseButton: UIButton!
    @IBOutlet weak var seekToLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.topBarView.isHidden = true
        self.seekToLabel.isHidden = true
        self.progressSlider.value = 0
        self.progressView.progress = 0
        
//        self.autohidedControlViews = [self.topBarView, self.bottomBarView]
        self.autohidedControlViews = [self.centerPlayOrPauseButton, self.bottomBarView]
    }
    
    
    
}

extension HHEmbeddedControlView {
    
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
    }
}

extension HHEmbeddedControlView {
    
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

extension HHEmbeddedControlView: EZPlayerCustom {
    
    
    func player(_ player: EZPlayer, playerStateDidChange state: EZPlayerState) {
        
        switch state {
        case .playing, .buffering:
            self.centerPlayOrPauseButton.setImage(UIImage(named: "player_icon_pause", in: Bundle(for: HHEmbeddedControlView.self), compatibleWith: nil), for: .normal)
            
        case .seekingForward, .seekingBackward:
            break
        default:
            self.centerPlayOrPauseButton.setImage(UIImage(named: "player_icon_player", in: Bundle(for: HHEmbeddedControlView.self), compatibleWith: nil), for: .normal)
        }
    }
    
    func player(_ player: EZPlayer, playerDisplayModeDidChange displayMode: EZPlayerDisplayMode) {
        // ignore
    }
    
    func player(_ player: EZPlayer, playerControlsHiddenDidChange controlsHidden: Bool, animated: Bool) {
        if controlsHidden {
            self.hideControlView(animated)
        } else {
            self.showControlView(animated)
        }
    }
    
    func player(_ player: EZPlayer, bufferDurationDidChange bufferDuration: TimeInterval, totalDuration: TimeInterval) {
        if totalDuration.isNaN || bufferDuration.isNaN || totalDuration == 0 || bufferDuration == 0 {
            self.progressView.progress = 0
        } else {
            self.progressView.progress = Float(bufferDuration/totalDuration)
        }
    }
    
    func player(_ player: EZPlayer, currentTime: TimeInterval, duration: TimeInterval) {
        if currentTime.isNaN || (currentTime == 0 && duration.isNaN) {
            return
        }
        
        self.progressSlider.isEnabled = !duration.isNaN
        self.progressSlider.maximumValue = duration.isNaN ? Float(currentTime) : Float(duration)
        self.progressSlider.value = Float(currentTime)
        self.playTimeLabel.text = EZPlayerUtils.formatTime(position: currentTime, duration: 0)
        self.totalTimeLabel.text = EZPlayerUtils.formatTime(position: duration, duration: 0)
        
    }
    
    func playerHeartbeat(_ player: EZPlayer) {
        // ignore
    }
    
    func player(_ player: EZPlayer, showLoading: Bool) {
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
    
    func fullEmbeddedScreenButtonPressed(_ sender: Any) {
        //ignore
    }
    
    func audioSubtitleCCButtonPressed(_ sender: Any) {
        //ignore
    }
    
    func backButtonPressed(_ sender: Any) {
        //ignore
    }
    
    public func player(_ player: EZPlayer, progressWillChange value: TimeInterval) {
        if player.isLive ?? true {
            return
        }
        cancel(self.hideControlViewTask)
        self.isSliding = true
    }
    
    func player(_ player: EZPlayer, progressChanging value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.playTimeLabel.text = EZPlayerUtils.formatTime(position: value, duration: 0)
        if !self.progressSlider.isTracking {
            self.progressSlider.value = Float(value)
        }
    }
    
    func player(_ player: EZPlayer, progressDidChange value: TimeInterval) {
        if player.isLive ?? true{
            return
        }
        self.autoHideControlView()
        player.seek(to: value) { (isFinished) in
            self.isSliding = false
        }
    }
    
    func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer) {
        player.setControlsHidden(!player.controlsHidden, animated: true)
    }
    
    func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
        self.playPauseButtonPressed(doubleTap)
    }
    
    
}
