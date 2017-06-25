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
import MediaPlayer
import Jukebox

//добавить блюр

class TrackViewController: UIViewController, JukeboxDelegate {

    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var playOrPauseButton: UIButton!
    @IBOutlet weak var nextSongButton: UIButton!
    @IBOutlet weak var previousSongButton: UIButton!
    @IBOutlet weak var downloadSongButton: UIButton!
    @IBOutlet weak var repeatSongButton: UIButton!
    
    @IBOutlet weak var playlistItem: UIBarButtonItem!
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    var playlist: Playlist?
    var song: Song?
    var viewMode: TrackViewMode?
    var jukebox : Jukebox!
    var repeatState: RepeatState = .off

    
    enum RepeatState {
        case on
        case off
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getSongsCallback(_:)), name: .getSongsCallback, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSongImageCallback(_:)), name: .getSongImageCallback, object: nil)
        
 
        SongManager.setIndex(value: 0)
        createPlaylist()
        //setupSong(position: Index.getIndex())
        APIManager.getSongsRequest(playlist: playlist!)
        
        UIApplication.shared.beginReceivingRemoteControlEvents()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //transparent navigationbar
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
    }

    
    func createPlaylist() {
        
        let SERVER_IP = APIManager.getServerIP()
        
        jukebox = Jukebox(delegate: self, items: [
            ])!
        
        let songs = DatabaseManager.getSongsOrderedByPosition(playlist: playlist!)
        SongManager.songs.removeAll()
        SongManager.setIndex(value: 0)
        for song in songs {
            jukebox.append(item: JukeboxItem (URL: URL(string: "\(SERVER_IP)\(song.song_url)")!), loadingAssets: true)
            SongManager.songs.append(song)
        }
        SongManager.backup = SongManager.songs
    }
    
    
    func setupUI() {
        
        resetUI()
        
        backgroundImage.addBlurEffect()
        
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
        let secondLine = NSAttributedString(string:"NOW PLAYING", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
        
        //customize thumb's size
        let upThumbImage: UIImage = UIImage(named: "circle-24")!
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContext(size)
        upThumbImage.draw(in: CGRect(x:0, y:0, width:size.width, height:size.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        songSlider.setThumbImage(resizeImage, for: .normal)
        
        songSlider.minimumTrackTintColor = UIColor.white
        songSlider.maximumTrackTintColor = UIColor.gray
        
        //initialization gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sliderTapped(gestureRecognizer:)))
        self.songSlider.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        print("Jukebox did load: \(item.URL.lastPathComponent)")
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            let value = Float(currentTime / duration)
            songSlider.value = value
            populateLabelWithTime(currentTimeLabel, time: currentTime)
            populateLabelWithTime(durationLabel, time: duration)
            
            //should pay next track or repeat
            if currentTimeLabel.text! == durationLabel.text! {
                if repeatState == .off {
                    let index = SongManager.getNextPosition()
                    jukebox.play(atIndex: index)
                }
                else {
                    jukebox.replayCurrentItem()
                }
            }
            
        } else {
            resetUI()
        }
    }
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
        if jukebox.state == .ready {
            playOrPauseButton.setImage(UIImage(named: "ic_play"), for: UIControlState())
        } else if jukebox.state == .loading  {
            playOrPauseButton.setImage(UIImage(named: "ic_pause"), for: UIControlState())
        } else {
            let imageName: String
            switch jukebox.state {
            case .playing, .loading:
                imageName = "ic_pause"
            case .paused, .failed, .ready:
                imageName = "ic_play"
            }
            playOrPauseButton.setImage(UIImage(named: imageName), for: UIControlState())
        }
        print("Jukebox state changed to \(jukebox.state)")
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        //print("Item updated:\n\(forItem)")
    }
    
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if event?.type == .remoteControl {
            switch event!.subtype {
            case .remoteControlPlay :
                jukebox.play()
            case .remoteControlPause :
                jukebox.pause()
            case .remoteControlNextTrack :
                let index = SongManager.getNextPosition()
                jukebox.play(atIndex: index)
            case .remoteControlPreviousTrack:
                let index = SongManager.getPreviousPosition()
                jukebox.play(atIndex: index)
            case .remoteControlTogglePlayPause:
                if jukebox.state == .playing {
                    jukebox.pause()
                } else {
                    jukebox.play()
                }
            default:
                break
            }
        }
        
    }
    
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    
    func getSongsCallback(_ notification: NSNotification) {
        
        let data = notification.userInfo as! [String : JSON]
        let songs = data["songs"]!.arrayValue
        for song in songs {
            DatabaseManager.setSong(json: song, playlist: playlist!)
        }
        //создать плейлист
        setupSong(position: 1)
        
    }

    
    func setupSong(position: Int) {
        
        if let songByPosition = DatabaseManager.getSongByPosition(playlist: playlist!, position: position) {
            song = songByPosition
            titleLabel.text = song?.title
            singerLabel.text = song?.singer
            APIManager.getSongImage(song: song!)
        }
                
    }
    
    func getSongImageCallback(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String : Any]
        let image = userInfo["image"]
        //проверка не поменялся ли трек
        songImage.image = image as? UIImage
        
    }
    
    
    @IBAction func playOrPause(_ sender: Any) {
        
        switch jukebox.state {
        case .ready :
            jukebox.play(atIndex: 0)
        case .playing :
            jukebox.pause()
        case .paused :
            jukebox.play()
        default:
            jukebox.stop()
        }
        
    }
    
    @IBAction func nextSong(_ sender: Any) {
        
        let index = SongManager.getNextPosition()
        jukebox.play(atIndex: index)
//        let posititon = jukebox.playIndex + 1
//        setupSong(position: posititon)
        
    }
    
    @IBAction func previousSong(_ sender: Any) {
        
        if jukebox.playIndex == 0 {
            jukebox.replayCurrentItem()
        } else {
            let index = SongManager.getPreviousPosition()
            jukebox.play(atIndex: index)
            
//            let posititon = jukebox.playIndex - 1
//            setupSong(position: posititon)
        }
        
    }
    
    @IBAction func repeatSong(_ sender: Any) {
        switch repeatState {
        case .off:
            repeatState = .on
            repeatSongButton.setImage(UIImage(named: "ic_repeat_on"), for: UIControlState())
        case .on:
            repeatState = .off
            repeatSongButton.setImage(UIImage(named: "ic_repeat_off"), for: UIControlState())
        }
    }
    
    @IBAction func downloadSong(_ sender: Any) {
        //загрузить в папку
    }
    
    @IBAction func songSliderValueChanged(_ sender: Any) {
        
        if let duration = jukebox.currentItem?.meta.duration {
            jukebox.seek(toSecond: Int(Double(songSlider.value) * duration))
        }
        
    }
    
    func resetUI() {
        
        durationLabel.text = "00:00"
        currentTimeLabel.text = "00:00"
        songSlider.value = 0
        
    }
    
    
    @IBAction func goToPlaylist(_ sender: Any) {
        
        self.performSegue(withIdentifier: SegueRouter.toPlaylist.rawValue, sender: playlist)
        
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        //когда выходим, что делать с треком?
        jukebox.stop()
        Shuffle.setOffState()
        SongManager.normalizeSongs()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueRouter.toPlaylist.rawValue {
            let destinationViewController = segue.destination as! PlaylistViewController
            destinationViewController.playlist = sender as? Playlist
//            destinationViewController.position = jukebox.playIndex
            destinationViewController.jukebox = jukebox
        }
        
    }

    //slider touch up for change value
    func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        let positionOfSlider: CGPoint = songSlider.frame.origin
        let widthOfSlider: CGFloat = songSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(songSlider.maximumValue) / widthOfSlider)
        
        if jukebox.state == .playing {
            jukebox.pause()
            if let duration = jukebox.currentItem?.meta.duration {
                jukebox.seek(toSecond: Int(Double(newValue) * duration))
                songSlider.setValue(Float(newValue), animated: true)
                populateLabelWithTime(currentTimeLabel, time: Double(newValue) * duration)
            }
            jukebox.play()
        }
        else if jukebox.state == .ready {
            jukebox.play()
            if let duration = jukebox.currentItem?.meta.duration {
                jukebox.seek(toSecond: Int(Double(newValue) * duration))
                songSlider.setValue(Float(newValue), animated: true)
                populateLabelWithTime(currentTimeLabel, time: Double(newValue) * duration)
            }
        }
        else {
            if let duration = jukebox.currentItem?.meta.duration {
                jukebox.seek(toSecond: Int(Double(newValue) * duration))
                songSlider.setValue(Float(newValue), animated: true)
                populateLabelWithTime(currentTimeLabel, time: Double(newValue) * duration)
            }
        }
    }
    
}
