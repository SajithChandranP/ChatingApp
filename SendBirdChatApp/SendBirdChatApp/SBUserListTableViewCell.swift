//
//  SBUserListTableViewCell.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/6/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBUserListTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    var users: SBDUser!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUserData(aUser: SBDUser) {
        self.users = aUser
        
        userNameLabel.text = self.users.nickname
    }
}
