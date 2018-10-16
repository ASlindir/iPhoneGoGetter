//
//  ChatModels.swift
//  Slindir
//
//  Created by Gurinder Batth on 24/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

import UIKit

internal class Friend {
    internal let id: String
    internal let name: String
    internal let lastMessage: [String: Any]?
    internal let profilePic: String
    internal let online: Bool
    
    init(id: String, name: String, profilePic: String, lastMessage: [String:Any]?, online: Bool) {
        self.id = id
        self.name = name
        self.lastMessage = lastMessage
        self.profilePic = profilePic
        self.online = online
    }
}
