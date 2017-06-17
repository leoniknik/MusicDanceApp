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
    
    private static let realm = try! Realm()
    
    
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
        song.playlist = playlist
        save(object: song)
        
    }
    
    
    class func getPlaylists() -> Results<Playlist> {
        
        return realm.objects(Playlist.self).sorted(byKeyPath: "position")
        
    }
    
    
    class func getFirstSong(playlist: Playlist) -> Song {
        
        return playlist.songs.sorted(byKeyPath: "position").first!
        
    }
    
    
    private class func save(object: Object) {
        
        try! realm.write {
            realm.add(object, update: true)
        }
        
    }
}
