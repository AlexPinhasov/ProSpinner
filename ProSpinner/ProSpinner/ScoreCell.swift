//
//  ScoreCell.swift
//  ProSpinner
//
//  Created by Alex Pinhasov on 31/07/2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit

class ScoreCell: UITableViewCell
{
    @IBOutlet weak var spinnerImage : UIImageView!
    @IBOutlet weak var playerName   : UILabel!
    @IBOutlet weak var kingCrown    : UIImageView!
    @IBOutlet weak var playerScore  : UILabel!
    @IBOutlet weak var rankLabel    : UILabel!
    
    override func prepareForReuse()
    {
        spinnerImage.image = nil
        kingCrown.alpha = 0.35
        backgroundColor = .white
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
            spinnerImage.image = nil
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
