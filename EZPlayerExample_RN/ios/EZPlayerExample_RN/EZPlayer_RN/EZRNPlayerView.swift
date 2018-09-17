//
//  EZRNPlayerView.swift
//  EZPlayerExample_RN
//
//  Created by IQIYI on 2017/9/30.
//  Copyright © 2017年 Facebook. All rights reserved.
//

import UIKit

import EZPlayer

open class EZRNPlayerView: UIView {
  var player: EZPlayer?
  
  @objc public var source: [String: Any]? = nil {

    didSet {
      
      if let newUri = source?["uri"] as? String {
        if self.player != nil{
//          self.player?.replaceToPlayWithURL(URL(string: newUri)!)
          self.player?.replaceToPlayWithURL(URL(string: newUri)!, title: source?["title"] as? String, coverUrl: source?["coverUrl"] as? String)
        }else{
          self.initPlayerIfNeeded()
        }
      }
      
    }
  }
  
  @objc public var autoPlay: Bool = true {
    didSet {
      self.player?.autoPlay = autoPlay
    }
  }
  
  @objc public var useDefaultUI: Bool = true {
    didSet {
      if useDefaultUI{
        self.player?.controlViewForIntercept = nil
      }else{
        self.player?.controlViewForIntercept = UIView()
      }
    }
  }
  
  @objc public var videoGravity: String = "aspect"{
    didSet {
     self.player?.videoGravity = self.getEZPlayerVideoGravity(videoGravity: videoGravity)
    }
  }
  
  @objc public var fullScreenMode: String = "landscape"{
    didSet {
      self.player?.fullScreenMode = self.getEZPlayerFullScreenMode(fullScreenMode: fullScreenMode)
    }
  }
  
  @objc public var selections: [[String: Any]]? {
    willSet{
      player?.selectionsModels.removeAll()
    }
    didSet {
      guard let selections = selections else { return }
      for dict in selections {
        player?.selectionsModels.append(SelectionsModel(dict: dict))
      }
    }
  }
  

  
  @objc public var onPlayerHeartbeat: RCTDirectEventBlock?
  @objc public var onPlayerPlaybackTimeDidChange: RCTDirectEventBlock?
  @objc public var onPlayerStatusDidChange: RCTDirectEventBlock?
  @objc public var onPlayerPlaybackDidFinish: RCTDirectEventBlock?
  @objc public var onPlayerLoadingDidChange: RCTDirectEventBlock?
  @objc public var onPlayerControlsHiddenDidChange: RCTDirectEventBlock?
  @objc public var onPlayerDisplayModeDidChange: RCTDirectEventBlock?
  @objc public var onPlayerDisplayModeChangedWillAppear: RCTDirectEventBlock?
  @objc public var onPlayerDisplayModeChangedDidAppear: RCTDirectEventBlock?
  @objc public var onPlayerTapGestureRecognizer: RCTDirectEventBlock?
  @objc public var onPlayerDidPersistContentKey: RCTDirectEventBlock?
  @objc public var onPlayerPlayFinished: RCTDirectEventBlock?
  @objc public var onPlayerClickNextButton: RCTDirectEventBlock?
  @objc public var onPlayerClickSelections: RCTDirectEventBlock?
  
  // MARK: - Life

  public override init(frame: CGRect) {
    super.init(frame: CGRect(x:0,y:0,width:100,height:100))
    //    self.backgroundColor = UIColor.red
    //    self.initPlayerIfNeeded()
    
  }
  
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override open func willMove(toWindow newWindow: UIWindow?) {
//    if newWindow == nil {
//      self.stop()
//    }
  }
  
  override open func willMove(toSuperview newSuperview: UIView?) {
//    if newSuperview == nil {
//      self.stop()
//    }
  }
  
  deinit {
    print("swift播放器释放")
  }
  
  // MARK: - player

  open func initPlayerIfNeeded(){
    if(self.player == nil){
      self.addObservers()
      self.player = self.useDefaultUI ?  EZPlayer() : EZPlayer(controlView: UIView())
      
      self.player!.autoPlay = self.autoPlay
      self.player!.videoGravity = self.getEZPlayerVideoGravity(videoGravity: self.videoGravity)
      self.player!.fullScreenMode = self.getEZPlayerFullScreenMode(fullScreenMode: self.fullScreenMode)
      self.player!.backButtonBlock = { fromDisplayMode in
        if fromDisplayMode == .embedded {
          self.stop()
        }else if fromDisplayMode == .fullscreen {
          
        }else if fromDisplayMode == .float {
          self.stop()
        }
      }
      self.player!.playWithURL(URL(string: source?["uri"] as? String ?? "")!, embeddedContentView: self)
    }
  }
  
