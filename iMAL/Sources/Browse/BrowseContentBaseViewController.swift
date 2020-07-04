//
//  BrowseContentBaseViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 30/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseContentBaseViewController: RootViewController {
    var tableView: UITableView! {
        return tableViewController?.tableView
    }
    var tableViewController: UITableViewController!

    var entityKind: EntityKind!
    
    private var isLoading: Bool = false
    private var canLoadMore: Bool = false
    var currentPage: Int = 0
    var data: [Entity] = []
    
    func browseAPI() -> API? {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrentUser.me.observing.observe(from: self, options: .all) { [weak self] _ in
            self?.tableView?.reloadData()
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.tableView?.backgroundColor = theme.global.viewBackground.color
            self.tableView?.indicatorStyle = theme.global.scrollIndicators.style
            self.tableView?.separatorColor = theme.separators.heavy.color
            self.tableView?.reloadData()
        }
    }
    
    deinit {
        CurrentUser.me.observing.stopObserving(from: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UITableViewController" {
            tableViewController = segue.destination as? UITableViewController
            
            tableViewController.tableView.delegate = self
            tableViewController.tableView.dataSource = self
            
            loadContent(append: false)
        }
    }
    
    func shouldIncludeEntity(_ entity: Entity) -> Bool {
        return !(Settings.filterRatedX && entity.classification == EntityRating.hentai.shortSymbol)
    }
    
    func clearReload() {
        data = []
        isLoading = false
        canLoadMore = false
        currentPage = 0
        tableView.reloadData()
        
        loadContent(append: false)
    }
    
    func loadContent(append: Bool) {
        guard !isLoading else {
            return
        }
        
        if append {
            currentPage += 1
        }
        else {
            currentPage  = 0
        }
        
        if let apiCall = browseAPI() {
            isLoading = true
            apiCall.request(loadingDelegate: append ? nil : self) { (success: Bool, entities: [Entity]?) in
                if success, let entities = entities {
                    if append {
                        self.data.append(contentsOf: entities.filter(self.shouldIncludeEntity))
                    }
                    else {
                        self.data = entities.filter(self.shouldIncludeEntity)
                    }
                    self.tableView.reloadData()
                }
                self.updateLoadMore(newEntities: entities ?? [])
                self.isLoading = false
            }
        }
    }
    
    func updateLoadMore(newEntities: [Entity]) {
        loadMore(false)
        canLoadMore = newEntities.count >= limitPerPage
    }
}

// MARK: - TableView Delegate
extension BrowseContentBaseViewController: UITableViewDataSource, UITableViewDelegate, EntityCellLongPressDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("tableView(_: cellForRowAt:) needs to be overriden")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        DispatchQueue.main.async {
            self.showEntityDetails(entity: self.data[indexPath.row])
        }
    }
    
    func didLongPressCell(_ cell: EntityOwnerCell) {
        showEntityDetails(entity: cell.entity, alternativeAction: true)
    }
}

extension BrowseContentBaseViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canLoadMore {
            if let lastVisibleRow = tableView.indexPathsForVisibleRows?.max() {
                triggerLoadMore(for: lastVisibleRow)
            }
        }
    }
}

// MARK: - Load more
private extension BrowseContentBaseViewController {
    var limitPerPage: Int {
        return 50
    }
    
    var itemsLeftThreshold: Int {
        return 15
    }
    
    func triggerLoadMore(for indexPath: IndexPath) {
        if data.count - itemsLeftThreshold <= indexPath.row {
            if !isLoading {
                loadMore(true)
            }
        }
    }
    
    func loadMore(_ load: Bool) {
        if load {
            tableView.tableFooterView = loadMoreLoaderView()
            loadContent(append: true)
        }
        else {
            tableView.tableFooterView = emptyFooterView()
        }
    }
    
    func loadMoreLoaderView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loader.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loader)
        view.centerSubview(loader)
        loader.startAnimating()
        
        return view
    }
    
    func emptyFooterView() -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.clear
        return view
    }
}
