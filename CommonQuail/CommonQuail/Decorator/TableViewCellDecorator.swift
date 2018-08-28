//
//  TableViewCellDecorator.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import UIKit

public protocol TableViewCellDecorator {
    
    func decorate(cell: UITableViewCellLoadableProtocol)
    
}
