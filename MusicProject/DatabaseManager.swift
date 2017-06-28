//
//  DatabaseManager.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class DatabaseManager {
    
    private static var realm = try! Realm()
    
    class func setFlagOn(song: ThreadSafeReference<Song>) {
        
        let realm = try! Realm()
        guard let song = realm.resolve(song) else {
            return
        }
        try! realm.write {
            let id = song.id
            let predicate = NSPredicate(format: "id == \(id)")
            if let newSong = realm.objects(Song.self).filter(predicate).first {
                newSong.isSaved = true
                realm.add(newSong, update: true)
            }
        }
        
    }
    
    
    class func setFlagOff(song: ThreadSafeReference<Song>) {
        
        let realm = try! Realm()
        guard let song = realm.resolve(song) else {
            return
        }
        try! realm.write {
            let id = song.id
            let predicate = NSPredicate(format: "id == \(id)")
            if let newSong = realm.objects(Song.self).filter(predicate).first {
                newSong.isSaved = false
                realm.add(newSong, update: true)
            }
        }
        
    }
    
//    class func getSongById(id: Int) -> Song? {
//        let predicate = NSPredicate(format: "id == \(id)")
//        return realm.objects(Song.self).filter(predicate).first
//    }
    
    class func setPlaylist(json: JSON) {
        
        let playlist = Playlist()
        playlist.id = json["id"].int!
        playlist.schoolName = json["school_owner"].string!
        playlist.lastUpdate = json["last_update"].int!
        playlist.position = json["pos"].int!
        playlist.title = json["title"].string!
        save(object: playlist)
        
    }
    
    
    class func setSong(json: JSON, playlist: Playlist) {
        
        let song = Song()
        song.id = json["id"].int!
        song.img_url = json["img_url"].string!
        song.length = json["length"].int!
        song.position = json["pos"].int!
        song.singer = json["singer"].string!
        song.song_url = json["song_url"].string!
        song.title = json["title"].string!
        
        let id = song.id
        let predicate = NSPredicate(format: "id == \(id)")
        if let oldSong = realm.objects(Song.self).filter(predicate).first {
            song.isSaved = oldSong.isSaved
        }
        else {
            song.isSaved = false
        }
        
        song.playlist = playlist
        save(object: song)
        
    }
    
    class func getPlaylists() -> Results<Playlist> {
        
        let predicate = NSPredicate(format: "id != 1000")
        return realm.objects(Playlist.self).sorted(byKeyPath: "position").filter(predicate)
        
    }
    
    class func getSongsOrderedByPosition(playlist: Playlist) -> Results<Song> {
        
        return playlist.songs.sorted(byKeyPath: "position")
        
    }
    
    class func getSongByPosition(playlist: Playlist, position: Int) -> Song? {
        let predicate = NSPredicate(format: "position == \(position)")
        return playlist.songs.filter(predicate).first
    }
    
    class func removePlaylists(IDs: [Int]) {
        
        let playlists = realm.objects(Playlist.self)
        for playlist in playlists {
            let ID = playlist.id
            if !(IDs.contains(ID)) && ID != 1000
            {
                try! realm.write {
                    realm.delete(playlist)
                }
            }
        }
        
    }
    
    class func removeSongs(IDs: [Int], playlist: Playlist) {
        
        let songs = playlist.songs
        for song in songs {
            let ID = song.id
            if !(IDs.contains(ID))
            {
                try! realm.write {
                    realm.delete(song)
                }
            }
        }
        
    }
    
    class func getSavedSongs() -> Results<Song> {
        
        let predicate = NSPredicate(format: "isSaved == true")
        return realm.objects(Song.self).filter(predicate)
        
    }
    
    private class func save(object: Object) {
        
        try! realm.write {
            realm.add(object, update: true)
        }
        
    }
}
