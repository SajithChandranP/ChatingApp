//
//  SBChatRoomVC.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/2/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBChatRoomVC: UIViewController {
    
    @IBOutlet weak var NavigationItem: UINavigationItem!
    @IBOutlet weak var msgListTableView: UITableView!
    @IBOutlet weak var newMsgTextField: UITextField!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    var messageQuery: SBDPreviousMessageListQuery!
    var delegateIdentifier: String!
    var keyboardShown: Bool = false
    var messages: [SBDBaseMessage] = []
    var groupChannel: SBDGroupChannel!
    var userName: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        sb_registerCell()
        sb_setDefaultNavigationItems()
        self.loadPreviousMessages()
        
        self.delegateIdentifier = self.description
        SBDMain.add(self as SBDChannelDelegate, identifier: self.delegateIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    
    }
    
    @IBAction func sendMsg(_ sender: Any) {
        if let newMsg = newMsgTextField.text {
            groupChannel.sendUserMessage(newMsg, data: "", completionHandler: { (userMessage, error) in
                if error != nil {
                    NSLog("Error: %@", error!)
                    return
                }
                self.messages.append(userMessage!)
                self.newMsgTextField.text = ""
                self.msgListTableView.reloadData()
            })
        }
    }
    
    // MARK: - Private Method
    
    fileprivate func sb_registerCell() {
        let incomingMsgNib = UINib(nibName: "SBIncomingTextMessageTableViewCell", bundle: nil)
        msgListTableView.register(incomingMsgNib, forCellReuseIdentifier: "SBIncomingTextMessageTableViewCell")
        
        let outgoingMsgNib = UINib(nibName: "SBOutgoingTextMessageTableViewCell", bundle: nil)
        msgListTableView.register(outgoingMsgNib, forCellReuseIdentifier: "SBOutgoingTextMessageTableViewCell")
    }
    
    fileprivate func sb_setDefaultNavigationItems() {
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        
        let backButton = UIBarButtonItem(image: UIImage(named: "closeImage"), style: UIBarButtonItemStyle.done, target: self, action: #selector(backToChatList))//UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToChatList))
    
        self.NavigationItem.title = userName
        self.NavigationItem.leftBarButtonItems = [negativeLeftSpacer, backButton]
    }

    @objc fileprivate func backToChatList() {
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        self.dismiss(animated: false, completion: nil)
    }
    
    fileprivate func loadPreviousMessages() {

        if self.messageQuery == nil {
            self.messageQuery = self.groupChannel.createPreviousMessageListQuery()
       }
        
        
        messageQuery?.loadPreviousMessages(withLimit: 50, reverse: true, completionHandler: { (messages, error) in
            if error != nil {
                let vc = UIAlertController(title: "message loadung error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler:nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            for msg in messages! as [SBDBaseMessage] {
                self.messages.append(msg)
            }
            DispatchQueue.main.async {
                self.msgListTableView.reloadData()
            }
            
        })
    }
    
    @objc fileprivate func keyboardWillShow(notification: Notification) {
        self.keyboardShown = true
        let keyboardInfo = notification.userInfo
        let keyboardFrameBegin = keyboardInfo?[UIKeyboardFrameEndUserInfoKey]
        let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
        DispatchQueue.main.async {
            self.bottomMargin.constant = -(keyboardFrameBeginRect.size.height)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc fileprivate func keyboardDidHide(notification: Notification) {
        self.keyboardShown = false
        DispatchQueue.main.async {
            self.bottomMargin.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension SBChatRoomVC: UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - UITableViewDataSource Method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let msg = self.messages[indexPath.row]
        var cell: UITableViewCell?
        
        if msg is SBDUserMessage {
            let userMessage = msg as! SBDUserMessage
            let sender = userMessage.sender
            
            if sender?.userId == SBDMain.getCurrentUser()?.userId {
                cell = tableView.dequeueReusableCell(withIdentifier: "SBOutgoingTextMessageTableViewCell")
                (cell as! SBOutgoingTextMessageTableViewCell).msgLabel.text = userMessage.message
            }
            else {
                cell = tableView.dequeueReusableCell(withIdentifier: "SBIncomingTextMessageTableViewCell")
                (cell as! SBIncomingTextMessageTableViewCell).msgLabel.text = userMessage.message
            }
        }
        return cell!
    }
}

extension SBChatRoomVC: SBDChannelDelegate {
    
    func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        self.messages.append(message)
        self.msgListTableView.reloadData()
    }
}
