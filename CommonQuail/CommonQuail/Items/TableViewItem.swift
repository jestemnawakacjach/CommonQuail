//
//  TableViewDataItem.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import UIKit

public protocol TableViewItem {
    
    func reuseID() -> String
    
    func height() -> CGFloat
    
}

public extension TableViewItem {
    
    func height() -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
