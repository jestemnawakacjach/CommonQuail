//
//  UITableViewCellLoadableProtocol.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import UIKit

public protocol UITableViewCellLoadableProtocol {
    
    func loadData(_ data: TableViewItem, tableView: UITableView)
    
}

public extension UITableViewCellLoadableProtocol {
    
    func loadData(_ data: TableViewItem) {
        guard let decorator = data as? TableViewCellDecorator else {
            return
        }
        
        decorator.decorate(cell: self)
    }
    
}
