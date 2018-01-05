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
        let textToShare = """
        Мне нравится RxProject!\n
        \n
        RxProject В VK\n
        https://vk.com/rxproject_studio\n
        \n
        СОТРУДНИЧЕСТВО c RxProject\n
        info@rxproject.ru\n
        \n
        СЛУЖБА ПОДДЕРЖКИ RxProject\n
        support.ios@rxproject.ru\n
        \n
        """
        
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
        label.textColor = UIColor.black
        
        //customize multiline text for navigationbar title
        let firstAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
        let firstLine = NSMutableAttributedString(string:"RxProject\n", attributes:firstAttributes)
        let secondAttributes =  [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        let secondLine = NSAttributedString(string:"CONTACTS", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
    }

}
