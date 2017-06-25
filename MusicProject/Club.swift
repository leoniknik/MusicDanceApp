//
//  Club.swift
//  MusicProject
//
//  Created by Кирилл Володин on 25.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation

struct Club {
    
    var name: String
    var year: String
    var location: String
    var members: String
    var site: String
    var instagram: String
    var vk: String
    
    init(name: String, year: String, location: String, members: String, site: String, instagram: String, vk: String) {
        self.name = name
        self.year = year
        self.location = location
        self.members = members
        self.site = site
        self.instagram = instagram
        self.vk = vk
    }
    
}
