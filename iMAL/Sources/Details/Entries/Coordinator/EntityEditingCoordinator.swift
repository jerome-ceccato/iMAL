//
//  EntityEditingCoordinator.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

protocol EntityEditingCoordinatorDelegate: class {
    func changesDidUpdate(coordinator: EntityEditingCoordinator)
    func presentEditController(controller: UIViewController)
}

class EntityEditingCoordinator {
    struct UserDate: OptionSet {
        let rawValue: Int
        
        static let start = UserDate(rawValue: 1 << 0)
        static let end = UserDate(rawValue: 1 << 1)
        
        static let both: UserDate = [.start, .end]
    }
    
    var delegate: EntityEditingCoordinatorDelegate?
    
    var statusUserEntry: EditableStatusEntryView!
    var scoreUserEntry: EditableScoreEntryView!
    var startDateUserEntry: EditableDateEntryView!
    var endDateUserEntry: EditableDateEntryView!
    var tagsUserEntry: EditableTagsEntryView!
    
    var changes: EntityChanges!
    
    init(delegate: EntityEditingCoordinatorDelegate?) {
        self.delegate = delegate
    }
    
    func hasChanges() -> Bool {
        return changes?.hasChanges() ?? false
    }
    
    func setEntriesCoordinator() {
        [statusUserEntry, scoreUserEntry, startDateUserEntry, endDateUserEntry, tagsUserEntry].forEach { entry in
            entry.coordinator = self
        }
    }
    
    func updateAllFields() {
        statusUserEntry.content = changes.specialStatus ?? changes.statusDisplayString
        scoreUserEntry.content = changes.score.scoreDisplayString
        
        startDateUserEntry.type = .start
        endDateUserEntry.type = .end
        
        startDateUserEntry.content = changes.originalEntity.startDate?.shortDateDisplayString
        endDateUserEntry.content = changes.originalEntity.endDate?.shortDateDisplayString
        tagsUserEntry.content = changes.originalEntity.tags.joined(separator: ", ")
    }
    
    func scoreDisplayStrings() -> [String] {
        return Int.scoresDisplayStrings().map { $0.isEmpty ? "None" : $0 }
    }
    
    func updateScore(_ score: Int) {
        changes.score = score
        delegate?.changesDidUpdate(coordinator: self)
    }
    
    func updateDate(_ date: Date, type: EditableDateEntryView.DateType) {
        switch type {
        case .start:
            changes.startDate = date
        case .end:
            changes.endDate = date
        }
        delegate?.changesDidUpdate(coordinator: self)
    }
    
    func revertAllChanges() {
        changes.revertChanges()
        updateAllFields()
        delegate?.changesDidUpdate(coordinator: self)
    }
    
    func automaticallyFill(dates: UserDate, with date: Date?) {
        if Settings.enableAutomaticDates {
            if dates.contains(.start) && changes.originalEntity.startDate == nil {
                changes.startDate = date
                startDateUserEntry.content = changes.startDate?.shortDateDisplayString
            }
            if dates.contains(.end) && changes.originalEntity.endDate == nil {
                changes.endDate = date
                endDateUserEntry.content = changes.endDate?.shortDateDisplayString
            }
        }
    }
    
    // MARK: - Override
    
    func statusDisplayStrings() -> [String] {
        return []
    }
    
    func updateStatus(withSelectedString status: String) {}
    func apiUpdateEntityMethod(changes: EntityChanges) -> API! { return nil }
    func changes(forNewTags tags: [String]) -> EntityChanges! { return nil }
    
    func commitChanges(_ loadingDelegate: RootViewController, completion: (() -> Void)? = nil) {
        if changes.hasChanges() {
            apiUpdateEntityMethod(changes: changes).request(loadingDelegate: loadingDelegate) { success in
                if success {
                    loadingDelegate.view.makeSuccessToast {
                        SocialNetworkManager.postChanges(self.changes, fromViewController: loadingDelegate)
                        self.changes.commitChanges()
                        CurrentUser.me.updateEntity(self.changes.originalEntity)
                        completion?()
                    }
                }
            }
        }
        else {
            completion?()
        }
    }

    func commitTagsChanges(_ tags: String, editController: TagEditViewController, completion: (() -> Void)? = nil) {
        let newTags = tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
        let changes = self.changes(forNewTags: newTags)!
        apiUpdateEntityMethod(changes: changes).request(loadingDelegate: editController) { success in
            if success {
                editController.view.makeSuccessToast {
                    SocialNetworkManager.postChanges(changes, fromViewController: editController.navigationController ?? editController)
                    changes.commitChanges()
                    self.tagsUserEntry.textField.text = tags
                    CurrentUser.me.updateEntity(changes.originalEntity)
                    completion?()
                }
            }
        }
    }
}
