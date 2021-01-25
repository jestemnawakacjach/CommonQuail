//
//  TableViewManager.swift
//  tableview_ribbon
//
//  Created by Karol Wawrzyniak on 18/07/2018.
//  Copyright © 2018 Fivedottwelve. All rights reserved.
//
import UIKit

public protocol TableViewCellDecorator {
    func decorate(cell: UITableViewCellLoadableProtocol)
}

open class GenericTableViewDataItem<T>: TableViewData {
    open var context: Any?

    public init() {
        context = nil
    }

    open func reuseID() -> String {
        return String(reflecting: T.self)
    }

    open func canEdit() -> Bool {
        return false
    }

    open func actions() -> [UITableViewRowAction]? {
        return nil
    }
}

public protocol ListProviderDelegate: class {
    func didStartFetching(_ data: [TableViewData]?)

    func didFinishFetching(_ data: [TableViewData]?)

    func didFinishFetchingWithError(_ error: NSError?)
}

public protocol ListProviderProtocol: class {
    var delegate: ListProviderDelegate? { get set }

    func requestData()
}

// TODO: add assosiated type
public protocol TableViewData {
    var context: Any? { get set }

    func reuseID() -> String

    func height() -> CGFloat

    func canEdit() -> Bool

    func actions() -> [UITableViewRowAction]?
}

open class SectionTableData {
    open var data = [TableViewData]()

    open var headerReuseId: String?

    open var height: CGFloat?

    public init() { }
}

public extension TableViewData {
    func height() -> CGFloat {
        return UITableView.automaticDimension
    }

    func canEdit() -> Bool {
        return false
    }

    func actions() -> [UITableViewRowAction]? {
        return nil
    }
}

public protocol UITableViewCellLoadableProtocol {
    func loadData(_ data: TableViewData, tableview: UITableView)
}

public protocol UITableViewHeaderLoadableProtocol {
    func loadData(_ data: SectionTableData, tableview: UITableView)
}

public protocol TableViewManagerDelegate: class {
    func didSelect(_ item: TableViewData)

    func pinDelegate(_ item: TableViewData)

    func tableViewManager(_ sender: TableViewManager, didScroll: UIScrollView)
    func tableViewManager(_ sender: TableViewManager, willDisplayItem item: TableViewData)
    func tableViewManager(_ sender: TableViewManager, didEndDisplayingItem item: TableViewData)
}

public protocol TableViewManagerSectionDisplayDelegate: class {
    func tableViewManager(_ sender: TableViewManager, willDisplaySection section: SectionTableData, forSection section: Int)
    func tableViewManager(_ sender: TableViewManager, didEndDisplayingSection section: SectionTableData, forSection section: Int)
}

public class TableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate {
    weak var tableView: UITableView!

    public weak var delegate: TableViewManagerDelegate?
    public weak var sectionDisplayDelegate: TableViewManagerSectionDisplayDelegate?
    public var isSelectionAllowed: Bool = false
    public private(set) var data = [SectionTableData]()

    public func reloadItem(item: TableViewData) {
        let array = data as NSArray
        let index = array.index(of: item)
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    public func removeAllData() {
        data = [SectionTableData]()
    }

    func removeItem(item: TableViewData) {
        let array = data as NSArray
        let index = array.index(of: item)
        data.remove(at: index)
        tableView.reloadData()
    }

    public func removeItemAt(index: Int, section: Int = 0) {
        tableView?.beginUpdates()
        data[section].data.remove(at: index)
        let indexPath = IndexPath(row: index, section: section)
        tableView?.deleteRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
    }

    public func insertData(items: [TableViewData], firstIndex: Int, section: Int = 0) -> [IndexPath] {
        guard items.count > 0 else {
            return []
        }

        items.forEach { data in
            self.registerItem(item: data)
        }

        tableView.beginUpdates()

        var index = firstIndex
        var indexPaths = [IndexPath]()
        let sectionItem = data[section]

        items.forEach { data in
            sectionItem.data.insert(data, at: index)
            let indexPath = IndexPath(row: index, section: section)
            indexPaths.append(indexPath)
            index = index + 1
        }

        tableView.insertRows(at: indexPaths, with: .fade)
        tableView.endUpdates()

        return indexPaths
    }

    public func add(section: SectionTableData) {
        _add(section: section)
        tableView.reloadData()
    }

    func _add(section: SectionTableData) {
        guard let rId = section.headerReuseId else {
            return
        }

        guard let className = NSClassFromString(rId) else {
            return
        }

        let bundle = Bundle(for: className)
        let nibName = rId.components(separatedBy: ".")[1]
        let nib = UINib(nibName: nibName, bundle: bundle)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: rId)

        for item in section.data {
            registerItem(item: item)
        }

        data.append(section)
    }

