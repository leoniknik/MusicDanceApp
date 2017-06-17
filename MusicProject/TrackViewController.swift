//
//  TrackViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import AudioPlayerSwift

class TrackViewController: UIViewController {

    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var songImage: UIImageView!
    
    
    var playlist: Playlist?
    var song: Song?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(getSongsCallback(_:)), name: .getSongsCallback, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSongImageCallback(_:)), name: .getSongImageCallback, object: nil)
        APIManager.getSongsRequest(playlist: playlist!)
        
    }

    
    func getSongsCallback(_ notification: NSNotification) {
        
        let data = notification.userInfo as! [String : JSON]
        let songs = data["songs"]!.arrayValue
        for song in songs {
            DatabaseManager.setSong(json: song, playlist: playlist!)
        }
        refreshView()
        
    }

    
    func refreshView() {
        
        song = DatabaseManager.getFirstSong(playlist: playlist!)
        titleLabel.text = song?.title
        singerLabel.text = song?.singer
        APIManager.getSongImage(song: song!)
                
    }
    
    func getSongImageCallback(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String : Any]
        let image = userInfo["image"]
        songImage.image = image as? UIImage
        
    }
    
}
