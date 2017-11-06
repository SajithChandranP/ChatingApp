//
//  SBChatListTableViewCell.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/2/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMsgLabel: UILabel!
    @IBOutlet weak var unreadMessageCountLabel: UILabel!
    
    var channel: SBDGroupChannel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setModel(aChannel: SBDGroupChannel) {
        self.channel = aChannel
        
        for member in self.channel.members! as NSArray as! [SBDUser] {
            if member.userId == SBDMain.getCurrentUser()?.userId {
                continue
            }
            if let chatName = member.nickname {
                userNameLabel.text = chatName
            }
            else {
                userNameLabel.text = member.userId
            }
        }
        
        if self.channel.lastMessage is SBDUserMessage {
            let lastMessage = (self.channel.lastMessage as! SBDUserMessage)
            self.lastMsgLabel.text = lastMessage.message
        }
        else {
            self.lastMsgLabel.text = ""
        }
        
        self.unreadMessageCountLabel.isHidden = false
        if self.channel.unreadMessageCount == 0 {
            self.unreadMessageCountLabel.isHidden = true
        }
        else if self.channel.unreadMessageCount <= 9 {
            self.unreadMessageCountLabel.text = String(format: "%ld", self.channel.unreadMessageCount)
        }
        else {
            self.unreadMessageCountLabel.text = "9+"
        }
        
    }
    
    
}
