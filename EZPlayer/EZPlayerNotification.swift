//
//  EZPlayerNotification.swift
//  EZPlayer
//
//  Created by yangjun zhu on 2016/12/28.
//  Copyright © 2016年 yangjun zhu. All rights reserved.
//

import Foundation



public extension Notification.Name {
    /// EZPlayer生命周期
    static let EZPlayerHeartbeat = Notification.Name(rawValue: "com.ezplayer.EZPlayerHeartbeat")

    /// addPeriodicTimeObserver方法的触发
    static let EZPlayerPlaybackTimeDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlaybackTimeDidChange")

    /// 播放器状态改变
    static let EZPlayerStatusDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerStatusDidChange")
    
    /// 视频结束
    static let EZPlayerPlaybackDidFinish = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlaybackDidFinish")
    
    /// loading状态改变
    static let EZPlayerLoadingDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerLoadingDidChange")

    /// 播放器控制条隐藏显示
    static let EZPlayerControlsHiddenDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerControlsHiddenDidChange")

    /// 播放器显示模式改变了（全屏，嵌入屏，浮动）
    static let EZPlayerDisplayModeDidChange = Notification.Name(rawValue: "com.ezplayer.EZPlayerStatusDidChang")
    /// 播放器显示模式动画开始
    static let EZPlayerDisplayModeChangedWillAppear = Notification.Name(rawValue: "EZPlayerDisplayModeChangedWillAppear")
    /// 播放器显示模式动画结束
    static let EZPlayerDisplayModeChangedDidAppear = Notification.Name(rawValue: "EZPlayerDisplayModeChangedDidAppear")

    /// 点击播放器手势通知
    static let EZPlayerTapGestureRecognizer = Notification.Name(rawValue: "com.ezplayer.EZPlayerTapGestureRecognizer")

    /// FairPlay DRM
    static let EZPlayerDidPersistContentKey = Notification.Name(rawValue: "com.ezplayer.EZPlayerDidPersistContentKey")
    /// 分享按钮
    static let EZPlayerPressShare = Notification.Name(rawValue: "com.ezplayer.EZPlayerPressShare")
    
    ///  返回按钮
    static let EZPlayerPressBack = Notification.Name(rawValue: "com.ezplayer.EZPlayerPressBack")
    /// 播放完成
    static let EZPlayerPlayFinished = Notification.Name(rawValue: "com.ezplayer.EZPlayerPlayFinished")
    /// 点击下一集
    static let EZPlayerPressNextButton = Notification.Name(rawValue: "com.ezplayer.EZPlayerPressNextButton")
    /// 点击选集
    static let EZPlayerPressSelections = Notification.Name(rawValue: "com.ezplayer.EZPlayerPressSelections")
}

public extension Notification {
    public struct Key {
        /// 播放器状态改变
        public static let EZPlayerNewStateKey = "EZPlayerNewStateKey"
        public static let EZPlayerOldStateKey = "EZPlayerOldStateKey"

        /// 视频结束
        public static let EZPlayerPlaybackDidFinishReasonKey = "EZPlayerPlaybackDidFinishReasonKey"

        /// loading状态改变
        public static let EZPlayerLoadingDidChangeKey = "EZPlayerLoadingDidChangeKey"

        /// 播放器控制条隐藏显示
        public static let EZPlayerControlsHiddenDidChangeKey = "EZPlayerControlsHiddenDidChangeKey"
        public static let EZPlayerControlsHiddenDidChangeByAnimatedKey = "EZPlayerControlsHiddenDidChangeByAnimatedKey"
        
        /// 播放器显示模式改变了（全屏，嵌入屏，浮动）
        public static let EZPlayerDisplayModeDidChangeKey = "EZPlayerDisplayModeDidChangeKey"
        public static let EZPlayerDisplayModeChangedFrom = "EZPlayerDisplayModeChangedFrom"
        public static let EZPlayerDisplayModeChangedTo = "EZPlayerDisplayModeChangedTo"

        /// 点击播放器手势通知
        public static let EZPlayerNumberOfTaps =  "EZPlayerNumberOfTaps"
        public static let EZPlayerTapGestureRecognizer =  "EZPlayerTapGestureRecognizer"

        /// FairPlay DRM=
        public static let EZPlayerDidPersistAssetIdentifierKey = "EZPlayerDidPersistAssetIdentifierKey"
        
        /// 分享按钮
        public static let EZPlayerPressShare = "EZPlayerPressShare"
        /// 返回按钮
        public static let EZPlayerPressBack = "EZPlayerPressBack"
        
        public static let EZPlayerPlayFinished = "EZPlayerPlayFinished"
        
        public static let EZPlayerPressNextButton = "EZPlayerPressNextButton"
        
        public static let EZPlayerPressSelections = "EZPlayerPressSelections"
    }

}