    public func add(sections: [SectionTableData]) {
        sections.forEach {
            _add(section: $0)
        }

        tableView.reloadData()
    }

    public func addData(_ items: [TableViewData]?) {
        guard let items = items else {
            return
        }

        guard items.count > 0 else {
            return
        }

        let count = data.count
        var indexPaths = [IndexPath]()

        if count == 0 {
            let section = SectionTableData()
            section.data.append(contentsOf: items)

            for data in section.data {
                registerItem(item: data)
            }
            data.append(section)
            tableView.reloadData()
            return
        }

        guard let sectionData = data.last else {
            return
        }

        CATransaction.begin()

        tableView.beginUpdates()

        sectionData.data.append(contentsOf: items)

        for (index, item) in items.enumerated() {
            registerItem(item: item)
            let indexPath = IndexPath(row: count + index, section: 0)
            indexPaths.append(indexPath)
        }

        tableView?.insertRows(at: indexPaths, with: .automatic)
        tableView?.endUpdates()

        CATransaction.commit()
    }

    public func registerHeader(reuseID: String) {
        if let className = NSClassFromString(reuseID) {
            let bundle = Bundle(for: className)
            let nibName = reuseID.components(separatedBy: ".")[1]
            let nib = UINib(nibName: nibName, bundle: bundle)
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseID)
        }
    }

    public func registerItem(reuseID: String) {
        if let className = NSClassFromString(reuseID) {
            let bundle = Bundle(for: className)
            let nibName = reuseID.components(separatedBy: ".")[1]

            tableView?.register(UINib(nibName: nibName, bundle: bundle), forCellReuseIdentifier: reuseID)
        }
    }

    func registerItem(item: TableViewData) {
        let reuseID = item.reuseID()
        registerItem(reuseID: reuseID)
    }

    public init(tableView: UITableView) {
        super.init()
        self.tableView = tableView
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.estimatedRowHeight = 100
        self.tableView.separatorColor = UIColor.clear
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .none
        data = [SectionTableData]()
    }

    public convenience init(tableView: UITableView, reuseIDs: [String]) {
        self.init(tableView: tableView)

        for reuseID in reuseIDs {
            registerItem(reuseID: reuseID)
        }
    }

    @objc public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].data.count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    @objc public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = data[indexPath.section]
        let dataItem = section.data[indexPath.row]

        let reuseID = dataItem.reuseID()
        let tableCell = tableView.dequeueReusableCell(withIdentifier: reuseID)

        if let loadableCell = tableCell as? UITableViewCellLoadableProtocol {
            loadableCell.loadData(dataItem, tableview: tableView)
        }

        delegate?.pinDelegate(dataItem)

        return tableCell!
    }

    @objc public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = data[section]

        guard let rId = sectionData.headerReuseId else {
            return nil
        }

        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: rId)

        if let loadableHeader = header as? UITableViewHeaderLoadableProtocol {
            loadableHeader.loadData(sectionData, tableview: tableView)
        }

        return header
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let sectionData = data[indexPath.section]
        let dataItem = sectionData.data[indexPath.row]
        return dataItem.canEdit()
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let sectionData = data[indexPath.section]
        let dataItem = sectionData.data[indexPath.row]
        return dataItem.actions()
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionData = data[indexPath.section]
        let dataItem = sectionData.data[indexPath.row]
        delegate?.tableViewManager(self, willDisplayItem: dataItem)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section < data.count {
            let sectionData = data[section]
            sectionDisplayDelegate?.tableViewManager(self, willDisplaySection: sectionData, forSection: section)
        }
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        if section < data.count {
            let sectionData = data[section]
            sectionDisplayDelegate?.tableViewManager(self, didEndDisplayingSection: sectionData, forSection: section)
        }
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionData = data[indexPath.section]
        if indexPath.row < sectionData.data.count {
            let dataItem = sectionData.data[indexPath.row]
            delegate?.tableViewManager(self, didEndDisplayingItem: dataItem)
        }
    }

    @objc public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.data[indexPath.section].data[indexPath.row]
        delegate?.didSelect(data)
        if isSelectionAllowed == false {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionData = data[section]
        return sectionData.height ?? 0
    }

    @objc public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = self.data[indexPath.section].data[indexPath.row]

        return data.height()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.tableViewManager(self, didScroll: scrollView)
    }
}
