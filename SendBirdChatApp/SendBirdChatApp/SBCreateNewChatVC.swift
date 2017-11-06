//
//  SBCreateNewChatVC.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/5/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBCreateNewChatVC: UIViewController {

    @IBOutlet weak var allUserListTableView: UITableView!
    @IBOutlet weak var NavigationItem: UINavigationItem!
    
    private var refreshControl: UIRefreshControl?
    private var users: [SBDUser] = []
    private var userListQuery: SBDUserListQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sb_registerCell()
        sb_setDefaultNavigationItems()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(sb_refreshChannelList), for: UIControlEvents.valueChanged)
        allUserListTableView.addSubview(self.refreshControl!)

        self.loadUserList(initial: true)
    }

    
    // MARK: - Private Method
    
    fileprivate func sb_registerCell() {
        let nib = UINib(nibName: "SBUserListTableViewCell", bundle: nil)
        allUserListTableView.register(nib, forCellReuseIdentifier: "SBUserListTableViewCell")
    }

    fileprivate func sb_setDefaultNavigationItems() {
        let negativeLeftSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeLeftSpacer.width = -2
        let negativeRightSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeRightSpacer.width = -2
        
        let backButton = UIBarButtonItem(image: UIImage(named: "closeImage"), style: UIBarButtonItemStyle.done, target: self, action: #selector(backToChatList))//UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backToChatList))

        self.NavigationItem.leftBarButtonItems = [negativeLeftSpacer, backButton]
    }

    @objc fileprivate func backToChatList() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc fileprivate func sb_refreshChannelList() {
        self.loadUserList(initial: true)
    }
    
    @objc fileprivate func loadUserList(initial: Bool) {
        if initial == true {
            self.users.removeAll()
            self.userListQuery = nil;
        }
        
        if self.userListQuery == nil {
            self.userListQuery = SBDMain.createAllUserListQuery()
            self.userListQuery?.limit = 25
        }
        
        if self.userListQuery?.hasNext == false {
            self.refreshControl?.endRefreshing()
            return
        }
        
        self.userListQuery?.loadNextPage(completionHandler: { (users, error) in
            if error != nil {
                let vc = UIAlertController(title: "User list loadung error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler:nil)
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                self.refreshControl?.endRefreshing()
                
                return
            }
            
            for user in users! as [SBDUser] {
                if user.userId == SBDMain.getCurrentUser()?.userId {
                    continue
                }
                self.users.append(user)
                
            }
            
            DispatchQueue.main.async {
                self.allUserListTableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        })
    }
    
    fileprivate func createChannelWith(user: SBDUser) {
        SBDGroupChannel.createChannel(with: [user], isDistinct: true) { (channel, error) in
            if error != nil {
                let vc = UIAlertController(title: "Channel creation error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                let closeAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: { (action) in
                    
                })
                vc.addAction(closeAction)
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: nil)
                }
                
                return
            }
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension SBCreateNewChatVC: UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - UITableViewDataSource Method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SBUserListTableViewCell") as! SBUserListTableViewCell!
        
        cell?.setUserData(aUser:  self.users[indexPath.row])
        
        
        if self.users.count > 0 && indexPath.row + 1 == self.users.count {
            self.loadUserList(initial: false)
        }
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate Method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.createChannelWith(user: self.users[indexPath.row])
    }
    
}