  open func  releasePlayerResource() {
    if self.player != nil {
      self.removeObservers()
      self.player = nil
      self.source = nil
      
    }
  }
  
  open func play(){
    //    if let source = self.source ,let  uri = source["uri"] as? String {
    //       self.initPlayerIfNeeded()
    //    }
    self.player?.play()
  }
  
  open func pause(){
    self.player?.pause()
  }
  
  open func stop(){
    self.player?.stop()
    self.releasePlayerResource()
  }
  
  open func seek(to time: TimeInterval, completionHandler: ((Bool) -> Swift.Void )? = nil){
    self.player?.seek(to: time, completionHandler: completionHandler)
  }
  
  open func replaceToPlay(source: [String: Any]){
    self.source = source;
  }
  
  /// 视频播放速率
//  public var rate: Float{
//    get {
//      if let player = self.player {
//        return player.rate
//      }
//      return .nan
//    }
//    set {
//      if let player = self.player {
//        player.rate = newValue
//      }
//    }
//  }
  
  
  
  private func getEZPlayerVideoGravity(videoGravity: String) -> EZPlayerVideoGravity{
    var videoGravitString = ""
    switch(videoGravity){
    case "aspect": videoGravitString = "AVLayerVideoGravityResizeAspect"
    case "aspectFill": videoGravitString = "AVLayerVideoGravityResizeAspectFill"
    case "scaleFill": videoGravitString = "AVLayerVideoGravityResize"
    default:videoGravitString = "AVLayerVideoGravityResizeAspect"
    }
    return EZPlayerVideoGravity(rawValue: videoGravitString)!
  }
  
  private func getEZPlayerFullScreenMode(fullScreenMode: String) -> EZPlayerFullScreenMode{
    var ezPlayerFullScreenMode = EZPlayerFullScreenMode.landscape
    switch(fullScreenMode){
    case "portrait": ezPlayerFullScreenMode = EZPlayerFullScreenMode.portrait
    case "landscape": ezPlayerFullScreenMode = EZPlayerFullScreenMode.landscape
    default:ezPlayerFullScreenMode = EZPlayerFullScreenMode.landscape
    }
    return ezPlayerFullScreenMode
  }
  
}


