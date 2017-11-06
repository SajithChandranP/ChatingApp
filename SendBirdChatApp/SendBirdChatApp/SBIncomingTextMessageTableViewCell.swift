//
//  SBIncomingTextMessageTableViewCell.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/2/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit

class SBIncomingTextMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var msgLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        msgLabel?.layer.cornerRadius = 5.0
        msgLabel?.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
