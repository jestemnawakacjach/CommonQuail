//
//  TableViewItemInteractions.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import Foundation

public protocol TableViewItemInteractions {
    
    func canEdit() -> Bool
    
    func actions() -> [UITableViewRowAction]?

}

public extension TableViewItemInteractions {
    
    func canEdit() -> Bool {
        return false
    }
    
    func actions() -> [UITableViewRowAction]? {
        return nil
    }

}
