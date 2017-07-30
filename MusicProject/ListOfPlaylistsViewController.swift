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
        setupUI()
        playlistsTable.dataSource = self
        playlistsTable.delegate = self
        playlistsTable.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(getPlaylistsCallback(_:)), name: .getPlaylistsCallback, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(getSongsCallback(_:)), name: .getSongsCallback, object: nil)
        APIManager.getPlaylistsRequest()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.black), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        playlistsTable.reloadData()
        
    }
    
    func setupUI() {
        
        let label = UILabel(frame: CGRect(x:0, y:0, width:100, height:100))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        //customize multiline text
        let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        let firstLine = NSMutableAttributedString(string:"DANCE FAMILY\n", attributes:firstAttributes)
        let secondAttributes =  [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        let secondLine = NSAttributedString(string:"MUSIC", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return playlists.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = playlistsTable.dequeueReusableCell(withIdentifier: "PlaylistTableViewCell") as! PlaylistTableViewCell
        let index = indexPath.row
        if SongManagerFactory.numberColoredPlaylist == index && SongManagerFactory.shouldColorPlaylist {
            cell.playlistLabel.textColor = UIColor.red
        }
        else {
            cell.playlistLabel.textColor = UIColor.white
        }
        cell.schoolName.text = playlists[index].schoolName
        cell.playlistImage.image = UIImage(named: "p_\(index % 17 + 1)")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        let playlist = playlists[index]
        if !playlist.songs.isEmpty {
            self.performSegue(withIdentifier: SegueRouter.toAudioPlayer.rawValue, sender: playlist)
            
            if SongManagerFactory.numberColoredPlaylist != index {
                SongManagerFactory.isSamePlaylist = false
            }
            else {
                SongManagerFactory.isSamePlaylist = true
            }
            
        }
        else {
            APIManager.getSongsRequest(playlist: playlist)
            showAlert()
        }
        
    }
    
    func showAlert() {

        let alert = UIAlertController(title: "", message: "В плейлисте нет песен", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func showAlertPlaylistsEmpty() {

        let alert = UIAlertController(title: "", message: "Список плейлистов пуст", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getPlaylistsCallback(_ notification: NSNotification) {
        
        let data = notification.userInfo as! [String : JSON]
        var IDs: [Int] = []
        let playlists = data["playlists"]!.arrayValue
        for playlist in playlists {
            DatabaseManager.setPlaylist(json: playlist)
            IDs.append(playlist["id"].int!)
        }
        DatabaseManager.removePlaylists(IDs: IDs)
        self.playlistsTable.reloadData()
        APIManager.hotLoad()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueRouter.toAudioPlayer.rawValue {
            let destinationViewController = segue.destination as! TrackViewController
            let playlist = sender as? Playlist
            destinationViewController.playlist = playlist
            TrackViewMode.mode = .fromListOfPlaylists
            
        }
        
    }
    
    func getSongsCallback(_ notification: NSNotification) {
        
        var IDs: [Int] = []
        let data = notification.userInfo?["data"] as! [String : JSON]
        let songs = data["songs"]!.arrayValue
        let playlist = notification.userInfo?["playlist"] as! Playlist
        for song in songs {
            DatabaseManager.setSong(json: song, playlist: playlist)
            IDs.append(song["id"].int!)
        }
        DatabaseManager.removeSongs(IDs: IDs, playlist: playlist)
    }
    
}
