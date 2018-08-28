//
//  UITableViewHeaderLoadableProtocol.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import UIKit

public protocol UITableViewHeaderLoadableProtocol {
    
    func loadData(_ data: TableViewSection, tableView: UITableView)
    
}
