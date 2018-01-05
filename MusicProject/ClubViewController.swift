//
//  ClubViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 25.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class ClubViewController: UIViewController {

    var club: Club?
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var instagramLabel: UILabel!
    @IBOutlet weak var vkLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func share(_ sender: Any) {
        
        let textToShare = "Все клубы Dance Family в одном приложении!\nСкачай DF Music прямо сейчас\nhttps://itunes.apple.com/us/app/df-music/id1265946456?mt=8"
        
        let objectsToShare = [textToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityVC, animated: true, completion: nil)

    }
    
    
    func setupUI() {
        setupTitle()
        setupClubInfo()
    }
    
    func setupTitle() {
        //setup title
        let label = UILabel(frame: CGRect(x:0, y:0, width:100, height:100))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        //customize multiline text for navigationbar title
        let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        let firstLine = NSMutableAttributedString(string:"\(club!.name)\n", attributes:firstAttributes)
        let secondAttributes =  [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        let secondLine = NSAttributedString(string:"INFO PAGE", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
    }
    
    func setupClubInfo() {
        locationLabel.text = club!.location
        yearLabel.text = club!.year
        memberLabel.text = club!.members
        nameLabel.text = club!.name
        siteLabel.text = club!.site
        vkLabel.text = club!.vk
        instagramLabel.text = club!.instagram
    }
}
