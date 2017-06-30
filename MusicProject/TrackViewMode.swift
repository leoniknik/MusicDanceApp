//
//  TrackViewMode.swift
//  MusicProject
//
//  Created by Кирилл Володин on 17.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation

class TrackViewMode {
    
    static var mode: Mode = .fromListOfPlaylists
    
    enum Mode {
        case fromListOfPlaylists
        case fromMenu
    }
    
}
