//
//  MenuViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 20.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit
import StoreKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuTable: UITableView!
    
    var songs = DatabaseManager.getSavedSongs()
    
    struct Menu {
        var image: UIImage
        var title: String
        
        init(image: UIImage, title: String) {
            self.image = image
            self.title = title
        }
        
    }
    
    let menu: [Menu] = [
        Menu(image: UIImage(named: "ic_share_all")!, title: "Рассказать друзьям"),
        Menu(image: UIImage(named: "ic_info_menu")!, title: "Dance Family"),
        Menu(image: UIImage(named: "ic_rating_menu")!, title: "Закладки"),
        Menu(image: UIImage(named: "ic_like_menu")!, title: "Оценить приложение"),
        Menu(image: UIImage(named: "ic_email_menu")!, title: "Написать разработчикам")
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        menuTable.dataSource = self
        menuTable.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        //transparent navigationbar
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setupUI() {
        
        //transparent tableview
        menuTable.tableFooterView = UIView(frame: CGRect.zero)
        menuTable.backgroundColor = .clear
        menuTable.separatorStyle = .none
        
        //disable scrolling
        menuTable.isScrollEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return menu.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = menuTable.dequeueReusableCell(withIdentifier: "MenuViewCell") as! MenuViewCell
        let index = indexPath.row
        cell.icon.image = menu[index].image
        cell.title.text = menu[index].title
        cell.isHighlighted = false
        return cell
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //transparent cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = .clear
        
        //transparent selection of cell
        let view = UIView()
        view.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 0.35)
        cell.selectedBackgroundView = view
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let index = indexPath.row
        
        switch index {
        case 0: share(tableView: tableView, indexPath: indexPath)
        case 1: self.performSegue(withIdentifier: SegueRouter.toDanceFamily.rawValue, sender: nil)
        case 2: favorites()
        case 3: mark()
        case 4: self.performSegue(withIdentifier: SegueRouter.toMail.rawValue, sender: nil)
        default: break
        }
        
    }
    
    
    func share(tableView: UITableView, indexPath: IndexPath) {
        
            let textToShare = "Все клубы Dance Family в одном приложении!\nСкачай DF Music прямо сейчас\nhttps://itunes.apple.com/ru/app/df-music/id1265946456?mt=8"
        
            let objectsToShare = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.present(activityVC, animated: true, completion: nil)
            
            if let popView = activityVC.popoverPresentationController {
                popView.sourceView = tableView
                popView.sourceRect = tableView.cellForRow(at: indexPath)!.frame
            }

    }
    
    func mark() {
        SKStoreReviewController.requestReview()
    }
    
    func favorites() {
        
        songs = DatabaseManager.getSavedSongs()
        
        if songs.isEmpty {
            // create the alert
            let alert = UIAlertController(title: "", message: "Нет сохраненных песен", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.performSegue(withIdentifier: SegueRouter.fromMenuToTrack.rawValue, sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SegueRouter.fromMenuToTrack.rawValue {
            TrackViewMode.mode = .fromMenu
            let playlist = PlaylistDisplay()
            playlist.position = -1
            playlist.title = "ЗАКЛАДКИ"
            playlist.schoolName = "ЗАКЛАДКИ"
            
            var songsDisplay = [SongDisplay]()
            var index = 1
            for item in songs {
                let object = SongDisplay()
                object.id = item.id
                object.img_url = item.img_url
                object.isSaved = item.isSaved
                object.length = item.length
                object.playlist = playlist
                object.position = index
                object.singer = item.singer
                object.song_url = item.song_url
                object.title = item.title
                songsDisplay.append(object)
                index += 1
            }
            
            playlist.songs = songsDisplay
            
            let destinationController = segue.destination as! PlaylistViewController
            destinationController.playlist = playlist
            if SongManagerFactory.numberColoredPlaylist == -2 {
                SongManagerFactory.isSamePlaylist = false
            }
            else {
                SongManagerFactory.isSamePlaylist = false
            }
        }
        
    }
    
}
