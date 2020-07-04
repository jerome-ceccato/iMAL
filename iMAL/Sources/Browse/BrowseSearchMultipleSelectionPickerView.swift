//
//  BrowseSearchMultipleSelectionPickerView.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 18/04/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

protocol BrowseSearchMultipleSelectionDelegate: class {
    func multipleSelectionPickerView(_ pickerView: BrowseSearchMultipleSelectionPickerView, didUpdateWith selected: [String])
}

class BrowseSearchMultipleSelectionPickerView: UIView {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundToolbar: UIToolbar!
    
    private var data: [String] = []
    private var selected: [String] = []
    private weak var delegate: BrowseSearchMultipleSelectionDelegate?
    
    class func create(with data: [String], selected: [String], delegate: BrowseSearchMultipleSelectionDelegate?) -> BrowseSearchMultipleSelectionPickerView? {
        if let view = UINib(nibName: "BrowseSearchMultipleSelectionPickerView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? BrowseSearchMultipleSelectionPickerView {
            
            view.setup(with: data, selected: selected, delegate: delegate)
            return view
        }
        return nil
    }
    
    func reset() {
        selected = []
        tableView.reloadData()
    }
    
    func setup(with data: [String], selected: [String], delegate: BrowseSearchMultipleSelectionDelegate?) {
        self.data = data
        self.selected = selected
        self.delegate = delegate
        
        tableView.register(UINib(nibName: "BrowseSearchMultipleSelectionTableViewCell", bundle: nil), forCellReuseIdentifier: "BrowseSearchMultipleSelectionTableViewCell")
        
        applyTheme { [unowned self] theme in
            self.backgroundColor = theme.actionPopup.background.color
            self.tableView.backgroundColor = theme.actionPopup.background.color
            self.backgroundToolbar.themeForPicker(with: theme)
            self.tableView.reloadData()
        }
    }
}

extension BrowseSearchMultipleSelectionPickerView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BrowseSearchMultipleSelectionTableViewCell", for: indexPath) as! BrowseSearchMultipleSelectionTableViewCell
        
        let content = data[indexPath.row]
        cell.fill(with: content, isSelected: selected.contains(content))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let content = data[indexPath.row]
        if let index = selected.index(of: content) {
            selected.remove(at: index)
        }
        else {
            selected.append(content)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
        delegate?.multipleSelectionPickerView(self, didUpdateWith: selected)
    }
}
