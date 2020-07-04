//
//  SettingsAppTableViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 01/03/2018.
//  Copyright © 2018 IATGOF. All rights reserved.
//

import UIKit
import AlamofireImage

class SettingsAppTableViewController: SettingsBaseTableViewController {
    @IBOutlet var themeLabel: UILabel!
    @IBOutlet var homepageActiveLabel: UILabel!
    @IBOutlet var listsStyleLabel: UILabel!
    @IBOutlet var animelistExpandOptionsLabel: UILabel!
    @IBOutlet var mangalistExpandOptionsLabel: UILabel!
    @IBOutlet var filterRXCheckImage: UIImageView!
    @IBOutlet var mangaPreferredMetricLabel: UILabel!
    @IBOutlet var quickAddDelayLabel: UILabel!
    @IBOutlet var automaticDatesEnabledCheckImage: UIImageView!
    @IBOutlet var pinchGestureEnabledCheckImage: UIImageView!
    @IBOutlet var invertTapGesturesEnabledCheckImage: UIImageView!
    @IBOutlet var invertTapGesturesOthersEnabledCheckImage: UIImageView!
    @IBOutlet var orientationLockLabel: UILabel!
    @IBOutlet var airingDatesCheckImage: UIImageView!
    @IBOutlet var airingDatesOffsetLabel: UILabel!
    @IBOutlet var airingNotificationsCheckImage: UIImageView!
    @IBOutlet var preventEditingUntilSynchedCheckImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Customization"
        
        let checkImage = #imageLiteral(resourceName: "success").withRenderingMode(.alwaysTemplate)
        filterRXCheckImage.image = checkImage
        pinchGestureEnabledCheckImage.image = checkImage
        invertTapGesturesEnabledCheckImage.image = checkImage
        invertTapGesturesOthersEnabledCheckImage.image = checkImage
        airingDatesCheckImage.image = checkImage
        airingNotificationsCheckImage.image = checkImage
        preventEditingUntilSynchedCheckImage.image = checkImage
        automaticDatesEnabledCheckImage.image = checkImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        themeLabel.text = Settings.theme.displayString
        homepageActiveLabel.text = Settings.homePageController.displayString
        listsStyleLabel.text = Settings.listsStyle.displayString
        animelistExpandOptionsLabel.text = Settings.animeListSectionsExpandOptions.displayString
        mangalistExpandOptionsLabel.text = Settings.mangaListSectionsExpandOptions.displayString.replacingOccurrences(of: "Watching", with: "Reading")
        filterRXCheckImage.alpha = Settings.filterRatedX ? 1 : 0
        mangaPreferredMetricLabel.text = Settings.preferredMangaMetric.displayString
        pinchGestureEnabledCheckImage.alpha = Settings.pinchToCollapseEnabled ? 1 : 0
        invertTapGesturesEnabledCheckImage.alpha = Settings.invertTapGesturesOnMyList ? 1 : 0
        invertTapGesturesOthersEnabledCheckImage.alpha = Settings.invertTapGesturesOnOthers ? 1 : 0
        airingDatesCheckImage.alpha = Settings.airingDatesEnabled ? 1 : 0
        airingDatesOffsetLabel.text = Settings.airingTimeOffset?.displayString ?? ""
        airingNotificationsCheckImage.alpha = Settings.airingDatesEnabled && Settings.airingNotificationsEnabled ? 1 : 0
        preventEditingUntilSynchedCheckImage.alpha = Settings.preventEditingUntilSynched ? 1 : 0
        quickAddDelayLabel.text = displayString(forDelay: Settings.listIncrementDelay)
        automaticDatesEnabledCheckImage.alpha = Settings.enableAutomaticDates ? 1 : 0
        orientationLockLabel.text = Settings.orientationPreference.displayString
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track(view: .settings)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actions: [[(IndexPath) -> Void]] = [
            [self.themePressed],
            [self.homeActivePressed],
            [self.listsStylePressed],
            [self.animelistExpandOptionsPressed, self.mangalistExpandOptionsPressed],
            [self.quickAddDelayPressed],
            [self.automaticDatesPressed],
            [self.enablePinchToCollapsePressed],
            [self.invertTapGesturesPressed, self.invertTapGesturesOthersPressed],
            [self.orientationLockPressed],
            [self.filterRxPressed],
            [self.mangaPreferredMetricPressed],
            [self.airingDateEnabledPressed, self.airingDateOffsetPressed],
            [self.airingNotificationsPressed],
            [self.preventEditingUntilSynchedPressed]
        ]
        
