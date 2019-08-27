//
//  PurchasesConst.swift
//  GoGetter
//
//  Created by admin on 25/08/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit

class PurchasesConst {
    enum ScreenAction: Int {
        typealias RawValue = Int
        
        case BUY_CONVO = 0
        case BUY_COINS = 1
        case READY_TO_CHAT = 2
        case WAIT_FOR_MATCH_TO_PAY = 3
        case CONVO_TERMINATED = 4
    }
    
    enum PurchaseStatus: Int {
        typealias RawValue = Int
        
        case PURCHASE_FAILED = 0
        case PURCHASE_SUCCESS = 1
    }
    
    enum PurchaseFailReasons: Int {
        typealias RawValue = Int
        
        case PURCHASE_FAIL_UNKOWN = 0
        case PURCHASE_FAIL_NSF = 1
        case PURCHASE_FAIL_CANCEL = 2
    }
    
    enum ConvoBuyState: Int {
        typealias RawValue = Int
        
        case CONVO_BUY_NONE = 0
        case CONVO_BOUGHT = 1
        case CONVO_TERMINATED = 2
    }
}
