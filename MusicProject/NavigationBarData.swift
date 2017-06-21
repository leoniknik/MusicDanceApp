//
//  NavigationBarData.swift
//  MusicProject
//
//  Created by Кирилл Володин on 20.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

struct NavigationBarData {
    
    static let BarTintColorArray: [NavigationBarBackgroundViewColor] = [.Black, .NoValue]
    static let BackgroundImageColorArray: [NavigationBarBackgroundViewColor] = [.NoValue, .Transparent, .Black]
    
    var barTintColor = NavigationBarData.BarTintColorArray.first!
    var backgroundImageColor = NavigationBarData.BackgroundImageColorArray.first!
    var prefersHidden = false
    var prefersShadowImageHidden = false
    
}

enum NavigationBarBackgroundViewColor: String {
    
    case Black
    case Transparent
    case NoValue = "No Value"
    
    var toUIColor: UIColor? {
        switch self {
        case .Black:
            return UIColor.black
        default:
            return nil
        }
    }
    
    var toUIImage: UIImage? {
        switch self {
        case .Transparent:
            return UIImage()
        default:
            if let color = toUIColor {
                return UIImage(color: color)
            } else {
                return nil
            }
        }
    }
}
