//
//  TableViewSection.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import Foundation

public class TableViewSection {
    
    // MARK: - Properties
    var rows = [TableViewItem]()
    var headerReuseId: String?
    var height: CGFloat = UITableViewAutomaticDimension
    
    // MARK: - Inits
    public init(rows: [TableViewItem] = []) {
        self.rows = rows
    }
    
}
