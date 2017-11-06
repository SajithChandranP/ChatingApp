//
//  SBChatServiceManager.swift
//  SendBirdChatApp
//
//  Created by Mobiiworld on 11/5/17.
//  Copyright © 2017 Mobiiworld. All rights reserved.
//

import UIKit
import SendBirdSDK

class SBChatServiceManager: NSObject {

    static func loadChatList() -> [SBDGroupChannel] {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let messageFileNamePrefix = String.init(format: "%@_chatlist", (SBDMain.getCurrentUser()?.userId)!)
        let dumpFileName = String(format: "%@.data", messageFileNamePrefix) as NSString
        let appIdDirectory = documentsDirectory.appendingPathComponent(SBDMain.getApplicationId()!) as NSString
        let dumpFilePath = appIdDirectory.appendingPathComponent(dumpFileName as String)
        
        if FileManager.default.fileExists(atPath: dumpFilePath) == false {
            return []
        }
        
        do {
            let channelDump = try String(contentsOfFile: dumpFilePath, encoding: String.Encoding.utf8)
            
            if channelDump.characters.count > 0 {
                let loadChannels = channelDump.components(separatedBy: "\n")
                
                if loadChannels.count > 0 {
                    var channels: [SBDGroupChannel] = []
                    for channelString in loadChannels {
                        let channelData = NSData(base64Encoded: channelString, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
                        let channel = SBDGroupChannel.build(fromSerializedData: channelData! as Data)
                        channels.append(channel!)
                    }
                    
                    return channels
                }
            }
        }
        catch {
            return []
        }
        
        return []
    }
}
