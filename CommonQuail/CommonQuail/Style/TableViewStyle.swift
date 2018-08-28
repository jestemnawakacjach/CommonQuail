//
//  TableViewStyle.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import UIKit

public struct TableViewStyle {
    
    // MARK: - Properties
    var parameters: [TableViewStyleParameter]

    // MARK: - Inits
    public init(_ parameters: TableViewStyleParameter...) {
        self.parameters = parameters
    }
    
    // MARK: - Templates
    public static var basic: TableViewStyle = TableViewStyle(
        .backgroundColor(.clear),
        .separatorStyle(.none),
        .deselectsAfterSelection(true)
    )
}

public extension TableViewManager {
    
    /// Sets all parameters passed through style
    public func styledTableView(with style: TableViewStyle) {
        style.parameters.forEach { setParameter($0) }
    }
    
    /// Sets style depending on type
    private func setParameter(_ parameter: TableViewStyleParameter) {
      
        switch parameter {
        case .backgroundColor(let backgroundColor):
            tableView?.backgroundColor = backgroundColor
        case .separatorColor(let separatorColor):
            tableView?.separatorColor = separatorColor
        case .separatorStyle(let separatorStyle):
            tableView?.separatorStyle = separatorStyle
        case .showsVerticalScrollIndicator(let showsVerticalScrollIndicator):
            tableView?.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        case .deselectsAfterSelection(let deselectsAfterSelection):
            self.deselectsAfterSelection = deselectsAfterSelection
        case .topInset(let topInset):
            tableView?.contentInset.top = topInset
        case .bottomInset(let bottomInset):
            tableView?.contentInset.bottom = bottomInset
        }
    }
    
}
