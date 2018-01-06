//
//  SongManager.swift
//  MusicProject
//
//  Created by Кирилл Володин on 24.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation
import RealmSwift
import MediaPlayer
import Jukebox

class SongManagerFactory {
    
    static var isSamePlaylist: Bool = false
    //for colored playlist
    static var shouldColorPlaylist: Bool = false
    //number of playlist
    static var numberColoredPlaylist: Int = -1
    
    static var repeatState: RepeatState = .off
    
    enum RepeatState {
        case on
        case off
    }
    
    static var actualSongManager = SongManager(name: "actual")
    static var newSongManager = SongManager(name: "new")
    
    static func getSongManager() -> SongManager {
        if isSamePlaylist {
            return actualSongManager
        }
        else {
            return newSongManager
        }
    }
    
    static func copyJukebox() {
        isSamePlaylist = true
        if let jukebox = actualSongManager.jukebox {
            jukebox.stop()
        }
        actualSongManager.jukebox = newSongManager.jukebox
        actualSongManager.backup = newSongManager.backup
        actualSongManager.songs = newSongManager.songs
        actualSongManager.index = newSongManager.index
        actualSongManager.images = newSongManager.images
        actualSongManager.shuffleState = newSongManager.shuffleState
        
    }
}

class SongManager: JukeboxDelegate {
    
    class SongWrapper {
        
        var song: SongDisplay!
        var position: Int
        
        init (song: SongDisplay, position: Int) {
            self.song = song
            self.position = position
        }

    }

    var jukebox: Jukebox!
        
    var backup: [SongWrapper] = []
    var songs: [SongWrapper] = []
    var images: [UIImage] = []
    var index: Int = 0
    var name = ""
    var shuffleState: ShuffleState = .off
    
    enum ShuffleState {
        case on
        case off
    }
    
    init(name: String) {
        self.name = name
    }
    
    func getIndex() -> Int {
        return index
    }
    
    func getPosition() -> Int? {
        
        if songs.isEmpty {
            return nil
        }
        let result = songs[getIndex()].position
        return result
        
    }
    
    func addSong(song: SongDisplay) {
        if TrackViewMode.mode == .fromListOfPlaylists {
            let songWrapper = SongWrapper(song: song, position: song.position)
            songs.append(songWrapper)
        }
        else {
            let songWrapper = SongWrapper(song: song, position: songs.count + 1)
            songs.append(songWrapper)
        }
    }
    
    func setIndex(value: Int) {
        
        if value == -1 || songs.isEmpty {
            index = 0
        }
        else if value == songs.count {
            index = value - 1
        }
        else {
            index = value
        }
        
    }
    
    func getNextPosition() -> Int? {
        let index = getIndex() + 1
        setIndex(value: index)
        return getPosition()
    }
    
    func getPreviousPosition() -> Int? {
        let index = getIndex() - 1
        setIndex(value: index)
        return getPosition()
    }
    
    func setIndex(bySongPosition position: Int) {
        for (index, song) in songs.enumerated() {
            if song.position == position {
                setIndex(value: index)
                break
            }
        }
    }
    
    func shuffleSongs() {
        let index = getIndex()
        if !songs.isEmpty {
            let position = songs[index].position
            backup = songs
            songs.shuffle()
            setIndex(bySongPosition: position)
        }
    }
    
    func normalizeSongs() {
        let index = getIndex()
        if !songs.isEmpty {
            let position = songs[index].position
            songs = backup
            setIndex(bySongPosition: position)
        }
    }
    
    func getCurrentImage() -> UIImage? {
        if let position = getPosition() {
            return images[position - 1]
        }
        else {
            return UIImage(named: "default_album_v2")
        }
    }
    
    func getSong(byPosition position: Int) -> SongDisplay? {
        
        for song in songs {
            if song.position == position {
                return song.song
            }
        }
        return nil
        
    }
    
    func getTime(time: Double) -> String {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        return String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    //MARK: Jukebox delegate
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            
            //update infoCenter
            jukebox.updateInfoCenter()
            
            if getTime(time: currentTime) == getTime(time: duration) {
                if SongManagerFactory.repeatState == .off {
                    
                    if let position = self.getNextPosition() {
                        jukebox.play(atIndex: position - 1)
                        //перерисовываем экран списка песен в плейлисте
                        NotificationCenter.default.post(name: .playNextSong, object: nil)
                    }
                }
                else {
                    jukebox.replayCurrentItem()
                }
            }
        }
    }

    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        
    }
}
