//
//  ManagedTableView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 25/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

protocol ManagedTableViewCell {
    func fill(with data: Any, context: ManagedTableView.Context)
}

typealias TableViewData = [(section: String?, items: [Any])]
class ManagedTableView: UITableView {
    @IBOutlet private var heightConstraint: NSLayoutConstraint!

    private var data: TableViewData!
    private var heightForItem: ((Any) -> CGFloat)!
    private var selectAction: ((Any) -> Void)!
    
    var headerHeight: CGFloat = 24
    var headerNibName: String?
    var additionalSpacing: CGFloat = 26
    
    var manageScrollAutomatically: Bool = false
    
    struct Context {
        var indexPath: IndexPath
        var data: TableViewData
        
        init(indexPath: IndexPath, data: TableViewData) {
            self.indexPath = indexPath
            self.data = data
        }
    }
    
    var height: CGFloat {
        return heightConstraint.constant
    }
    
    @discardableResult
    func setup(withSimpleData data: [Any], rowHeight: CGFloat, selectAction: @escaping (Any) -> Void) -> Bool {
        return setup(withData: [(section: nil, items: data)], heightForItem: { _ in rowHeight }, selectAction: selectAction)
    }
    
    @discardableResult
    func setup(withData data: TableViewData, heightForItem: @escaping (Any) -> CGFloat, selectAction: @escaping (Any) -> Void) -> Bool {
        if let data = purgedData(data) {
            
            self.data = data
            self.heightForItem = heightForItem
            self.selectAction = selectAction
            
            delegate = self
            dataSource = self
            
            if let headerNibName = headerNibName {
                register(UINib(nibName: headerNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: "ManagedTableViewHeader")
            }
            heightConstraint.constant = requiredHeightForTableView(data: data, heightForItem: heightForItem)
            reloadData()
            
            return true
        }
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if manageScrollAutomatically {
            isScrollEnabled = bounds.height < contentSize.height
        }
    }
}

private extension ManagedTableView {
    func purgedData(_ data: TableViewData) -> TableViewData? {
        let ret = data.compactMap { (section, items) in items.count > 0 ? (section: section, items: items) : nil }
        return ret.isEmpty ? nil : ret
    }
    
    func requiredHeightForTableView(data: TableViewData, heightForItem: @escaping (Any) -> CGFloat) -> CGFloat {
        return data.enumerated().reduce(0) { height, data in
            return height + tableView(self, heightForHeaderInSection: data.offset) + heightForItems(data.element.items, heightForItem: heightForItem)
        }
    }
    
    func heightForItems(_ items: [Any], heightForItem: (Any) -> CGFloat) -> CGFloat {
        let hasSeparators = separatorStyle != .none
        
        return items.reduce(0) { h, item in
            return h + heightForItem(item) + (hasSeparators ? 1 : 0)
        }
    }
}

extension ManagedTableView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForItem(data[indexPath.section].items[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManagedTableViewCell", for: indexPath)
        
        if let cellData = cell as? ManagedTableViewCell {
            let context = Context(indexPath: indexPath, data: data)
            cellData.fill(with: data[indexPath.section].items[indexPath.row], context: context)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection {
            tableView.indexPathsForSelectedRows?.filter({ $0.section == indexPath.section && $0.row != indexPath.row }).forEach({ tableView.deselectRow(at: $0, animated: true) })
        }
        else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        selectAction(data[indexPath.section].items[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection {
            if tableView.indexPathsForSelectedRows?.find({ $0.section == indexPath.section }) == nil {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerTitle = data[section].section {
            if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ManagedTableViewHeader") as? ManagedTableViewHeader {
                header.titleLabel.text = headerTitle
                return header
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return data[section].section != nil ? (section == 0 ? headerHeight : headerHeight + additionalSpacing) : 0.1
    }
}
