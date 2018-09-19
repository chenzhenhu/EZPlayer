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

enum PanelViewType {
    case none
    case rate
    case selections
    case resolution
}

public let constraintLeft: CGFloat = 76
public let progressSliderTrackColor = UIColor(red: 215 / 255.0, green: 171 / 255.0, blue: 112 / 255.0, alpha: 1.0)
private let cellId = "HHPanelViewCell"
private let rates:[RateModel] = [RateModel(title: "0.8X", rate: 0.8),
                                   RateModel(title: "1.0X", rate: 1.0),
                                   RateModel(title: "1.25X", rate: 1.25),
                                   RateModel(title: "1.5X", rate: 1.5),
                                   RateModel(title: "2.0X", rate: 2.0),]
private var selections:[String] = [String]()
private var resolutions:[String] = [String]()

open class HHFullScreenControlView: UIView {

    public weak var player: EZPlayer? {
        didSet {
            player?.delegate = self
            player?.setControlsHidden(false, animated: true)
            self.autoHideControlView()
        }
    }
    var panelType: PanelViewType = .none
    var hideControlViewTask: Task?
    var loadingView: EZPlayerLoading = EZPlayerLoading()
    public var autohidedControlViews = [UIView]()
    public var notEnableViews: [UIView] = [UIView]()
    fileprivate var isSliding: Bool = false
    fileprivate var rateIndexPath: IndexPath?
    fileprivate var selectionIndexPath: IndexPath?
    fileprivate var resolutionIndexPath: IndexPath?

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
    @IBOutlet weak var resolutionButtonConstraintWidth: NSLayoutConstraint!
    
    @IBOutlet weak var panelView: UIView!
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: self.panelView.bounds, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0)
        tableView.register(HHPanelViewCell.self, forCellReuseIdentifier: cellId)
        return tableView
    }()
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.resolutionButtonConstraintWidth.constant = 0
        self.moreButton.isHidden = true
        self.previewView.isHidden = true
        self.panelView.isHidden = true
        self.panelView.addSubview(self.tableView)
        self.progressSlider.value = 0
        self.progressSlider.maximumTrackTintColor = UIColor.clear
        self.progressSlider.minimumTrackTintColor = progressSliderTrackColor
        self.progressSlider.setThumbImage(UIImage(named: "fullplayer_progress_point", in: Bundle(for: HHFullScreenControlView.self), compatibleWith: nil), for: .normal)
        self.progressView.progress = 0
        self.progressView.progressTintColor = UIColor.white
        self.progressView.trackTintColor = UIColor.white.withAlphaComponent(0.33)
        
        self.autohidedControlViews = [self.topBarView, self.bottomBarView]
        self.notEnableViews = [self.topBarView, self.bottomBarView, self.panelView, self.tableView]
        
        if EZPlayerUtils.isPhoneX {
            
            self.bottomBarViewConstraintHeight.constant = 70
            self.exitFullScreenButtonConstraintLeft.constant = constraintLeft
            self.moreButtonConstraintRight.constant = constraintLeft + 10
            self.progressViewConstraintLeft.constant = constraintLeft
            self.progressViewConstraintRight.constant = constraintLeft
            self.progressSliderConstraintLeft.constant = constraintLeft
            self.progressSliderConstraintRight.constant = constraintLeft
            self.playOrPauseConstraintLeft.constant = constraintLeft
            self.resolutionButtonConstraintRight.constant = constraintLeft + 10
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let player = self.player else { return }
        player.fullScreenStatusbarBackgroundColor = UIColor.clear
        if player.state == .pause {
            self.playOrPauseButton.setImage(UIImage(named: "player_icon_play", in: Bundle(for: HHFullScreenControlView.self), compatibleWith: nil), for: .normal)
        } else {
            self.playOrPauseButton.setImage(UIImage(named: "player_icon_pause", in: Bundle(for: HHFullScreenControlView.self), compatibleWith: nil), for: .normal)
        }
        
        selections.removeAll()
        if let title = player.contentItem?.title, !title.isEmpty {
            selections.append(title)
        }
    }
}

