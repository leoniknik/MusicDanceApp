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
import MediaPlayer
import Jukebox

class ListOfPlaylistsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playlistsTable: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var topTableConstraint: NSLayoutConstraint!

    var playlists = [PlaylistDisplay]()
    var results = [Int]()
    
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        playlistsTable.dataSource = self
        playlistsTable.delegate = self
        playlistsTable.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(getPlaylistsCallback(_:)), name: .getPlaylistsCallback, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getPlaylistsCallbackError(_:)), name: .getPlaylistsCallbackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSongsCallback(_:)), name: .getSongsCallback, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSongsCallbackError(_:)), name: .getSongsCallbackError, object: nil)

        
        setupRefreshView()
        
        self.playlistsTable.setContentOffset(CGPoint(x: 0, y: self.playlistsTable.contentOffset.y-self.refreshControl.frame.size.height), animated: false)
        self.refreshControl.beginRefreshing()
        getUpdate()
    }
    
    func setupNavbar() {
        UIApplication.shared.statusBarStyle = .lightContent
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: UIColor.black), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavbar()
        updateRefreshControl()
        playlistsTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupRefreshView() {
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(getUpdate), for: .valueChanged)
        //добавление активити для обновления
        playlistsTable.refreshControl = refreshControl
    }
    
    func getUpdate() {
        DispatchQueue.global(qos: .userInitiated).async {
            APIManager.getPlaylistsRequest()
        }
    }
    
    func updateRefreshControl() {
        if (self.playlistsTable.refreshControl?.isRefreshing ?? false) {
            let offset = self.playlistsTable.contentOffset
            self.playlistsTable.refreshControl?.endRefreshing()
            self.playlistsTable.refreshControl?.beginRefreshing()
            self.playlistsTable.contentOffset = offset
        }
    }
    
    func setupUI() {
        
        //make black background
        playlistsTable.backgroundColor = UIColor.black
        
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
        cell.schoolName.text = playlists[index].schoolName.uppercased()
        cell.playlistImage.image = UIImage(named: "p_\(index % 17 + 1)")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        let playlist = playlists[index]
        self.performSegue(withIdentifier: SegueRouter.toPlaylist.rawValue, sender: playlist)
            
        if SongManagerFactory.numberColoredPlaylist != index {
            SongManagerFactory.isSamePlaylist = false
        }
        else {
            SongManagerFactory.isSamePlaylist = true
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
        guard let json = data["playlists"]?.arrayValue else {
            return
        }
        for item in json {
            let playlist = PlaylistDisplay()
            guard let id = item["id"].int, let schoolName = item["school_owner"].string, let lastUpdate = item["last_update"].int, let position = item["pos"].int, let title = item["title"].string else {
                continue
            }
            playlist.id = id
            playlist.schoolName = schoolName
            playlist.lastUpdate = lastUpdate
            playlist.position = position
            playlist.title = title
            playlists.append(playlist)
            
        }
        
        for playlist in playlists {
            DispatchQueue.global(qos: .userInitiated).async {
                APIManager.getSongsRequest(playlist: playlist)
            }
        }
    }
    
    func getPlaylistsCallbackError(_ notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.errorLabel.isHidden = false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueRouter.toPlaylist.rawValue {
            let destinationViewController = segue.destination as! PlaylistViewController
            let playlist = sender as? PlaylistDisplay
            destinationViewController.playlist = playlist
            TrackViewMode.mode = .fromListOfPlaylists
        }
        
    }
    
    func getSongsCallback(_ notification: NSNotification) {
        
        let data = notification.userInfo?["data"] as! [String : JSON]
        let songs = data["songs"]!.arrayValue
        let playlist = notification.userInfo?["playlist"] as! PlaylistDisplay
        for item in songs {
            let song = SongDisplay()
            song.id = item["id"].int!
            song.img_url = item["img_url"].string!
            song.length = item["length"].int!
            song.position = item["pos"].int!
            song.singer = item["singer"].string!
            song.song_url = item["song_url"].string!
            song.title = item["title"].string!
            playlist.songs.append(song)
        }
        checkFinishLoading()
    }
    
    func getSongsCallbackError(_ notification: NSNotification) {
        checkFinishLoading()
    }
    
    func checkFinishLoading() {
        results.append(1)
        if results.count == playlists.count {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl.endRefreshing()
                self?.playlistsTable.refreshControl?.removeFromSuperview()
                self?.playlistsTable.reloadData()
                self?.errorLabel.isHidden = true
            }
            
        }
    }
    
    
}
