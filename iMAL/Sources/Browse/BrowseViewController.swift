//
//  BrowseViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 10/03/17.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class BrowseViewController: RootViewController {
    @IBOutlet var sectionTitleLabels: [UILabel]!
    @IBOutlet var indicatorView: UIView!
    
    @IBOutlet var contentScrollView: UIScrollView!
    @IBOutlet var indicatorAnimeAlignmentConstraint: NSLayoutConstraint!
    
    @IBOutlet var tabbarView: UIView!
    @IBOutlet var tabbarLayoutConstraints: [NSLayoutConstraint]!
    
    private var data: BrowseData!
    
    private var animeCollectionViewController: BrowseCollectionViewController?
    private var mangaCollectionViewController: BrowseCollectionViewController?
    
    private var currentPage: EntityKind = EntityKind.anime
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS < 10 doesn't handle autolayout, and iOS 11 only supports autolayout
        tabbarView.removeFromSuperview()
        if #available(iOS 11, *) {} else {
            tabbarView.removeConstraints(tabbarLayoutConstraints)
            tabbarView.autoresizingMask = []
            tabbarView.translatesAutoresizingMaskIntoConstraints = true
        }
        
        navigationItem.titleView = tabbarView
        automaticallyAdjustsScrollViewInsets = false
        
        API.browseLanding.request(loadingDelegate: self) { (success: Bool, data: BrowseData?) in
            if success, let data = data {
                self.data = data
                self.reloadContent()
            }
        }
        
        applyTheme { [unowned self] theme in
            self.view.backgroundColor = theme.global.viewBackground.color
            self.sectionTitleLabels.forEach { label in
                label.textColor = theme.global.bars.title.color
            }
            self.indicatorView.backgroundColor = theme.global.activeTint.color
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? BrowseCollectionViewController {
            if segue.identifier == "AnimeBrowseCollectionViewController" {
                animeCollectionViewController = controller
                controller.parentBrowseController = self
                controller.entityKind = .anime
                controller.sections = data?.anime
            }
            else if segue.identifier == "MangaBrowseCollectionViewController" {
                mangaCollectionViewController = controller
                controller.parentBrowseController = self
                controller.entityKind = .manga
                controller.sections = data?.manga
            }
        }
    }
    
    func reloadContent() {
        animeCollectionViewController?.sections = data.anime
        mangaCollectionViewController?.sections = data.manga
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let targetOffsetX = (currentPage == .anime ? 0 : 1) * size.width
        coordinator.animate(alongsideTransition: { _ in
            self.contentScrollView?.contentOffset = CGPoint(x: targetOffsetX, y: 0)
        }, completion: nil)
    }
}

extension BrowseViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page: EntityKind = scrollView.contentOffset.x > scrollView.bounds.width / 2 ? .manga : .anime
        if page != currentPage {
            currentPage = page
            animatePageChange(page: page)
        }
    }
    
    private func animatePageChange(page: EntityKind) {
        UIView.animate(withDuration: 0.2) {
            self.indicatorAnimeAlignmentConstraint.priority = UILayoutPriority(rawValue: page == .anime ? 950 : 850)
            self.tabbarView.layoutIfNeeded()
        }
    }
    
    @IBAction func animeTabPressed() {
        if currentPage != .anime {
            animatePageChange(page: .anime)
            contentScrollView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
    @IBAction func mangaTabPressed() {
        if currentPage != .manga {
            animatePageChange(page: .manga)
            contentScrollView.setContentOffset(CGPoint(x: contentScrollView.bounds.width, y: 0), animated: true)
        }
    }
}

