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
    @IBOutlet weak var markSongButton: UIButton!
    @IBOutlet weak var repeatSongButton: UIButton!
    
    @IBOutlet weak var playlistItem: UIBarButtonItem!
    @IBOutlet weak var backItem: UIBarButtonItem!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var playlist: Playlist?
    var song: Song?
    var tapGestureRecognizer: Any?
    //var downloadTask: URLSessionDownloadTask?
    var songRef: ThreadSafeReference<Song>?
    //var backgroundSession: URLSession!
    var songManager: SongManager!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        songManager = SongManagerFactory.getSongManager()
        setupRepeat()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getSongImageCallback(_:)), name: .getSongImageCallback, object: nil)
        
        //initialization gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sliderTapped(gestureRecognizer:)))
        self.songSlider.addGestureRecognizer(tapGestureRecognizer as! UIGestureRecognizer)
        
        if !SongManagerFactory.isSamePlaylist {
            createPlaylist()

        }
        else {
            if let currentTime = songManager.jukebox.currentItem?.currentTime, let duration = songManager.jukebox.currentItem?.meta.duration {
                let value = Float(currentTime / duration)
                songSlider.value = value
                populateLabelWithTime(currentTimeLabel, time: currentTime)
                populateLabelWithTime(durationLabel, time: duration)
            }
        }
        
        if SongManagerFactory.isSamePlaylist {
            songManager.jukebox.delegate = self
            setupPlayOrPauseButton(songManager.jukebox)
        }
        
        if let position = songManager.getPosition() {
            setupSong(position: position)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //transparent navigationbar
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        if let position = songManager.getPosition() {
            setupSong(position: position)
        }
        
        //checkDownloadImage
        updateMarkButton()
        
        if SongManagerFactory.isSamePlaylist {
            songManager.jukebox.delegate = self
            setupPlayOrPauseButton(songManager.jukebox)
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        
        if SongManagerFactory.isSamePlaylist {
            songManager.jukebox.delegate = songManager
        }
        
    }
    
    func createPlaylist() {
        
        let SERVER_IP = APIManager.getServerIP()
        
        songManager.jukebox = Jukebox(delegate: self, items: [
            ])!
        
        let songs: Results<Song>
        
        if TrackViewMode.mode == .fromListOfPlaylists {
            songs = DatabaseManager.getSongsOrderedByPosition(playlist: playlist!)
        }
        else {
            songs = DatabaseManager.getSavedSongs()
        }
        songManager.songs.removeAll()
        songManager.images.removeAll()
        songManager.setIndex(value: 0)
        
        for song in songs {
            var urlString = "\(SERVER_IP)\(song.song_url)"
            urlString = urlString.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
            let url = URL(string : urlString)!
            
            songManager.jukebox.append(item: JukeboxItem(URL: url), loadingAssets: false)
        
            songManager.addSong(song: song)
            songManager.images.append(UIImage(named: "default_album_v2")!)
        }

        songManager.backup = songManager.songs
        
    }
    
    func setupRepeat() {
        switch SongManagerFactory.repeatState {
        case .on:
            repeatSongButton.setImage(UIImage(named: "ic_repeat_on"), for: UIControlState())
        case .off:
            repeatSongButton.setImage(UIImage(named: "ic_repeat_off"), for: UIControlState())
        }
    }
    
    func setupUI() {
        
        resetUI()
        backgroundImage.addBlurEffect()
        
        var titlePlaylist = ""
        if TrackViewMode.mode == .fromListOfPlaylists {
            titlePlaylist = playlist!.schoolName
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
            
            //update infoCenter
            jukebox.updateInfoCenter()
            
            if currentTimeLabel.text == durationLabel.text {
                if SongManagerFactory.repeatState == .off {
                    
                    if let position = songManager.getNextPosition() {
                        jukebox.play(atIndex: position - 1)
                        setupSong(position: position)
                    }
                    updateMarkButton()
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
        
        setupPlayOrPauseButton(jukebox)
        print("Jukebox state changed to \(jukebox.state)")
        
    }
    
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        
    }
    
    func setupPlayOrPauseButton(_ jukebox: Jukebox) {
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
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        
        if event?.type == .remoteControl {
            switch event!.subtype {
            case .remoteControlPlay :
                
                if !SongManagerFactory.isSamePlaylist {
                    SongManagerFactory.copyJukebox()
                    songManager = SongManagerFactory.getSongManager()
                }
                
                songManager.jukebox.play()
                SongManagerFactory.shouldColorPlaylist = true
                SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
            case .remoteControlPause :
                songManager.jukebox.pause()
                SongManagerFactory.shouldColorPlaylist = false
                //SongManagerFactory.numberColoredPlaylist = -1
            case .remoteControlNextTrack :
                if let position = songManager.getNextPosition() {
                    
                    if !SongManagerFactory.isSamePlaylist {
                        SongManagerFactory.copyJukebox()
                        songManager = SongManagerFactory.getSongManager()
                    }
                    
                    songManager.jukebox.play(atIndex: position - 1)
                    SongManagerFactory.shouldColorPlaylist = true
                    SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
                    setupSong(position: position)
                }
                updateMarkButton()
            case .remoteControlPreviousTrack:
                
                if !SongManagerFactory.isSamePlaylist {
                    SongManagerFactory.copyJukebox()
                    songManager = SongManagerFactory.getSongManager()
                }
                
                if let position = songManager.getPreviousPosition() {
                    songManager.jukebox.play(atIndex: position - 1)
                    if position - 1 == 0 {
                        songManager.jukebox.replayCurrentItem()
                    }
                    SongManagerFactory.shouldColorPlaylist = true
                    SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
                    setupSong(position: position)
                }
                updateMarkButton()
            case .remoteControlTogglePlayPause:
                if songManager.jukebox.state == .playing {
                    songManager.jukebox.pause()
                    SongManagerFactory.shouldColorPlaylist = false
                    //SongManagerFactory.numberColoredPlaylist = -1
                } else {
                    
                    if !SongManagerFactory.isSamePlaylist {
                        SongManagerFactory.copyJukebox()
                        songManager = SongManagerFactory.getSongManager()
                    }
                    
                    songManager.jukebox.play()
                    SongManagerFactory.shouldColorPlaylist = true
                    SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
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

    
    func setupSong(position: Int) {
        
        if TrackViewMode.mode == .fromListOfPlaylists {
            if let songByPosition = DatabaseManager.getSongByPosition(playlist: playlist!, position: position) {
                song = songByPosition
                print(song!)
            
                updateSongImage()
                APIManager.getSongImage(song: song!, position: position)
            
                updateUI()
            }
        }
        else {
            if let songByPosition = songManager.getSong(byPosition: position) {
                song = songByPosition
                print(song!)
                updateSongImage()
                APIManager.getSongImage(song: song!, position: position)
                updateUI()
            }
        }

    }
    
    func updateUI() {
        if let song = song {
            self.titleLabel.text = song.title
            self.singerLabel.text = song.singer
            self.populateLabelWithTime(self.durationLabel, time: Double(song.length))
        }
    }
    
    func updateSongImage() {
        if let image = songManager.getCurrentImage() {
            songImage.image = image
        }
    }
    
    
    func getSongImageCallback(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String : Any]
        let image = userInfo["image"]
        let position = userInfo["position"] as! Int - 1
        songManager.images[position] = image as? UIImage ?? UIImage(named: "default_album_v2")!
        updateSongImage()
    }
    

    @IBAction func playOrPause(_ sender: Any) {
        
        switch songManager.jukebox.state {
        case .ready :
            if let position = songManager.getPosition() {
                
                if !SongManagerFactory.isSamePlaylist {
                    SongManagerFactory.copyJukebox()
                    songManager = SongManagerFactory.getSongManager()
                }
                
                songManager.jukebox.play(atIndex: position - 1)
                SongManagerFactory.shouldColorPlaylist = true
                SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
                setupSong(position: position)

            }
        case .playing :
            songManager.jukebox.pause()
            SongManagerFactory.shouldColorPlaylist = false
            //SongManagerFactory.numberColoredPlaylist = -1
        case .paused :
            
            if !SongManagerFactory.isSamePlaylist {
                SongManagerFactory.copyJukebox()
                songManager = SongManagerFactory.getSongManager()
            }
            
            songManager.jukebox.play()
            SongManagerFactory.shouldColorPlaylist = true
            SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
        default:
            songManager.jukebox.stop()
            SongManagerFactory.shouldColorPlaylist = false
            //SongManagerFactory.numberColoredPlaylist = -1
        }
        
    }
    
    @IBAction func nextSong(_ sender: Any) {
        
        if !SongManagerFactory.isSamePlaylist {
            SongManagerFactory.copyJukebox()
            songManager = SongManagerFactory.getSongManager()
            print(songManager.name)
        }
        
        if let position = songManager.getNextPosition() {
            
            if position-1 != songManager.jukebox.playIndex {
                songManager.jukebox.play(atIndex: position - 1)
                resetUI()
                SongManagerFactory.shouldColorPlaylist = true
                SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
                setupSong(position: position)
            }
        }
        
        updateMarkButton()
        
    }
    
    @IBAction func previousSong(_ sender: Any) {
        
        resetUI()
        if !SongManagerFactory.isSamePlaylist {
            SongManagerFactory.copyJukebox()
            songManager = SongManagerFactory.getSongManager()
        }
        
        if let position = songManager.getPreviousPosition() {
            songManager.jukebox.play(atIndex: position - 1)
            SongManagerFactory.shouldColorPlaylist = true
            SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
            if position - 1 == 0 {
                songManager.jukebox.replayCurrentItem()
            }
            setupSong(position: position)
            }
        updateMarkButton()
        
    }
    
    @IBAction func repeatSong(_ sender: Any) {
        switch SongManagerFactory.repeatState {
        case .off:
            SongManagerFactory.repeatState = .on
            repeatSongButton.setImage(UIImage(named: "ic_repeat_on"), for: UIControlState())
        case .on:
            SongManagerFactory.repeatState = .off
            repeatSongButton.setImage(UIImage(named: "ic_repeat_off"), for: UIControlState())
        }
    }
    
    
    
    @IBAction func songSliderValueChanged(_ sender: Any) {
        
        self.songSlider.removeGestureRecognizer(tapGestureRecognizer as! UIGestureRecognizer)
        if let duration = songManager.jukebox.currentItem?.meta.duration {
            songManager.jukebox.seek(toSecond: Int(Double(songSlider.value) * duration))
        }
        self.songSlider.addGestureRecognizer(tapGestureRecognizer as! UIGestureRecognizer)
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

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueRouter.toPlaylist.rawValue {
            let destinationViewController = segue.destination as! PlaylistViewController
            destinationViewController.playlist = sender as? Playlist
            destinationViewController.jukebox = songManager.jukebox
        }
        
    }

    //slider touch up for change value
    func sliderTapped(gestureRecognizer: UIGestureRecognizer) {
        
        let pointTapped: CGPoint = gestureRecognizer.location(in: self.view)
        let positionOfSlider: CGPoint = songSlider.frame.origin
        let widthOfSlider: CGFloat = songSlider.frame.size.width
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(songSlider.maximumValue) / widthOfSlider)
        
        if !SongManagerFactory.isSamePlaylist {
            SongManagerFactory.copyJukebox()
            songManager = SongManagerFactory.getSongManager()
        }
        
        if songManager.jukebox.state == .playing {
            songManager.jukebox.pause()
            if let duration = songManager.jukebox.currentItem?.meta.duration {
                songManager.jukebox.seek(toSecond: Int(Double(newValue) * duration))
                songSlider.setValue(Float(newValue), animated: true)
                populateLabelWithTime(currentTimeLabel, time: Double(newValue) * duration)
            }
            songManager.jukebox.play()
            SongManagerFactory.shouldColorPlaylist = true
            SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
        }
        else if songManager.jukebox.state == .ready {
            songManager.jukebox.play()
            SongManagerFactory.shouldColorPlaylist = true
            SongManagerFactory.numberColoredPlaylist = playlist!.position - 1
            if let duration = songManager.jukebox.currentItem?.meta.duration {
                songManager.jukebox.seek(toSecond: Int(Double(newValue) * duration))
                songSlider.setValue(Float(newValue), animated: true)
                populateLabelWithTime(currentTimeLabel, time: Double(newValue) * duration)
            }
        }
        else {
            if let duration = songManager.jukebox.currentItem?.meta.duration {
                songManager.jukebox.seek(toSecond: Int(Double(newValue) * duration))
                songSlider.setValue(Float(newValue), animated: true)
                populateLabelWithTime(currentTimeLabel, time: Double(newValue) * duration)
            }
        }
    }

    @IBAction func markSong(_ sender: Any) {
        
        if let song = song {
            if song.isSaved {
                DatabaseManager.setFlagOff(song: song)
            }
            else {
                DatabaseManager.setFlagOn(song: song)
            }
            updateMarkButton()
        }
        
    }
    
    func updateMarkButton () {
        if song!.isSaved {
            markSongButton.setImage(UIImage(named: "ic_grade_on"), for: UIControlState())
        }
        else {
            markSongButton.setImage(UIImage(named: "ic_grade_off"), for: UIControlState())
        }
    }
}
