//
//  ShuffleState.swift
//  MusicProject
//
//  Created by Кирилл Володин on 24.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation


class Shuffle {
    
    static var shuffleState: ShuffleState = .off
    
    enum ShuffleState {
        case on
        case off
    }
    
    class func getState() -> ShuffleState {
        return shuffleState
    }
    
    class func switchState() {
        if getState() == .on {
            setOffState()
        }
        else {
            setOnState()
        }
    }
    
    class func setOnState() {
        shuffleState = .on
    }
    
    class func setOffState() {
        shuffleState = .off
    }
}
