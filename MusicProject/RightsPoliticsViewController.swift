//
//  RightsPoliticsViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 05.01.2018.
//  Copyright © 2018 Кирилл Володин. All rights reserved.
//

import UIKit

class RightsPoliticsViewController: UIViewController {

    @IBAction func goBack(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        
        let label = UILabel(frame: CGRect(x:0, y:0, width:100, height:100))
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = UIColor.black
        
        //customize multiline text for navigationbar title
        let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        let firstLine = NSMutableAttributedString(string:"Правовая политика", attributes:firstAttributes)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
    }

}
