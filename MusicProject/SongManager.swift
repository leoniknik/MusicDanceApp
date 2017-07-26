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
    static var numberColoredPlaylist: Int = 0
    
    static var actualSongManager = SongManager()
    static var newSongManager = SongManager()
    
    static func getSongManager() -> SongManager {
        if isSamePlaylist {
            return actualSongManager
        }
        else {
            return newSongManager
        }
    }
    
}

class SongManager {
    
    class SongWrapper {
        
        var song: Song!
        var position: Int
        
        init (song: Song, position: Int) {
            self.song = song
            self.position = position
        }

    }

    var jukebox: Jukebox!
        
    var backup: [SongWrapper] = []
    var songs: [SongWrapper] = []
    var images: [UIImage] = []
    var index: Int = 0
    
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
    
    func addSong(song: Song) {
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
    
    func getSong(byPosition position: Int) -> Song? {
        
        for song in songs {
            if song.position == position {
                return song.song
            }
        }
        return nil
        
    }

}
