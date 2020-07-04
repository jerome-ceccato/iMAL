//
//  EditableChaptersEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableChaptersEntryView: EditableUserEntryView {
    
    var mangaCoordinator: MangaEditingCoordinator {
        return coordinator as! MangaEditingCoordinator
    }
    
    func updateReadChapters(_ chapters: Int) {
        textField.text = "\(chapters)"
    }
    
    override func accessoryToolbar(with toolbar: UIToolbar) -> UIToolbar? {
        toolbar.items = [
            UIBarButtonItem(title: "- CH", style: .plain, target: self, action: #selector(self.prevChapter)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "+ CH", style: .plain, target: self, action: #selector(self.nextChapter))
        ]
        return toolbar
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            self.textField.tintColor = theme.global.keyboardIndicator.color
        }
    }
}

extension EditableChaptersEntryView {
    @objc func nextChapter() {
        updateChapterCount(1)
    }
    
    @objc func prevChapter() {
        updateChapterCount(-1)
    }
    
    func updateChapterCount(_ shift: Int) {
        if var chapters = Int(textField.textString) {
            chapters = max(0, chapters + shift)
            let maxChapters = mangaCoordinator.numberOfChaptersInSeries()
            if maxChapters > 0 && chapters > maxChapters {
                updateReadChapters(maxChapters)
                mangaCoordinator.updateChapterCount(maxChapters)
            }
            else {
                updateReadChapters(chapters)
                mangaCoordinator.updateChapterCount(chapters)
            }
        }
        else if shift > 0 {
            updateReadChapters(shift)
            mangaCoordinator.updateChapterCount(shift)
        }
    }
}

extension EditableChaptersEntryView {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let targetString: String = (textField.textString as NSString).replacingCharacters(in: range, with: string)
        
        if targetString.isEmpty {
            updateReadChapters(0)
            mangaCoordinator.updateChapterCount(0)
            return false
        }
        else if let chapters = Int(targetString) {
            let maxChapters = mangaCoordinator.numberOfChaptersInSeries()
            if maxChapters > 0 && chapters > maxChapters {
                updateReadChapters(maxChapters)
                mangaCoordinator.updateChapterCount(maxChapters)
                return false
            }
            else if chapters != 0 && targetString.starts(with: "0") {
                updateReadChapters(chapters)
                mangaCoordinator.updateChapterCount(chapters)
                return false
            }
            
            mangaCoordinator.updateChapterCount(chapters)
            return true
        }
        return false
    }
}
