//
//  PlaylistViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit
import RealmSwift
import Jukebox
import SwiftyJSON

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var songsTable: UITableView!
    @IBOutlet weak var shuffleItem: UIBarButtonItem!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var playlist: PlaylistDisplay!
//    var jukebox: Jukebox?
    var songManager: SongManager!
    var isFromTrack = false
    var createPlaylistTask: DispatchWorkItem?
    var finish = false
    var transite = true

    override func viewDidLoad() {
        
        super.viewDidLoad()
        songManager = SongManagerFactory.getSongManager()

        songsTable.delegate = self
        songsTable.separatorStyle = .none
        songsTable.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: .playNextSong, object: nil)
        
        startCreatePlaylistTask()
        
    }
    
    
    func startCreatePlaylistTask() {
        if !SongManagerFactory.isSamePlaylist {
            createPlaylistTask = DispatchWorkItem { [weak self] in
                if self?.createPlaylistTask?.isCancelled ?? true {
                    return
                }
                
                let SERVER_IP = APIManager.getServerIP()
                self?.songManager.jukebox = Jukebox(delegate: nil, items: [
                    ])!
                
                let songs: [SongDisplay] = self?.playlist.songs ?? []
                
                self?.songManager.songs.removeAll()
                self?.songManager.images.removeAll()
                self?.songManager.setIndex(value: 0)
                
                for song in songs {
                    if self?.createPlaylistTask?.isCancelled ?? true {
                        return
                    }
                    var urlString = "\(SERVER_IP)\(song.song_url)"
                    urlString = urlString.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
                    guard let url = URL(string : urlString) else {
                        continue
                    }
                    if self?.createPlaylistTask?.isCancelled ?? true {
                        return
                    }
                    self?.songManager.jukebox.append(item: JukeboxItem(URL: url), loadingAssets: true)
                    if self?.createPlaylistTask?.isCancelled ?? true {
                        return
                    }
                    self?.songManager.addSong(song: song)
                    if self?.createPlaylistTask?.isCancelled ?? true {
                        return
                    }
                    self?.songManager.images.append(UIImage(named: "default_album_v2")!)
                }
                self?.songManager.backup = self?.songManager.songs ?? []
                
                DispatchQueue.main.async { [weak self] in
                    self?.finish = true
                    self?.songsTable.reloadData()
                }
            }
            
            if let task = createPlaylistTask {
                DispatchQueue.global(qos: .userInitiated).async(execute: task)
            }
        }
        else {
            finish = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        if isFromTrack {
            songsTable.reloadData()
        }
        isFromTrack = false
        transite = true
        //transparent navigationbar
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }

    
    @IBAction func goBack(_ sender: Any) {
        if (TrackViewMode.mode == .fromMenu) {
            songManager.jukebox.stop()
        }
        createPlaylistTask?.cancel()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupUI() {
        
        backgroundImage.addBlurEffect()
        
        //transparent tableview
        songsTable.tableFooterView = UIView(frame: CGRect.zero)
        songsTable.backgroundColor = .clear
        songsTable.separatorStyle = .none
        
        var titlePlaylist = ""
        //multiline title
        if let playlist = playlist {
            titlePlaylist = playlist.schoolName.uppercased()
        }
        else {
            titlePlaylist = "SAVED SONGS"
        }
        
        let label = UILabel(frame: CGRect(x:0, y:0, width:100, height:100))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        //customize multiline text for navigationbar title
        let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        let firstLine = NSMutableAttributedString(string:"\(titlePlaylist)\n", attributes:firstAttributes)
        let secondAttributes =  [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        let secondLine = NSAttributedString(string:"PLAYLIST", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
        
        //baritem
        if SongManagerFactory.isSamePlaylist {
            if songManager.shuffleState == .off {
                shuffleItem.image = UIImage(named: "ic_shuffle_off")
            }
            else {
                shuffleItem.image = UIImage(named: "ic_shuffle_on")
            }
        }
        else {
            shuffleItem.image = UIImage(named: "ic_shuffle_off")
        }

    }
    
    //transparent cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = .clear
        
        //transparent selection of cell
        let view = UIView()
        view.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 0.35)
        cell.selectedBackgroundView = view
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !finish {
            return 0
        }
        return songManager.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = songsTable.dequeueReusableCell(withIdentifier: "SongViewCell") as! SongViewCell
        let index = indexPath.row
        
        songManager = SongManagerFactory.getSongManager()
        
        if index == songManager.getIndex() {
            cell.number.textColor = UIColor.red
            cell.name.textColor = UIColor.red
            cell.duration.textColor = UIColor.red
        }
        else {
            cell.number.textColor = UIColor.white
            cell.name.textColor = UIColor.white
            cell.duration.textColor = UIColor.white
        }
        cell.number.text = "\(index + 1)"
        cell.name.text = songManager.songs[index].song.title
        let time = songManager.songs[index].song.length
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        cell.duration.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        cell.isHighlighted = false
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if transite {
            self.performSegue(withIdentifier: SegueRouter.toTrack.rawValue, sender: index as Any?)
            transite = false
        }
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueRouter.toTrack.rawValue {
            
            let destinationViewController = segue.destination as! TrackViewController
            let index = sender as! Int
            
            let position = songManager.songs[index].position
            songManager.setIndex(bySongPosition: position)
            let juckboxItemPosition = songManager.songs[songManager.getIndex()].position - 1
            
            if !SongManagerFactory.isSamePlaylist {
                SongManagerFactory.copyJukebox()
            }
            
            destinationViewController.songManager = SongManagerFactory.getSongManager()
            destinationViewController.playlist = playlist
            
            destinationViewController.songManager.jukebox.play(atIndex: juckboxItemPosition)
            SongManagerFactory.shouldColorPlaylist = true
            SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
            
        }
        
    }
    
    
    @IBAction func shuffle(_ sender: Any) {
        if songManager.shuffleState == .off {
            songManager.shuffleSongs()
            songManager.shuffleState = .on
            shuffleItem.image = UIImage(named: "ic_shuffle_on")
        }
        else {
            songManager.shuffleState = .off
            songManager.normalizeSongs()
            shuffleItem.image = UIImage(named: "ic_shuffle_off")
        }
        songsTable.reloadData()
    }
    
    func updateUI(_ notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            self?.songsTable.reloadData()
        }
    }
    
}
