//
//  AiringNotificationsTableViewController.swift
//  iMAL
//
//  Created by Jerome Ceccato on 18/07/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class AiringNotificationsTableViewController: SettingsBaseTableViewController {
    @IBOutlet var notificationsEnabledCheckImage: UIImageView!
    
    @IBOutlet var notificationStatusEnabledLabel: UILabel!
    @IBOutlet var notificationsTrackWatchingOnlyCheckImage: UIImageView!
    
    @IBOutlet var notificationsTimeDoNotDistrubCheckImage: UIImageView!
    @IBOutlet var notificationsTimeDoNotDistrubFromLabel: UILabel!
    @IBOutlet var notificationsTimeDoNotDistrubToLabel: UILabel!
    
    @IBOutlet var statsNumberOfAnimeLabel: UILabel!
    @IBOutlet var statsLastNotificationDateLabel: UILabel!
    @IBOutlet var statsNumberOfNotifications: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        
        let checkImage = #imageLiteral(resourceName: "success").withRenderingMode(.alwaysTemplate)
        notificationsEnabledCheckImage.image = checkImage
        notificationsTrackWatchingOnlyCheckImage.image = checkImage
        notificationsTimeDoNotDistrubCheckImage.image = checkImage
        
        refreshContent()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actions: [[() -> Void]] = [
            [self.toggleNotificationsEnabled],
            [self.editStatusEnabled],
            [self.toggleTrackWatchingOnly],
            [self.openAnimeSelectionView],
            [self.toggleDoNotDisturbMode, self.editDoNotDisturbFrom, self.editDoNotDisturbTo]
        ]
        
        DispatchQueue.main.async {
            actions[safe: indexPath.section]?[safe: indexPath.row]?()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
#if APP_STORE_BUILD
    private let statsSection = 5

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == statsSection {
            return nil
        }
        return super.tableView(tableView, titleForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == statsSection {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
#endif
}

// MARK: - Actions
private extension AiringNotificationsTableViewController {
    func toggleNotificationsEnabled() {
        let enabled = !Settings.airingNotificationsEnabled
        
        if enabled {
            AiringNotificationsCenter.shared.authorizeNotifications { granted in
                if granted {
                    self.updateNotificationsState(enabled: enabled)
                }
                else {
                    self.warnAboutNotificationPermissions()
                }
            }
        }
        else {
            updateNotificationsState(enabled: enabled)
        }
    }
    
    func editStatusEnabled() {
        let data = statusEnabledDisplayStrings
        let index = Settings.airingNotificationStatusEnabled.rawValue
        let controller = ManagedPickerViewController.picker(withData: data, selectedIndex: index, completion: { (save, index) in
            if let option = Settings.StatusEnabled(rawValue: index), save {
                Settings.airingNotificationStatusEnabled = option
                AiringNotificationsCenter.shared.refreshScheduledNotificationsIfNeeded {
                    delay(0.2) {
                        self.refreshContent()
                    }
                }
            }

            self.notificationStatusEnabledLabel.text = self.displayStringForStatus(Settings.airingNotificationStatusEnabled)
        })
        
        if let controller = controller {
            present(controller, animated: true, completion: nil)
        }
    }
    
    func toggleTrackWatchingOnly() {
        let enabled = !Settings.airingNotificationsTrackWatchedOnly
        Settings.airingNotificationsTrackWatchedOnly = enabled
        notificationsTrackWatchingOnlyCheckImage.alpha = enabled ? 1 : 0
        
        AiringNotificationsCenter.shared.refreshScheduledNotificationsIfNeeded {
            delay(0.2) {
                self.refreshContent()
            }
        }
    }
    
    func openAnimeSelectionView() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AiringNotificationsAnimeTableViewController") as? AiringNotificationsAnimeTableViewController {
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func toggleDoNotDisturbMode() {
        let enabled = !Settings.airingNotificationsDoNotDisturbEnabled
        Settings.airingNotificationsDoNotDisturbEnabled = enabled
        notificationsTimeDoNotDistrubCheckImage.alpha = enabled ? 1 : 0
        
        AiringNotificationsCenter.shared.refreshScheduledNotificationsIfNeeded {
            delay(0.2) {
                self.refreshContent()
            }
        }
    }
    
    func editDoNotDisturbFrom() {
        editDoNotDisturbTime(label: notificationsTimeDoNotDistrubFromLabel,
                             get: { Settings.airingNotificationDoNotDisturbFromTime },
                             set: { Settings.airingNotificationDoNotDisturbFromTime = $0 })
    }
    
    func editDoNotDisturbTo() {
        editDoNotDisturbTime(label: notificationsTimeDoNotDistrubToLabel,
                             get: { Settings.airingNotificationDoNotDisturbToTime },
                             set: { Settings.airingNotificationDoNotDisturbToTime = $0 })
    }
    
    func editDoNotDisturbTime(label: UILabel, get: @escaping () -> Settings.Time, set: @escaping (Settings.Time) -> Void) {
        let picker = ManagedDatePickerViewController.pickerWithSetup(setup: { picker in
            picker.datePickerMode = .time
            picker.date = Calendar.current.date(from: get().toDateComponents()) ?? Date()
            
        }, completion: { date in
            if let date = date {
                let time = Settings.Time(components: Calendar.current.dateComponents([.hour, .minute], from: date))
                set(time)
                
                if Settings.airingNotificationsDoNotDisturbEnabled {
                    AiringNotificationsCenter.shared.refreshScheduledNotificationsIfNeeded()
                }
                
                label.text = time.shortDisplayString()
            }
        })
        
        if let picker = picker {
            present(picker, animated: true, completion: nil)
        }
    }
}

// MARK: - Utils
private extension AiringNotificationsTableViewController {
    func updateNotificationsState(enabled: Bool) {
        Settings.airingNotificationsEnabled = enabled
        animateUpdate(view: notificationsEnabledCheckImage, enabled: enabled)
        
        if enabled {
            let containerView = navigationController?.view
            containerView?.makeToastActivity(.center)
            AiringNotificationsCenter.shared.refreshScheduledNotificationsIfNeeded() {
                containerView?.hideToastActivity()
            }
        }
        else {
            AiringNotificationsCenter.shared.cleanupScheduledNotifications(clearPending: true)
        }
    }
    
    func warnAboutNotificationPermissions() {
        let alert = UIAlertController(title: "Notifications disabled", message: "You need to enable notifications for iMAL in the Settings app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
            self.openSettings()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
    }

    func refreshContent() {
        notificationsEnabledCheckImage.alpha = Settings.airingNotificationsEnabled ? 1 : 0
        notificationsTrackWatchingOnlyCheckImage.alpha = Settings.airingNotificationsTrackWatchedOnly ? 1 : 0
        notificationsTimeDoNotDistrubCheckImage.alpha = Settings.airingNotificationsDoNotDisturbEnabled ? 1 : 0
        
        notificationStatusEnabledLabel.text = displayStringForStatus(Settings.airingNotificationStatusEnabled)
        notificationsTimeDoNotDistrubFromLabel.text = Settings.airingNotificationDoNotDisturbFromTime.shortDisplayString()
        notificationsTimeDoNotDistrubToLabel.text = Settings.airingNotificationDoNotDisturbToTime.shortDisplayString()
        
        #if APP_STORE_BUILD
        #else
        AiringNotificationsCenter.shared.getStats { stats in
            self.refreshStats(stats: stats)
        }
        #endif
    }
    
    func refreshStats(stats: AiringNotificationsCenter.Stats) {
        statsNumberOfAnimeLabel.text = "\(stats.numberOfAnime)"
        statsNumberOfNotifications.text = "\(stats.scheduledNotifications)/\(stats.notificationLimit)"
        statsLastNotificationDateLabel.text = stats.lastScheduledDate?.shortDateDisplayString
    }
    
    func animateUpdate(view: UIView, enabled: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
            view.alpha = enabled ? 1 : 0
        })
    }
    
    var statusEnabledDisplayStrings: [String] {
        return ["Watching only", "Watching and Plan to Watch", "All"]
    }
    
    func displayStringForStatus(_ status: Settings.StatusEnabled) -> String {
        return statusEnabledDisplayStrings[status.rawValue]
    }
}