// MARK: - Notification
extension EZRNPlayerView {
  open func addObservers(){
    self.removeObservers()
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerHeartbeat(_:)), name: NSNotification.Name.EZPlayerHeartbeat, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerPlaybackTimeDidChange(_:)), name: NSNotification.Name.EZPlayerPlaybackTimeDidChange, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerStatusDidChange(_:)), name: NSNotification.Name.EZPlayerStatusDidChange, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerPlaybackDidFinish(_:)), name: NSNotification.Name.EZPlayerPlaybackDidFinish, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerLoadingDidChange(_:)), name: NSNotification.Name.EZPlayerLoadingDidChange, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerControlsHiddenDidChange(_:)), name: NSNotification.Name.EZPlayerControlsHiddenDidChange, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDisplayModeDidChange(_:)), name: NSNotification.Name.EZPlayerDisplayModeDidChange, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDisplayModeChangedWillAppear(_:)), name: NSNotification.Name.EZPlayerDisplayModeChangedWillAppear, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDisplayModeChangedDidAppear(_:)), name: NSNotification.Name.EZPlayerDisplayModeChangedDidAppear, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerTapGestureRecognizer(_:)), name: NSNotification.Name.EZPlayerTapGestureRecognizer, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidPersistContentKey(_:)), name: NSNotification.Name.EZPlayerDidPersistContentKey, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerPlayFinished(_:)), name: NSNotification.Name.EZPlayerPlayFinished, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerClickNextButton(_:)), name: NSNotification.Name.EZPlayerPressNextButton, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.playerClickSelections(_:)), name: NSNotification.Name.EZPlayerPressSelections, object: nil)
  }
  
  open func removeObservers(){
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc  func playerHeartbeat(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    var playerInfo = [String:Any]()
    if let player = self.player{
      if let isLive = player.isLive {
        playerInfo["isLive"] = isLive
      }
      if let duration = player.duration {
        playerInfo["duration"] = duration.isNaN ? -1 : duration  //maybe nan
      }
      if let currentTime = player.currentTime {
        playerInfo["currentTime"] = currentTime
      }
      
      playerInfo["isM3U8"] = player.isM3U8
      playerInfo["rate"] = player.rate.isNaN ? 0 : player.rate //maybe nan
      playerInfo["systemVolume"] = player.systemVolume
      playerInfo["state"] = self.stateName(state: player.state)

    }
    self.onPlayerHeartbeat?(playerInfo)
  }
  
  @objc  func playerPlaybackTimeDidChange(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    self.onPlayerPlaybackTimeDidChange?(notifiaction.userInfo)
    
  }
  
  @objc  func playerStatusDidChange(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    let newState = self.stateName(state: notifiaction.userInfo![Notification.Key.EZPlayerNewStateKey] as! EZPlayerState)
    let oldState = self.stateName(state: notifiaction.userInfo![Notification.Key.EZPlayerOldStateKey] as! EZPlayerState)
    self.onPlayerStatusDidChange?(["newState":newState,"oldState":oldState])
  }
  
  @objc  func playerPlaybackDidFinish(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    let reason = self.finishReason(finishReason: notifiaction.userInfo![Notification.Key.EZPlayerPlaybackDidFinishReasonKey] as! EZPlayerPlaybackDidFinishReason)
    self.onPlayerPlaybackDidFinish?(["playerPlaybackDidFinish" : reason])
  }
  
  @objc  func playerLoadingDidChange(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    self.onPlayerLoadingDidChange?(notifiaction.userInfo)
  }
  
  @objc  func playerControlsHiddenDidChange(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    self.onPlayerControlsHiddenDidChange?(notifiaction.userInfo)
  }
  
  @objc  func playerDisplayModeDidChange(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    let displayMode = self.displayModeName(displayMode:self.player?.displayMode ?? .none)
    self.onPlayerDisplayModeDidChange?(["displayMode":displayMode])
  }
  
  @objc  func playerDisplayModeChangedWillAppear(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    self.onPlayerDisplayModeChangedWillAppear?(notifiaction.userInfo)
  }
  
  @objc  func playerDisplayModeChangedDidAppear(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    self.onPlayerDisplayModeChangedDidAppear?(notifiaction.userInfo)
  }
  
  @objc  func playerTapGestureRecognizer(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    self.onPlayerTapGestureRecognizer?(notifiaction.userInfo)
  }
  
  @objc  func playerDidPersistContentKey(_ notifiaction: Notification) {
    guard let player = notifiaction.object as? EZPlayer ,let selfPlayer = self.player , player == selfPlayer else{
      return
    }
    self.onPlayerDidPersistContentKey?(notifiaction.userInfo)
  }
  
  @objc func playerPlayFinished(_ notifiaction: Notification) {
    self.onPlayerPlayFinished?(["code": 0])
  }
  
  @objc func playerClickNextButton(_ notifiaction: Notification) {
    self.onPlayerClickNextButton?(notifiaction.object as? [String : Any])
  }
  
  @objc func playerClickSelections(_ notifiaction: Notification) {
    self.onPlayerClickSelections?(notifiaction.object as? [String: Any])
  }
  
  private func stateName(state: EZPlayerState) -> String{
    var stateName = ""
    switch (state) {
    case .unknown: stateName = "unknown"
    case .readyToPlay: stateName = "readyToPlay"
    case .buffering: stateName = "buffering"
    case .bufferFinished: stateName = "bufferFinished"
    case .playing: stateName = "playing"
    case .seekingForward: stateName = "seekingForward"
    case .seekingBackward: stateName = "seekingBackward"
    case .pause: stateName = "pause"
    case .stopped: stateName = "stopped"
    case .error(let type):
      switch (type){
      case .invalidContentURL: stateName = "error.invalidContentURL"
      case .playerFail: stateName = "error.playerFail"
      }
    }
    return stateName
  }
  
  private func displayModeName(displayMode: EZPlayerDisplayMode) -> String{
    var displayModeName = ""
    switch (displayMode) {
    case .none: displayModeName = "none"
    case .embedded: displayModeName = "embedded"
    case .fullscreen: displayModeName = "fullscreen"
    case .float: displayModeName = "float"
    }
    return displayModeName
  }
  
  
  private func finishReason(finishReason: EZPlayerPlaybackDidFinishReason) -> String{
    var reason = ""
    switch (finishReason) {
    case .playbackEndTime: reason = "playbackEndTime"
    case .playbackError: reason = "playbackError"
    case .stopByUser: reason = "stopByUser"
    }
    return reason
  }

  
}

