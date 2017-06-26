//
//  SongManager.swift
//  MusicProject
//
//  Created by Кирилл Володин on 24.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation
import RealmSwift

struct SongManager {
    static var backup: [Song] = []
    static var songs: [Song] = []
    static var images: [UIImage] = []
    static var index: Int = 0
    
    static func getIndex() -> Int {
        let result = SongManager.index
        return result
    }
    
    static func getPosition() -> Int? {
        
        if songs.isEmpty {
            return nil
        }
        let result = SongManager.songs[SongManager.getIndex()].position
        return result
        
    }
    
    static func setIndex(value: Int) {
        
        if value == -1 || SongManager.songs.isEmpty {
            SongManager.index = 0
        }
        else if value == SongManager.songs.count {
            SongManager.index = value - 1
        }
        else {
            SongManager.index = value
        }
    }
    
    static func getNextPosition() -> Int? {
        let index = getIndex() + 1
        setIndex(value: index)
        return getPosition()
    }
    
    static func getPreviousPosition() -> Int? {
        let index = getIndex() - 1
        setIndex(value: index)
        return getPosition()
    }
    
    static func setIndex(bySongPosition position: Int) {
        for (index, song) in songs.enumerated() {
            if song.position == position {
                setIndex(value: index)
                break
            }
        }
    }
    
    static func shuffleSongs() {
        let index = SongManager.getIndex()
        let position = songs[index].position
        SongManager.backup = SongManager.songs
        SongManager.songs.shuffle()
        SongManager.setIndex(bySongPosition: position)
    }
    
    static func normalizeSongs() {
        let index = SongManager.getIndex()
        let position = songs[index].position
        SongManager.songs = SongManager.backup
        SongManager.setIndex(bySongPosition: position)
    }
    
    static func getCurrentImage() -> UIImage? {
        if let position = getPosition() {
            return images[position - 1]
        }
        else {
            return UIImage(named: "default_album_v2")
        }
    }
    
}
