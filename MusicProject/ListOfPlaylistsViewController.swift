//
//  ListOfPlaylistsViewController.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class ListOfPlaylistsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        APIManager.getPlaylistsRequest()
    }
}
