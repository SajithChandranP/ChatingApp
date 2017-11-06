//
//  ViewController.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/1/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit
import SendBirdSDK

class ViewController: UIViewController {

    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonAction(_ sender: Any) {
        if let userID = userIDTextField?.text {
            if let userName = userNameTextField?.text {
                SBDMain.connect(withUserId: userID, completionHandler: { (user, error) in
                    if error != nil {
                        
                        let alertVC = UIAlertController(title: "login error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                        let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                        alertVC.addAction(okayAction)
                        
                        DispatchQueue.main.async {
                            
                            self.indicatorView.stopAnimating()
                            self.present(alertVC, animated: true, completion: nil)
                        }
                        
                        return
                    }
                    
                    SBDMain.updateCurrentUserInfo(withNickname: userName, profileUrl: nil, completionHandler: { (error) in
                       
                        
                        if error != nil {
                            let alertVC = UIAlertController(title: "login error", message: error?.domain, preferredStyle: UIAlertControllerStyle.alert)
                            let closeAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil)
                            alertVC.addAction(closeAction)
                            DispatchQueue.main.async {
                                
                                self.indicatorView.stopAnimating()
                                self.present(alertVC, animated: true, completion: nil)
                            }
                            
                            SBDMain.disconnect(completionHandler: {
                                
                            })
                            
                            return
                        }
                        
                        UserDefaults.standard.set(SBDMain.getCurrentUser()?.userId, forKey: "sendbird_user_id")
                        UserDefaults.standard.set(SBDMain.getCurrentUser()?.nickname, forKey: "sendbird_user_name")
                    })
                    
                    DispatchQueue.main.async {
                        let vc = SBChatLisVC(nibName: "SBChatLisVC", bundle: Bundle.main)
                        self.present(vc, animated: false, completion: nil)
                    }
                })
            }
        }
    }    
}

