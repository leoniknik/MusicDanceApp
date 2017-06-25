//
//  DonateViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 25.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class DonateViewController: UIViewController {

    @IBOutlet weak var attributedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }

    func setupUI() {
        setupTitle()
        setupLabel()
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
        let firstLine = NSMutableAttributedString(string:"PROJECT\n", attributes:firstAttributes)
        let secondAttributes =  [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13)]
        let secondLine = NSAttributedString(string:"SUPPORT", attributes:secondAttributes)
        firstLine.append(secondLine)
        
        label.attributedText = firstLine
        self.navigationItem.titleView = label
    }
    
    func setupLabel() {
        
        //setup attributed text
        attributedLabel.backgroundColor = UIColor.clear
        attributedLabel.numberOfLines = 4
        attributedLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        attributedLabel.textAlignment = .center
        attributedLabel.textColor = UIColor.white
        
        //customize multiline text for navigationbar title
        let firstLine = NSMutableAttributedString(string:"ДРУЗЬЯ, ПОЖАЛУЙСТА,\n", attributes:nil)
        let secondLine = NSAttributedString(string:"ПОДДЕРЖИТЕ НАШИ ПРОЕКТЫ!\n", attributes:nil)
        let thirdLine = NSAttributedString(string:"ВМЕСТЕ МЫ СДЕЛАЕМ МИР\n", attributes:nil)
        let fourthLine = NSAttributedString(string:"ЧУТОЧКУ ЛУЧШЕ И ИНТЕРЕСНЕЕ!", attributes:nil)
        firstLine.append(secondLine)
        firstLine.append(thirdLine)
        firstLine.append(fourthLine)
        
        attributedLabel.attributedText = firstLine

    }
    
    @IBAction func goBack(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func share(_ sender: Any) {
        
        let textToShare = "Я поддерживаю проект DF Music от HILK Studio, поддержи и ты!\n\nКарта Сбербанка\n4276 4000 6194 2877\n\nЯндекс.Деньги\nhttps://money.yandex.ru/to/410015079982251\n\nPayPal\npaypal.me/HILKstudio\n\nQIWI Кошелек\n+79169016017\n\nСкачай DF Music прямо сейчас"
        
        let objectsToShare = [textToShare] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender as? UIView
        self.present(activityVC, animated: true, completion: nil)
    }
    
}
