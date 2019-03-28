//
//  Message.swift
//  gameofchats
//
//  Created by Muhammad Fatani on 10/03/2019.
//  Copyright © 2019 Muhammad Fatani. All rights reserved.
//

import UIKit
import Firebase
class Message{
    let fromId: String?
    
    let text: String?
    
    let timestamp: NSNumber?
    
    let toId: String?
    
    let messageUrl:String?
    
    let imageWidth: NSNumber?
    
    let imageHeight: NSNumber?
    
    let videoUrl: String?

    init(dictionary: [String: Any]) {
        fromId = dictionary["fromId"] as? String
        
        text =  dictionary["text"] as? String
        
        timestamp =  dictionary["timestamp"] as? NSNumber
        
        toId = dictionary["toId"] as? String
        
        messageUrl = dictionary["imageUrl"] as? String
        
        imageWidth = dictionary["imageWidth"] as? NSNumber
        
        imageHeight = dictionary["imageHeight"] as? NSNumber
        
        videoUrl = dictionary["videoUrl"] as? String
    }
    
//    init(fromId: String?, text:String?, timestamp:NSNumber?, toId:String?, messageUrl:String?) {
//        self.fromId = fromId
//        self.text = text
//        self.timestamp = timestamp
//        self.toId = toId
//        self.messageUrl = messageUrl
//
//    }
//
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
