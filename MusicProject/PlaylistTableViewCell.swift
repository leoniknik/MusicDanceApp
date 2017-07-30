//
//  PlaylistTableViewCell.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var playlistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