        DispatchQueue.main.async {
            actions[safe: indexPath.section]?[safe: indexPath.row]?(indexPath)
        }
    }
}

// MARK: - Actions
private extension SettingsAppTableViewController {
    func themePressed(_ indexPath: IndexPath) {
        let data = Settings.Theme.availableOptionsDisplayStrings
        let index = data.index(of: Settings.theme.displayString) ?? 0
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = Settings.Theme(rawValue: Settings.Theme.availableOptionsStrings[index]), save {
                Settings.theme = option
                delay(0.25) {
                    ThemeManager.updateTheme()
                }
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.themeLabel.text = Settings.theme.displayString
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func homeActivePressed(_ indexPath: IndexPath) {
        let data = Settings.HomePage.availableOptionsDisplayStrings
        let index = Settings.homePageController.rawValue
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = Settings.HomePage(rawValue: index), save {
                Settings.homePageController = option
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.homepageActiveLabel.text = Settings.homePageController.displayString
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func listsStylePressed(_ indexPath: IndexPath) {
        let data = ListDisplayStyle.availableStylesDisplayStrings
        let index = Settings.listsStyle.rawValue
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = ListDisplayStyle(rawValue: index), save {
                Settings.listsStyle = option
                ListDisplayProxy.broadcastListDisplayStyleChangedNotification()
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.listsStyleLabel.text = Settings.listsStyle.displayString
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func animelistExpandOptionsPressed(_ indexPath: IndexPath) {
        let data = Settings.ExpandOptions.availableOptionsDisplayStrings()
        let index = Settings.animeListSectionsExpandOptions.rawValue
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = Settings.ExpandOptions(rawValue: index), save {
                Settings.animeListSectionsExpandOptions = option
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.animelistExpandOptionsLabel.text = Settings.animeListSectionsExpandOptions.displayString
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func mangalistExpandOptionsPressed(_ indexPath: IndexPath) {
        let data = Settings.ExpandOptions.availableOptionsDisplayStrings(manga: true)
        let index = Settings.mangaListSectionsExpandOptions.rawValue
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = Settings.ExpandOptions(rawValue: index), save {
                Settings.mangaListSectionsExpandOptions = option
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.mangalistExpandOptionsLabel.text = Settings.mangaListSectionsExpandOptions.displayString.replacingOccurrences(of: "Watching", with: "Reading")
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func filterRxPressed(_ indexPath: IndexPath) {
        Settings.filterRatedX = !Settings.filterRatedX
        UIView.animate(withDuration: 0.1, animations: {
            self.filterRXCheckImage.alpha = Settings.filterRatedX ? 1 : 0
        })
        tableView.deselectRow(at: indexPath, animated: true)
        
        Database.shared.broadcastRxFilterChangedNotification()
    }
    
    func mangaPreferredMetricPressed(_ indexPath: IndexPath) {
        let data = Settings.MangaMetric.availableOptionsDisplayStrings
        let index = Settings.preferredMangaMetric.rawValue
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = Settings.MangaMetric(rawValue: index), save {
                Settings.preferredMangaMetric = option
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.mangaPreferredMetricLabel.text = Settings.preferredMangaMetric.displayString
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func displayString(forDelay delay: TimeInterval) -> String {
        return String(format: "%.1f sec", delay)
    }
    
    func quickAddDelayPressed(_ indexPath: IndexPath) {
        let data = stride(from: 0, to: 2.1, by: 0.1).map(self.displayString(forDelay:))
        let index = Int(round(Settings.listIncrementDelay * 10))
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if save {
                let option = TimeInterval(index) / 10
                Settings.listIncrementDelay = option
                self.quickAddDelayLabel.text = self.displayString(forDelay: option)
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func automaticDatesPressed(_ indexPath: IndexPath) {
        Settings.enableAutomaticDates = !Settings.enableAutomaticDates
        UIView.animate(withDuration: 0.1, animations: {
            self.automaticDatesEnabledCheckImage.alpha = Settings.enableAutomaticDates ? 1 : 0
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func enablePinchToCollapsePressed(_ indexPath: IndexPath) {
        Settings.pinchToCollapseEnabled = !Settings.pinchToCollapseEnabled
        UIView.animate(withDuration: 0.1, animations: {
            self.pinchGestureEnabledCheckImage.alpha = Settings.pinchToCollapseEnabled ? 1 : 0
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func invertTapGesturesPressed(_ indexPath: IndexPath) {
        Settings.invertTapGesturesOnMyList = !Settings.invertTapGesturesOnMyList
        UIView.animate(withDuration: 0.1, animations: {
            self.invertTapGesturesEnabledCheckImage.alpha = Settings.invertTapGesturesOnMyList ? 1 : 0
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func invertTapGesturesOthersPressed(_ indexPath: IndexPath) {
        Settings.invertTapGesturesOnOthers = !Settings.invertTapGesturesOnOthers
        UIView.animate(withDuration: 0.1, animations: {
            self.invertTapGesturesOthersEnabledCheckImage.alpha = Settings.invertTapGesturesOnOthers ? 1 : 0
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func orientationLockPressed(_ indexPath: IndexPath) {
        let data = Settings.Orientation.availableOptionsDisplayStrings
        let index = Settings.orientationPreference.rawValue
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = Settings.Orientation(rawValue: index), save {
                Settings.orientationPreference = option
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.orientationLockLabel.text = Settings.orientationPreference.displayString
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func airingDateEnabledPressed(_ indexPath: IndexPath) {
        Settings.airingDatesEnabled = !Settings.airingDatesEnabled
        if !Settings.airingDatesEnabled {
            Settings.airingNotificationsEnabled = false
            AiringNotificationsCenter.shared.cleanupScheduledNotifications(clearPending: true)
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.airingDatesCheckImage.alpha = Settings.airingDatesEnabled ? 1 : 0
            self.airingNotificationsCheckImage.alpha = Settings.airingDatesEnabled && Settings.airingNotificationsEnabled ? 1 : 0
        })
        tableView.deselectRow(at: indexPath, animated: true)
        
        if Settings.airingDatesEnabled {
            Database.shared.updateAiringAnimeDataIfNeeded()
        }
    }
    
    func airingNotificationsPressed(_ indexPath: IndexPath) {
        if !AiringNotificationsCenter.shared.canUseNotifications() {
            let alert = UIAlertController(title: "Sorry!", message: "Notifications are only available for iOS 10+.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ":(", style: .cancel, handler: nil))
            present(alert, animated: true) {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            return
        }
        
        if Settings.airingDatesEnabled {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "AiringNotificationsTableViewController") {
                navigationController?.pushViewController(controller, animated: true)
            }
            delay(0.3) {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "You cannot enable airing notifications if airing data is disabled", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true) {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    func airingDateOffsetPressed(_ indexPath: IndexPath) {
        let data = [(0 ..< 11).map({ "\($0) day\($0 > 1 ? "s" : "")" }),
                    (0 ..< 24).map({ "\($0) hour\($0 > 1 ? "s" : "")" }),
                    (0 ..< 60).map({ "\($0) min\($0 > 1 ? "s" : "")" })]
        let indexes = Settings.airingTimeOffset?.pack()
        
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndexes: indexes, completion: { (save, indexes) in
            if save {
                Settings.airingTimeOffset = AiringData.Offset(raw: indexes)
                Database.shared.invalidateAiringTimeOffset()
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.airingDatesOffsetLabel.text = Settings.airingTimeOffset?.displayString ?? ""
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func preventEditingUntilSynchedPressed(_ indexPath: IndexPath) {
        Settings.preventEditingUntilSynched = !Settings.preventEditingUntilSynched
        UIView.animate(withDuration: 0.1, animations: {
            self.preventEditingUntilSynchedCheckImage.alpha = Settings.preventEditingUntilSynched ? 1 : 0
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

