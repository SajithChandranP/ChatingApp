//
//  SBChatLisVC.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/2/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBChatLisVC: UIViewController {
    
    @IBOutlet weak var NavigationItem: UINavigationItem!
    @IBOutlet weak var chatListTableView: UITableView!
    @IBOutlet weak var noChannelLabel: UILabel!
    
    var refreshControl: UIRefreshControl?
    var channels: [SBDGroupChannel] = []
    var editableChannel: Bool = false
    var groupChannelListQuery: SBDGroupChannelListQuery?
    
    var cachedChannels: Bool = true
    var firstLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sb_registerCell()
        sb_setDefaultNavigationItems()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(sb_refreshChannelList), for: UIControlEvents.valueChanged)
        chatListTableView.addSubview(self.refreshControl!)
        
        let dumpLoadQueue: DispatchQueue = DispatchQueue(label: "com.sendbird.dumploadqueue", attributes: .concurrent)
        dumpLoadQueue.async {
            self.channels = SBChatServiceManager.loadChatList()
            if self.channels.count > 0 {
                DispatchQueue.main.async {
                    self.chatListTableView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(150), execute: {
                        self.sb_refreshChannelList()
                    })
                }
            }
            else {
                self.cachedChannels = false
                self.sb_refreshChannelList()
            }
        }
        
        self.firstLoading = true
//        print("UserID:",SBDMain.getCurrentUser()?.userId,"UserName:",SBDMain.getCurrentUser()?.nickname)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.firstLoading == false {
            self.sb_refreshChannelList()
        }
        
        self.firstLoading = false
    }
    
    // MARK: - Private Method
    
    fileprivate func sb_registerCell() {
        let nib = UINib(nibName: "SBChatListTableViewCell", bundle: nil)
        chatListTableView.register(nib, forCellReuseIdentifier: "SBChatListTableViewCell")
    }
    
    fileprivate func sb_setDefaultNavigationItems() {
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2

        let disconectButton = UIBarButtonItem(title: "Disconnect", style: UIBarButtonItemStyle.plain, target: self, action: #selector(disconnectUser))
       
        let createChatButton = UIBarButtonItem(image: UIImage(named: "plusImage"), style: UIBarButtonItemStyle.done, target: self, action: #selector(createChannel))// UIBarButtonItem(title: "Create", style: UIBarButtonItemStyle.plain, target: self, action: #selector(createChannel))
       

        self.NavigationItem.leftBarButtonItems = [negativeLeftSpacer, disconectButton]
        self.NavigationItem.rightBarButtonItems = [negativeRightSpacer, createChatButton]
    }

    @objc fileprivate func sb_refreshChannelList() {
        self.groupChannelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
        self.groupChannelListQuery?.limit = 20
        self.groupChannelListQuery?.order = SBDGroupChannelListOrder.latestLastMessage
        
        self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                
                return
            }
            
            self.channels.removeAll()
            self.cachedChannels = false
            
            for channel in channels! {
                self.channels.append(channel)
            }
            
            DispatchQueue.main.async {
                if self.channels.count == 0 {
                     self.noChannelLabel.isHidden = false
                }
                else {
                    self.noChannelLabel.isHidden = true
                }
                
                self.refreshControl?.endRefreshing()
                self.chatListTableView.reloadData()
            }
        })
    }
    
    @objc fileprivate func disconnectUser() {
        SBDMain.disconnect(completionHandler: {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
                self.dismiss(animated: false, completion: nil)
            }
        })
    }
    
    @objc fileprivate func createChannel() {
        let vc = SBCreateNewChatVC(nibName: "SBCreateNewChatVC", bundle: Bundle.main)
        self.present(vc, animated: false, completion: nil)
    }
    
    fileprivate func loadChannels() {
        if self.cachedChannels == true {
            return
        }
        
        if self.groupChannelListQuery != nil {
            if self.groupChannelListQuery?.hasNext == false {
                return
            }
            
            self.groupChannelListQuery?.loadNextPage(completionHandler: { (channels, error) in
                if error != nil {
                    if error?.code != 800170 {
                        DispatchQueue.main.async {
                            self.refreshControl?.endRefreshing()
                        }
                        
                        let vc = UIAlertController(title: "chanel list loading error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let closeAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                        vc.addAction(closeAction)
                        DispatchQueue.main.async {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                    return
                }
                
                for channel in channels! {
                    self.channels.append(channel)
                }
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.chatListTableView.reloadData()
                }
            })
        }
    }
}

extension SBChatLisVC: UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - UITableViewDataSource Method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SBChatListTableViewCell") as! SBChatListTableViewCell!
            
        cell?.setModel(aChannel: self.channels[indexPath.row])

        if self.channels.count > 0 && indexPath.row + 1 == self.channels.count {
            self.loadChannels()
        }

        return cell!
    }
    
    // MARK: - UITableViewDelegate Method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SBChatRoomVC(nibName: "SBChatRoomVC", bundle: Bundle.main)
        vc.groupChannel = self.channels[indexPath.row]
        
        for member in self.channels[indexPath.row].members! as NSArray as! [SBDUser] {
            if member.userId == SBDMain.getCurrentUser()?.userId {
                continue
            }
            vc.userName = member.nickname
        }
        self.present(vc, animated: false, completion: nil)
    }
}
