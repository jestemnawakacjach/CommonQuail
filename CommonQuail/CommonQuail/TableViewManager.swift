//
//  TableViewManager.swift
//  tableview_ribbon
//
//  Created by Karol Wawrzyniak on 18/07/2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//

import UIKit

public protocol TableViewManagerDelegate: class {

    func tableViewManager(manager: TableViewManager, didSelectItem item: TableViewItem)

}

public class TableViewManager: NSObject {

    // MARK: - Properties
    public var deselectsAfterSelection: Bool = true
    
    public weak var delegate: TableViewManagerDelegate?

    public private (set) var data = [TableViewSection]()
    public private (set) weak var tableView: UITableView!

    // MARK: - Inits
    public init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.data = [TableViewSection]()
    }
    
    public init(style: UITableViewStyle = .plain) {
        super.init()
        tableView = UITableView(frame: .zero, style: style)
        data = [TableViewSection]()
        styledTableView(with: .basic)
    }

    public convenience init(tableView: UITableView, reuseIDs: [String]) {
        self.init(tableView: tableView)

        for reuseID in reuseIDs {
            register(reuseID: reuseID)
        }
    }
    
    // MARK: - Public Instance Methods
    public func tableViewItem(for indexPath: IndexPath) -> TableViewItem {
        return data[indexPath.section].rows[indexPath.row]
    }
    
    public func tableViewSection(for index: Int) -> TableViewSection {
        return data[index]
    }
    
    public func numberOfRows(in section: Int) -> Int {
        return data[section].rows.count
    }
    
    public func numberOfSections() -> Int {
        return data.count
    }
    
    public func reloadItem(item: TableViewItem) {
        let array = self.data as NSArray
        let index = array.index(of: item)
        let indexPath = IndexPath(row: index, section: 0)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    public func removeAllItems() {
        data = [TableViewSection]()
    }
    
    public func removeItem(at index: Int, section: Int = 0) {
        let indexPath = IndexPath(row: index, section: section)
        
        tableView?.beginUpdates()
        data[section].rows.remove(at: index)
        tableView?.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }
    
    public func insertItems(_ items: [TableViewItem], firstIndex: Int, section: Int = 0) {
        
        guard items.count > 0 else { return }
        
        items.forEach { (data) in
            register(item: data)
        }
        
        tableView.beginUpdates()
        
        var index = firstIndex
        var indexPaths = [IndexPath]()
        let sectionItem = self.data[section]
        
        items.forEach { item in
            sectionItem.rows.insert(item, at: index)
            let indexPath = IndexPath(row: index, section: section)
            indexPaths.append(indexPath)
            index += 1
        }
        
        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.endUpdates()
        
    }
    
    public func add(section: TableViewSection) {
        
        guard let rId = section.headerReuseId, let className = NSClassFromString(rId) else {
            return
        }
        
        let bundle = Bundle(for: className)
        let nibName = rId.components(separatedBy: ".")[1]
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: rId)
        
        for item in section.rows {
            register(item: item)
        }
        
        data.append(section)
        tableView.reloadData()
        
    }
    
    public func addItems(_ items: [TableViewItem]) {
        
        guard items.count > 0 else { return }
        
        let sectionsCount = numberOfSections()
        var indexPaths = [IndexPath]()
        
        if sectionsCount == 0 {
            
            let section = TableViewSection(rows: items)
            
            section.rows.forEach { register(item: $0) }
            
            data.append(section)
            tableView.reloadData()
            
            return
        }
        
        guard let sectionData = self.data.last else { return }
        
        for (index, item) in items.enumerated() {
            register(item: item)
            let indexPath = IndexPath(row: sectionsCount + index, section: 0)
            indexPaths.append(indexPath)
        }

        CATransaction.begin()
        
        tableView.beginUpdates()
        
        sectionData.rows.append(contentsOf: items)
        tableView?.insertRows(at: indexPaths, with: .automatic)
        
        tableView?.endUpdates()
        
        CATransaction.commit()
    }

}

// MARK: - Instance Methods
extension TableViewManager {
    
    func register(item: TableViewItem) {
        let reuseID = item.reuseID()
        self.register(reuseID: reuseID)
    }
    
    func register(reuseID: String) {
        if let className = NSClassFromString(reuseID) {
            let bundle = Bundle(for: className)
            let nibName = reuseID.components(separatedBy: ".")[1]
            
            self.tableView?.register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: reuseID)
        }
    }

    func removeItem(item: TableViewItem) {
        
        let array = self.data as NSArray
        let index = array.index(of: item)
        
        data.remove(at: index)
        
        tableView.reloadData()
    }

}


// MARK: - UITableViewDataSource Methods
extension TableViewManager: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(in: section)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = tableViewItem(for: indexPath)
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: item.reuseID())
        
        if let loadableCell = tableCell as? UITableViewCellLoadableProtocol {
            loadableCell.loadData(item, tableView: tableView)
        }
        
        return tableCell!
    }
    
}

// MARK: - UITableViewDelegate Methods
extension TableViewManager: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = tableViewItem(for: indexPath)
        
        delegate?.tableViewManager(manager: self, didSelectItem: item)
        
        if deselectsAfterSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewSection(for: section).height
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewItem(for: indexPath).height()
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewItem(for: indexPath).height()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let section = tableViewSection(for: section)
        
        guard let reuseId = section.headerReuseId else {
            return nil
        }
        
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseId)
        
        if let loadableHeader = header as? UITableViewHeaderLoadableProtocol {
            loadableHeader.loadData(section, tableView: tableView)
        }
        
        return header
        
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let item = tableViewItem(for: indexPath) as? TableViewItemInteractions else {
            return false
        }
        
        return item.canEdit()
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let item = tableViewItem(for: indexPath) as? TableViewItemInteractions else {
            return nil
        }
        
        return item.actions()
    }

}
