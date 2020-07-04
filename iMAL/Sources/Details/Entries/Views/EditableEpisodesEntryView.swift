//
//  EditableEpisodesEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 27/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableEpisodesEntryView: EditableUserEntryView {
    
    var animeCoordinator: AnimeEditingCoordinator {
        return coordinator as! AnimeEditingCoordinator
    }
    
    func updateWatchedEpisodes(_ episodes: Int) {
        textField.text = "\(episodes)"
    }
    
    override func accessoryToolbar(with toolbar: UIToolbar) -> UIToolbar? {
        toolbar.items = [
            UIBarButtonItem(title: "- EP", style: .plain, target: self, action: #selector(self.prevEpisode)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "+ EP", style: .plain, target: self, action: #selector(self.nextEpisode))
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

extension EditableEpisodesEntryView {
    @objc func nextEpisode() {
        updateEpisodeCount(1)
    }
    
    @objc func prevEpisode() {
        updateEpisodeCount(-1)
    }
    
    func updateEpisodeCount(_ shift: Int) {
        if var episodes = Int(textField.textString) {
            episodes = max(0, episodes + shift)
            let maxEpisodes = animeCoordinator.numberOfEpisodesInSeries()
            if maxEpisodes > 0 && episodes > maxEpisodes {
                updateWatchedEpisodes(maxEpisodes)
                animeCoordinator.updateEpisodeCount(maxEpisodes)
            }
            else {
                updateWatchedEpisodes(episodes)
                animeCoordinator.updateEpisodeCount(episodes)
            }
        }
        else if shift > 0 {
            updateWatchedEpisodes(shift)
            animeCoordinator.updateEpisodeCount(shift)
        }
    }
}

extension EditableEpisodesEntryView {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let targetString: String = (textField.textString as NSString).replacingCharacters(in: range, with: string)
        
        if targetString.isEmpty {
            updateWatchedEpisodes(0)
            animeCoordinator.updateEpisodeCount(0)
            return false
        }
        else if let episodes = Int(targetString) {
            let maxEpisodes = animeCoordinator.numberOfEpisodesInSeries()
            
            if (maxEpisodes > 0 && episodes > maxEpisodes) {
                updateWatchedEpisodes(maxEpisodes)
                animeCoordinator.updateEpisodeCount(maxEpisodes)
                return false
            }
            else if episodes != 0 && targetString.starts(with: "0") {
                updateWatchedEpisodes(episodes)
                animeCoordinator.updateEpisodeCount(episodes)
                return false
            }
            
            animeCoordinator.updateEpisodeCount(episodes)
            return true
        }
        return false
    }
}
