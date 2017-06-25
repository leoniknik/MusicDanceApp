//
//  ContactViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 25.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func share(_ sender: Any) {
        let textToShare = "Мне нравится HILK STUDIO!\n\nHILK В VK\nhttps://vk.com/hilk_studio\n\nСОТРУДНИЧЕСТВО C HILK\nhilk.commerce@gmail.com\n\nСЛУЖБА ПОДДЕРЖКИ HILK\nhilk.helpdesk@gmail.com\n\nСкачай DF Music прямо сейчас"
        
        let objectsToShare = [textToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
            self.present(activityVC, animated: true, completion: nil)
    }
    
    func setupUI() {
        
        let label = UILabel(frame: CGRect(x:0, y:0, width:100, height:100))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        //customize multiline text for navigationbar title
        let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        let firstLine = NSMutableAttributedString(string:"HILK STUDIO\n", attributes:firstAttributes)
        let secondAttributes =  [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        let secondLine = NSAttributedString(string:"CONTACTS", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
    }

}
