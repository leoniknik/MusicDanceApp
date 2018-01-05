//
//  ListsOfClubsViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 25.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class ListOfClubsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var clubsTable: UITableView!
    
    let clubs: [Club] = [
        Club(name: "BLACK VELVET", year: "Since 2014", location: "Россия, Москва", members: "> 80 чел.", site: "скоро", instagram: "/blackvelvetteam", vk: "/blackvelvetteam"),
        Club(name: "CRAZY DREAM", year: "Since 2004", location: "Россия, Москва", members: "> 500 чел.", site: "/crazydreamdancefamily.com", instagram: "/crazydream_msk", vk: "/crazy_dream_official"),
        Club(name: "DANCE FAMILY LADIES", year: "Since 2009", location: "Россия, Москва", members: "> 10 чел.", site: "скоро", instagram: "скоро", vk: "/df_ladystyle"),
        Club(name: "FLASH LIGHT", year: "Since 2010", location: "Россия, Горячий ключ", members: "> 50 чел.", site: "скоро", instagram: "/flash_light_fam", vk: "/flashlightfam"),
        Club(name: "FREE STEPS", year: "Since 2008", location: "Россия, Москва", members: "> 60 чел.", site: "скоро", instagram: "ds_freesteps", vk: "freestepskids"),
        Club(name: "JUST DANCE", year: "Since 2013", location: "Россия, Ставрополь", members: "> 60 чел", site: "скоро", instagram: "/justdancestav", vk: "jdstav"),
        Club(name: "LEADER DANCE", year: "Since 2009", location: "Россия, Астрахань", members: "> 230 чел.", site: "/leader-dance.ru", instagram: "/leader.dance", vk: "/leaderd"),
        Club(name: "LUCKY JAM", year: "Since 2010", location: "Россия, Ставрополь", members: "> 70 чел.", site: "/luckyjam.ru", instagram: "/lucky_jam_stav", vk: "/club16550057"),
        Club(name: "MY COMMUNITY", year: "Since 2005", location: "Россия, Ростов", members: "> 100 чел.", site: "/mycom.plp7.ru", instagram: "/mycomdance", vk: "/mycommunity_dance"),
        Club(name: "UNISTREAM", year: "Since 2006", location: "Россия, Ростов-на-Дону", members: "> 170 чел.", site: "скоро", instagram: "/unistream_dance", vk: "/usmdance")
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        clubsTable.dataSource = self
        clubsTable.delegate = self
        clubsTable.separatorStyle = .none
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //transparent navigationbar
        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    func setupUI() {
        
        //setup title
        let label = UILabel(frame: CGRect(x:0, y:0, width:100, height:100))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        //customize multiline text for navigationbar title
        let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        let firstLine = NSMutableAttributedString(string:"DANCE FAMILY\n", attributes:firstAttributes)
        let secondAttributes =  [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        let secondLine = NSAttributedString(string:"CLUBS", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
        
        //transparent tableview
        clubsTable.tableFooterView = UIView(frame: CGRect.zero)
        clubsTable.backgroundColor = .clear
        clubsTable.separatorStyle = .none
        
    }
    
    @IBAction func share(_ sender: Any) {
        
        let textToShare = "Все клубы Dance Family в одном приложении!\nСкачай DF Music прямо сейчас\nhttps://itunes.apple.com/us/app/df-music/id1265946456?mt=8"
        
        let objectsToShare = [textToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityVC, animated: true, completion: nil)

    }
    
    @IBAction func goBack(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
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
        
        return clubs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = clubsTable.dequeueReusableCell(withIdentifier: "ClubViewCell") as! ClubViewCell
        let index = indexPath.row
        cell.number.text = "\(index + 1)"
        cell.name.text = clubs[index].name
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        let club = clubs[index]
        self.performSegue(withIdentifier: SegueRouter.toClub.rawValue, sender: club)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationViewController = segue.destination as! ClubViewController
        destinationViewController.club = sender as? Club
        
    }
    
}

