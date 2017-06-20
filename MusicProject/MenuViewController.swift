//
//  MenuViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 20.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuTable: UITableView!
    
    //let menu
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        menuTable.dataSource = self
        menuTable.delegate = self
        
    }

    func setupUI() {
        
        //transparent navigationbar
        
//        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        //self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.view.backgroundColor = UIColor.clear
        
        let bar: UINavigationBar! =  self.navigationController?.navigationBar
        
        bar.tintColor = UIColor.white
        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        bar.shadowImage = UIImage()
        bar.isTranslucent = true
        
        //transparent tableview
        menuTable.tableFooterView = UIView(frame: CGRect.zero)
        menuTable.backgroundColor = .clear
        menuTable.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = menuTable.dequeueReusableCell(withIdentifier: "MenuViewCell") as! MenuViewCell
        let index = indexPath.row
        
        return cell
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    //transparent cell
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = .clear
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = indexPath.row
        
        switch index {
            case 0: self.performSegue(withIdentifier: SegueRouter.toDanceFamily.rawValue, sender: nil)
            case 1: self.performSegue(withIdentifier: SegueRouter.toDanceFamily.rawValue, sender: nil)
            case 2: self.performSegue(withIdentifier: SegueRouter.toDanceFamily.rawValue, sender: nil)
            case 3: self.performSegue(withIdentifier: SegueRouter.toDanceFamily.rawValue, sender: nil)
            case 4: self.performSegue(withIdentifier: SegueRouter.toDanceFamily.rawValue, sender: nil)
            case 5: self.performSegue(withIdentifier: SegueRouter.toDanceFamily.rawValue, sender: nil)
            default: break
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == SegueRouter.toAudioPlayer.rawValue {
//            let destinationViewController = segue.destination as! TrackViewController
//            destinationViewController.playlist = sender as? Playlist
//            destinationViewController.viewMode = TrackViewMode.fromListOfPlaylists
//        }
        
    }
    
}
