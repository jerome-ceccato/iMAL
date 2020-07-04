//
//  BrowseCollectionViewController.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 10/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var entityKind: EntityKind = .anime
    var sections: BrowseData.Section? {
        didSet {
            updateVisibleSections()
        }
    }
    
    private var visibleSections: [[Entity]] = []
    private var sectionKinds: [BrowseData.Section.Kind] = []
    
    var parentBrowseController: BrowseViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        collectionView?.contentInset.top += 10
        collectionView?.contentInset.bottom += 10
        collectionView?.register(UINib(nibName: "BrowseMainCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "BrowseMainCollectionReusableView")
        collectionView?.register(UINib(nibName: "BrowseSearchCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "BrowseSearchCollectionReusableView")
        
        Database.shared.handleRxFilterChangedNotification(self) { [weak self] in
            self?.updateVisibleSections()
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.collectionView?.backgroundColor = theme.global.viewBackground.color
            self.collectionView?.indicatorStyle = theme.global.scrollIndicators.style
            self.collectionView?.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.unregister(self)
    }
    
    // MARK: - Actions
    
    private func showSearchView(entityKind: EntityKind) {
        CurrentUser.me.requireUserList(type: entityKind, loadingDelegate: parentBrowseController) {
            if let controller = UIStoryboard(name: "BrowseContent", bundle: nil).instantiateViewController(withIdentifier: "BrowseNameSearchContentViewController") as? BrowseNameSearchContentViewController {
                controller.entityKind = entityKind
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    private func showBrowseView(entityKind: EntityKind) {
        CurrentUser.me.requireUserList(type: entityKind, loadingDelegate: parentBrowseController) {
            if let controller = UIStoryboard(name: "BrowseContent", bundle: nil).instantiateViewController(withIdentifier: "BrowseSearchPanelViewController") as? BrowseSearchPanelViewController {
                controller.entityKind = entityKind
                
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    private func showContentView(section: BrowseData.Section.Kind, entityKind: EntityKind) {
        CurrentUser.me.requireUserList(type: entityKind, loadingDelegate: parentBrowseController) {
            if section == .schedule {
                if let controller = UIStoryboard(name: "BrowseContent", bundle: nil).instantiateViewController(withIdentifier: "BrowseScheduleViewController") as? BrowseScheduleViewController {
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
            else {
                if let controller = UIStoryboard(name: "BrowseContent", bundle: nil).instantiateInitialViewController() as? BrowseContentViewController {
                    controller.entityKind = entityKind
                    controller.contentKind = section
                    
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    func showEntityView(entity: Entity, alternative: Bool) {
        CurrentUser.me.requireUserList(type: entityKind, loadingDelegate: parentBrowseController) {
            self.parentBrowseController?.showEntityDetails(entity: entity, alternativeAction: alternative)
        }
    }
    
    // MARK: - Content
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.reloadData()
        }, completion: nil)
    }
    
    private func updateVisibleSections() {
        if let sections = sections {
            let infos = sections.compiled().filter(self.sectionShouldBeVisible)
            visibleSections = infos.map { $0.entities }
            sectionKinds = infos.map { $0.kind }
        }
        else {
            visibleSections = []
            sectionKinds = []
        }
        
        UIView.performWithoutAnimation {
            collectionView?.reloadData()
            view.layoutIfNeeded()
        }
    }
    
    private func sectionShouldBeVisible(_ section: (entities: [Entity], kind: BrowseData.Section.Kind)) -> Bool {
        if Settings.filterRatedX {
            if entityKind == .anime && section.kind == .justAdded {
                return false
            }
            else if entityKind == .manga && (section.kind == .upcoming || section.kind == .justAdded) {
                return false
            }
        }
        return true
    }
    
    // MARK: UICollectionViewDelegate
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleSections.count + (visibleSections.isEmpty ? 0 : 2)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 0
        }
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseContainerCollectionViewCell", for: indexPath) as! BrowseContainerCollectionViewCell
    
        cell.fill(with: visibleSections[indexPath.section - 2], parentController: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        return BrowseContainerCollectionViewCell.requiredSize(layout: layout)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            if indexPath.section == 0 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BrowseSearchCollectionReusableView", for: indexPath) as! BrowseMainCollectionReusableView
                
                header.fill(with: entityKind) { [weak self] in
                    if let this = self {
                        this.showSearchView(entityKind: this.entityKind)
                    }
                }
                return header
            }
            else if indexPath.section == 1 {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BrowseMainCollectionReusableView", for: indexPath) as! BrowseMainCollectionReusableView
                
                header.fill(with: entityKind) { [weak self] in
                    if let this = self {
                        this.showBrowseView(entityKind: this.entityKind)
                    }
                }
                return header
            }
            else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BrowseHeaderCollectionReusableView", for: indexPath) as! BrowseHeaderCollectionReusableView
                
                header.fill(with: sectionKinds[indexPath.section - 2]) { [weak self] in
                    if let this = self {
                        this.showContentView(section: this.sectionKinds[indexPath.section - 2], entityKind: this.entityKind)
                    }
                }
                return header
            }
        }
        return super.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.section == 0 {
            showSearchView(entityKind: entityKind)
        }
        else if indexPath.section == 1 {
            showBrowseView(entityKind: entityKind)
        }
        else {
            showContentView(section: sectionKinds[indexPath.section - 2], entityKind: entityKind)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: [40, 80, 50][min(section, 2)])
    }
}
