//
//  SongViewCell.swift
//  MusicProject
//
//  Created by Кирилл Володин on 23.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class SongViewCell: UITableViewCell {

    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