//MARK: UI 控件事件
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
        
    }
    
    @IBAction func clickMoreButton(_ sender: Any) {
        
    }
    
    @IBAction func clickNextButton(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name.EZPlayerPressNextButton, object: ["index": 0, "currentTime": self.player?.currentTime])
    }
    
    @IBAction func clickSpeedButton(_ sender: Any) {
        self.player?.setControlsHidden(true, animated: true)
        self.panelView.isHidden = false
        self.panelType = .rate
        let height:CGFloat = CGFloat(rates.count * 50)
        let topBottom = (self.panelView.bounds.height - height) / 2
        self.tableView.contentInset = UIEdgeInsetsMake(topBottom, 0, topBottom, 0)
        self.tableView.bounces = false
        self.tableView.isScrollEnabled = false
        self.tableView.reloadData()
    }
    
    @IBAction func clickSelectionsButton(_ sender: Any) {
        self.player?.setControlsHidden(true, animated: true)
        self.panelView.isHidden = false
        self.panelType = .selections
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 20, 0)
        self.tableView.bounces = true
        self.tableView.isScrollEnabled = true
        self.tableView.reloadData()
    }
    
    @IBAction func clickResolutionButton(_ sender: Any) {
        self.player?.setControlsHidden(true, animated: true)
        self.panelView.isHidden = false
        self.panelType = .resolution
        let height:CGFloat = CGFloat(rates.count * 50)
        let topBottom = (self.panelView.bounds.height - height) / 2
        self.tableView.contentInset = UIEdgeInsetsMake(topBottom, 0, topBottom, 0)
        self.tableView.bounces = false
        self.tableView.isScrollEnabled = false
        self.tableView.reloadData()
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
        if currentTime == duration {
            NotificationCenter.default.post(name: .EZPlayerPlayFinished, object: nil)
        }
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
        self.previewView.isHidden = true
        if player.isLive ?? true{
            return
        }
        self.autoHideControlView()
        player.seek(to: value) { (isFinished) in
            self.isSliding = false
        }
    }
    
    public func player(_ player: EZPlayer, singleTapGestureTapped singleTap: UITapGestureRecognizer) {
        if !self.panelView.isHidden {
            self.panelView.isHidden = true
        }
        player.setControlsHidden(!player.controlsHidden, animated: true)
    }
    
    public func player(_ player: EZPlayer, doubleTapGestureTapped doubleTap: UITapGestureRecognizer) {
        if !self.panelView.isHidden {
            self.panelView.isHidden = true
        }
        self.playPauseButtonPressed(doubleTap)
    }
    
    
}

extension HHFullScreenControlView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch panelType {
        case .rate:
            return rates.count
        case .selections:
            return selections.count
        case .resolution:
            return resolutions.count
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch panelType {
        case .rate:
            return 50
        case .selections:
            return 40
        case .resolution:
            return 50
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! HHPanelViewCell
        
        switch panelType {
        case .rate:
            let rateModel = rates[indexPath.row]
            cell.titleLabel.text = rateModel.title
            let rate = self.player?.rate ?? 1.0
            if rate == rateModel.rate {
                cell.backgroundColor = UIColor.red
                rateIndexPath = indexPath
            } else {
                cell.backgroundColor = UIColor.clear
            }
        case .selections:
            cell.titleLabel.text = selections[indexPath.row]
        case .resolution:
            cell.titleLabel.text = resolutions[indexPath.row]
        case .none:
            cell.isHidden = true
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath).backgroundColor = UIColor.red
        switch panelType {
        case .rate:
            let rate = rates[indexPath.row].rate
            self.player?.rate = rate
            if rateIndexPath != nil {
                tableView.dequeueReusableCell(withIdentifier: cellId, for: rateIndexPath!).backgroundColor = UIColor.clear
            }
            
        case .selections:
            if selectionIndexPath != nil {
                tableView.dequeueReusableCell(withIdentifier: cellId, for: selectionIndexPath!).backgroundColor = UIColor.clear
            }
            NotificationCenter.default.post(name: .EZPlayerPressSelections, object: ["currentTime": self.player?.currentTime ?? 0, "currentIndex": indexPath.row])
        case .resolution:
            print("")
        case .none:
            print("")
        }
        self.panelView.isHidden = true
        self.player?.setControlsHidden(false, animated: true)
    }
}
