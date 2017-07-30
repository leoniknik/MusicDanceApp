//
//  NotificationManager.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let getPlaylistsCallback = Notification.Name("getPlaylistsCallback")
    static let getSongsCallback = Notification.Name("getSongsCallback")
    static let getSongImageCallback = Notification.Name("getSongImageCallback")
    static let playNextSong = Notification.Name("playNextSong")
    
}
