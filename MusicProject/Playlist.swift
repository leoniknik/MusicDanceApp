//
//  Playlist.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation
import RealmSwift

class Playlist: Object {
    
    dynamic var id: Int = 0
    dynamic var schoolName: String = ""
    dynamic var lastUpdate: Int = 0
    dynamic var position: Int = 0
    dynamic var title: String = ""
//    let songs = LinkingObjects(fromType: Song.self, property: "playlist")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
//    override static func ignoredProperties() -> [String] {
//        return ["tmpID"]
//    }

}

class PlaylistDisplay {
    var id: Int = 0
    var schoolName: String = ""
    var lastUpdate: Int = 0
    var position: Int = 0
    var title: String = ""
    var songs = [SongDisplay]()
}

