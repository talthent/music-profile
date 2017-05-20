//
//  PlaylistTableViewCell.swift
//  MusicProfile
//
//  Created by Tal Cohen on 20/05/2017.
//  Copyright © 2017 Tal Cohen. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(white: 0, alpha: 0.3)
        } else {
            self.backgroundColor = .clear
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.songLabel.textColor = UIColor(red: 10/255, green: 164/255, blue: 217/255, alpha: 1)
            self.artistLabel.textColor = UIColor(red: 10/255, green: 164/255, blue: 217/255, alpha: 0.7)
        } else {
            self.songLabel.textColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
            self.artistLabel.textColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 0.7)
        }
    }
}
