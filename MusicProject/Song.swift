//
//  Song.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation
import RealmSwift

class Song: Object {
    
    dynamic var id: Int = 0
    dynamic var song_url: String = ""
    dynamic var title: String = ""
    dynamic var position: Int = 0
    dynamic var length: Int = 0
    dynamic var img_url: String = ""
    dynamic var singer: String = ""
    dynamic var playlist: Playlist?
    dynamic var isSaved: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
