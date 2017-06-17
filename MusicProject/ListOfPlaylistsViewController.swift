//
//  ListOfPlaylistsViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class ListOfPlaylistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playlistsTable: UITableView!
    
    var playlists: Results<Playlist> = DatabaseManager.getPlaylists()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        playlistsTable.dataSource = self
        playlistsTable.delegate = self
        playlistsTable.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(getPlaylistsCallback(_:)), name: .getPlaylistsCallback, object: nil)
        APIManager.getPlaylistsRequest()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return playlists.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = playlistsTable.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell") as! PlaylistTableViewCell
        let index = indexPath.row
        cell.schoolName.text = playlists[index].schoolName
        cell.playlistImage.image = UIImage(named: "p_\(index+1)")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        let playlist = playlists[index]
        self.performSegue(withIdentifier: SegueRouter.toAudioPlayer.rawValue, sender: playlist)
        
    }
    
    func getPlaylistsCallback(_ notification: NSNotification) {
        
        let data = notification.userInfo as! [String : JSON]
        let playlists = data["playlists"]!.arrayValue
        for playlist in playlists {
            DatabaseManager.setPlaylist(json: playlist)
        }
        self.playlistsTable.reloadData()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueRouter.toAudioPlayer.rawValue {
            let destinationViewController = segue.destination as! TrackViewController
            destinationViewController.playlist = sender as? Playlist
        }
        
    }
    
}