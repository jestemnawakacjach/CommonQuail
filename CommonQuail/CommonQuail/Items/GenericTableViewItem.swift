//
//  GenericTableViewItem.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import UIKit

open class GenericTableViewItem<T>: TableViewItem {
    
    public func reuseID() -> String {
        return String(reflecting: T.self)
    }
    
}
