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

class TrackViewController: UIViewController, JukeboxDelegate, URLSessionDownloadDelegate {

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
    
    @IBOutlet weak var downdloadLabel: UILabel!
    @IBOutlet weak var progressDownloadIndicator: UIProgressView!
    
    //сохраненный плейлист
    //игра в бекграунде
    //icon 
    //разные экраны
    
    var playlist: Playlist?
    var song: Song?
    var viewMode: TrackViewMode?
    var jukebox : Jukebox!
    var repeatState: RepeatState = .off
    var tapGestureRecognizer: Any?
    var downloadTask: URLSessionDownloadTask?
    var songRef: ThreadSafeReference<Song>?
    var backgroundSession: URLSession!
    
    enum RepeatState {
        case on
        case off
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(getSongsCallback(_:)), name: .getSongsCallback, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getSongImageCallback(_:)), name: .getSongImageCallback, object: nil)
        
 
        SongManager.setIndex(value: 0)
        
//        if viewMode == .fromListOfPlaylists {
//            print(playlist!)
//          APIManager.getSongsRequest(playlist: playlist!)
//        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()

        //initialization gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.sliderTapped(gestureRecognizer:)))
        self.songSlider.addGestureRecognizer(tapGestureRecognizer as! UIGestureRecognizer)
        
        createPlaylist()
        
        if let position = SongManager.getPosition() {
            setupSong(position: position)
        }
        
        progressDownloadIndicator.setProgress(0.0, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
//        super.viewWillAppear(animated)
//        songImage.image = UIImage(named: "default_album_v2")
        
        //transparent navigationbar
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        if let position = SongManager.getPosition() {
            setupSong(position: position)
        }
        
        downdloadLabel.isHidden = true
        progressDownloadIndicator.isHidden = true
        progressDownloadIndicator.progress = 0.0
        
        //checkDownloadImage
        updateDownloadButton()

        
    }

    
    func createPlaylist() {
        
        let SERVER_IP = APIManager.getServerIP()
        
        jukebox = Jukebox(delegate: self, items: [
            ])!
        
        let songs: Results<Song>
        
        if viewMode == .fromListOfPlaylists {
            print(playlist!)
            songs = DatabaseManager.getSongsOrderedByPosition(playlist: playlist!)
        }
        else {
            songs = DatabaseManager.getSavedSongs()
        }
        SongManager.songs.removeAll()
        SongManager.images.removeAll()
        SongManager.setIndex(value: 0)
        for song in songs {
            jukebox.append(item: JukeboxItem (URL: URL(string: "\(SERVER_IP)\(song.song_url)")!), loadingAssets: false)
            SongManager.songs.append(song)
            SongManager.images.append(UIImage(named: "default_album_v2")!)
        }

        SongManager.backup = SongManager.songs
    }
    
    
    func setupUI() {
        
        resetUI()
        
        backgroundImage.addBlurEffect()
        var titlePlaylist = ""
        if viewMode == .fromListOfPlaylists {
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
            
            //should pay next track or repeat
            if currentTimeLabel.text! == durationLabel.text! {
                if repeatState == .off {
                    if let position = SongManager.getNextPosition() {
                        jukebox.play(atIndex: position - 1)
                        setupSong(position: position)
                    }
                    updateDownloadButton()
                    stopDowload()
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
                if let index = SongManager.getNextPosition() {
                    jukebox.play(atIndex: index)
                }
            case .remoteControlPreviousTrack:
                if let index = SongManager.getPreviousPosition() {
                    jukebox.play(atIndex: index)
                }
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
    
    
//    func getSongsCallback(_ notification: NSNotification) {
//        
//        var IDs: [Int] = []
//        let data = notification.userInfo?["data"] as! [String : JSON]
//        let songs = data["songs"]!.arrayValue
//        let playlist = notification.userInfo?["playlist"] as! Playlist
//        print(playlist)
//        for song in songs {
//            DatabaseManager.setSong(json: song, playlist: playlist)
//            IDs.append(song["id"].int!)
//        }
//        DatabaseManager.removeSongs(IDs: IDs, playlist: playlist)
//        if SongManager.songs.isEmpty {
//           self.playlist = playlist
//            createPlaylist()
//            setupSong(position: 1)
//        }
//        
//    }

    
    func setupSong(position: Int) {
        
        if let songByPosition = DatabaseManager.getSongByPosition(playlist: playlist!, position: position) {
            song = songByPosition
            print(song!)
            
            updateSongImage()
            APIManager.getSongImage(song: song!, position: position)
            
            updateUI()
        }
           
    }
    
    func updateUI() {
        if let song = song {
            
//            DispatchQueue.main.async {
                self.titleLabel.text = song.title
                self.singerLabel.text = song.singer
                self.populateLabelWithTime(self.durationLabel, time: Double(song.length))
//            }
        }
    }
    
    func updateSongImage() {
        if let image = SongManager.getCurrentImage() {
            songImage.image = image
        }
//        else {
//            songImage.image = UIImage(named: "default_album_v2")
//        }
    }
    
    
    func getSongImageCallback(_ notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String : Any]
        let image = userInfo["image"]
        let position = userInfo["position"] as! Int - 1
        //проверка не поменялся ли трек
        SongManager.images[position] = image as? UIImage ?? UIImage(named: "default_album_v2")!
        updateSongImage()
    }
    
    
    @IBAction func playOrPause(_ sender: Any) {
        
        switch jukebox.state {
        case .ready :
            if let position = SongManager.getPosition() {
                jukebox.play(atIndex: position - 1)
                setupSong(position: position)
            }
        case .playing :
            jukebox.pause()
        case .paused :
            jukebox.play()
        default:
            jukebox.stop()
        }
        
    }
    
    @IBAction func nextSong(_ sender: Any) {
        
        if let position = SongManager.getNextPosition() {
            jukebox.play(atIndex: position - 1)
            setupSong(position: position)
        }
        stopDowload()
        updateDownloadButton()
    }
    
    @IBAction func previousSong(_ sender: Any) {
        
        if let position = SongManager.getPreviousPosition() {
            jukebox.play(atIndex: position - 1)
            if position - 1 == 0 {
                jukebox.replayCurrentItem()
            }
            setupSong(position: position)
            }
        stopDowload()
        updateDownloadButton()
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
    
    
    
    @IBAction func songSliderValueChanged(_ sender: Any) {
        
        self.songSlider.removeGestureRecognizer(tapGestureRecognizer as! UIGestureRecognizer)
        if let duration = jukebox.currentItem?.meta.duration {
            jukebox.seek(toSecond: Int(Double(songSlider.value) * duration))
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
        stopDowload()
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
//        DispatchQueue.main.async {
            self.jukebox.stop()
//        }
        Shuffle.setOffState()
        SongManager.normalizeSongs()
        stopDowload()
//        SongManager.songs.removeAll()
//        SongManager.images.removeAll()

        //playlist = nil
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

    @IBAction func downloadSong(_ sender: Any) {
        
        let SERVER_IP = APIManager.getServerIP()
        if let song = song {
        if let audioUrl = URL(string: "\(SERVER_IP)\(song.song_url)") {
            if let localUrl = getFileLocalPathByUrl(audioUrl) {
                print("The file already exists at path: \(localUrl)")
                //songRef = ThreadSafeReference(to: song)
                removeSongFileLocally(audioUrl)
                //removeFromLocalPlaylist()
            }
            else {
                startDownload(audioUrl: audioUrl)
            }
        }
        }
    }
    
    func getFileLocalPathByUrl(_ fileUrl: URL) -> URL? {
        // create your document folder url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // your destination file url
        let fileName = fileUrl.lastPathComponent
            // your destination file url
        let destinationUrl = documentsUrl.appendingPathComponent(fileName)
            
        if FileManager().fileExists(atPath: destinationUrl.path) {
            return destinationUrl
        }
        return nil
    }
    
    // #MARK: - NSURLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("download task did resume")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
         print("download task did finish")
        
        let audioUrl = downloadTask.originalRequest?.url
        
        if let data = try? Data(contentsOf: location) {
            storeFileLocally(remoteFileUrl: audioUrl! as NSURL, data)
            
            DispatchQueue.main.async {
                self.downdloadLabel.isHidden = true
                self.progressDownloadIndicator.isHidden = true
                self.progressDownloadIndicator.progress = 0.0
                self.downloadSongButton.setImage(UIImage(named: "ic_save_on"), for: UIControlState())
            }
        }
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        progressDownloadIndicator.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("error")
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        DispatchQueue.main.async {
            self.progressDownloadIndicator.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
            
        }
        
    }
    
    func storeFileLocally(remoteFileUrl: NSURL, _ data: Data?) {
        // create your document folder url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // your destination file url
        if let fileName = remoteFileUrl.lastPathComponent {
            let destinationUrl = documentsUrl.appendingPathComponent(fileName)
            
            if let data = data {
                do {
                    try data.write(to: destinationUrl, options: Data.WritingOptions.atomicWrite)
                    print("file saved at \(destinationUrl)")
                    //set saved flag
                       // addToLocalPlaylist()
//                        downloadTask = nil
                }
                catch {
                    print(error)
                }
            }
        }
        else {
            print("fileName is nil")
        }
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        stopDowload()
//        
//    }
    
    func startDownload(audioUrl: URL) {
        
            if downloadTask == nil {
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
                backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
                downloadTask = backgroundSession.downloadTask(with: audioUrl)
                downdloadLabel.isHidden = false
                progressDownloadIndicator.isHidden = false
                downloadTask!.resume()
                print(song!)
                //songRef = ThreadSafeReference(to: song!)
        }
        
    }
    
    func stopDowload() {
        
        self.downdloadLabel.isHidden = true
        self.progressDownloadIndicator.isHidden = true
        self.progressDownloadIndicator.progress = 0.0
        if downloadTask != nil{
            downloadTask!.cancel()
        }
        self.backgroundSession.invalidateAndCancel()
        
    }
    
    func removeSongFileLocally(_ fileUrl: URL) {
        
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // your destination file url
        let fileName = fileUrl.lastPathComponent
        // your destination file url
        let destinationUrl = documentsUrl.appendingPathComponent(fileName)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            
            do {
                try FileManager().removeItem(at: destinationUrl)
            }
            catch {
                print(error)
            }
        }
        updateDownloadButton()
    }
    
    func addToLocalPlaylist() {
        
        if let song = songRef {
            DatabaseManager.setFlagOn(song: song)
        }
        
    }
    
    func removeFromLocalPlaylist() {
        if let song = songRef {
            DatabaseManager.setFlagOff(song: song)
        }
    }
    
    func updateDownloadButton () {
        
        let SERVER_IP = APIManager.getServerIP()
        
        if let songURL = song?.song_url {
            if let audioUrl = URL(string: "\(SERVER_IP)\(songURL)") {
                if getFileLocalPathByUrl(audioUrl) != nil {
                    downloadSongButton.setImage(UIImage(named: "ic_save_on"), for: UIControlState())
                }
                else {
                    downloadSongButton.setImage(UIImage(named: "ic_save_off"), for: UIControlState())
                }
            }
        }
    }
}
