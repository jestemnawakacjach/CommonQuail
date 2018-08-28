//
//  ListProviderProtocol.swift
//  CommonQuail
//
//  Created by Five.Twelve on 27.08.2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import Foundation

public protocol ListProviderProtocol: class {
    
    var delegate: ListProviderDelegate? { get set }
    
    func requestData()
    
}

public protocol ListProviderDelegate: class {
    
    func listProviderDidStartFetching(_ provider: ListProviderProtocol)
    
    func listProvider(_ provider: ListProviderProtocol, didFinishFetching data: [TableViewItem]?)
    
    func listProvider(_ provider: ListProviderProtocol, didFinishWithError error: Error?)
    
}
