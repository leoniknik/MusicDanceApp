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

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var songsTable: UITableView!
    
    enum ShuffleState {
        case on
        case off
    }
    
    var playlist: Playlist?
    var songs: Results<Song>?
    var position: Int?
    var jukebox: Jukebox!
    var shuffleState: ShuffleState = .off

    override func viewDidLoad() {
        
        super.viewDidLoad()
        songsTable.dataSource = self
        songsTable.delegate = self
        songsTable.separatorStyle = .none
        songs = DatabaseManager.getSongsOrderedByPosition(playlist: playlist!)
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //transparent navigationbar
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func setupUI() {
        
        //transparent tableview
        songsTable.tableFooterView = UIView(frame: CGRect.zero)
        songsTable.backgroundColor = .clear
        songsTable.separatorStyle = .none
        
        //multiline title
        let titlePlaylist = playlist!.schoolName
        
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
        
        return songs!.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = songsTable.dequeueReusableCell(withIdentifier: "SongViewCell") as! SongViewCell
        let index = indexPath.row
        if index == position {
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
        cell.name.text = songs![index].title
        let time = songs![index].length
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        cell.duration.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
        cell.isHighlighted = false
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        self.navigationController?.popViewController(animated: true)
        let previousController = self.navigationController?.topViewController as! TrackViewController
        let position = songs![index].position
        let juckboxItemPosition = position - 1
        let songPosition = position
        previousController.jukebox.play(atIndex: juckboxItemPosition)
        previousController.setupSong(position: songPosition)
        
    }
    
    
    @IBAction func shuffle(_ sender: Any) {
        var juckboxItems: [JukeboxItem] = []
        for item in jukebox.queuedItems {
            juckboxItems.append(item)
        }
        juckboxItems.shuffle()
        
    }
    
    
}
