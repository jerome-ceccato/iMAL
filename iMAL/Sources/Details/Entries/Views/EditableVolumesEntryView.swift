//
//  EditableVolumesEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 19/09/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableVolumesEntryView: EditableUserEntryView {
    
    var mangaCoordinator: MangaEditingCoordinator {
        return coordinator as! MangaEditingCoordinator
    }
    
    func updateReadVolumes(_ volumes: Int) {
        textField.text = "\(volumes)"
    }
    
    override func accessoryToolbar(with toolbar: UIToolbar) -> UIToolbar? {
        toolbar.items = [
            UIBarButtonItem(title: "- VOL", style: .plain, target: self, action: #selector(self.prevVolume)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "+ VOL", style: .plain, target: self, action: #selector(self.nextVolume))
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

extension EditableVolumesEntryView {
    @objc func nextVolume() {
        updateVolumeCount(1)
    }
    
    @objc func prevVolume() {
        updateVolumeCount(-1)
    }
    
    func updateVolumeCount(_ shift: Int) {
        if var volumes = Int(textField.textString) {
            volumes = max(0, volumes + shift)
            let maxVolumes = mangaCoordinator.numberOfVolumesInSeries()
            if maxVolumes > 0 && volumes > maxVolumes {
                updateReadVolumes(maxVolumes)
                mangaCoordinator.updateVolumeCount(maxVolumes)
            }
            else {
                updateReadVolumes(volumes)
                mangaCoordinator.updateVolumeCount(volumes)
            }
        }
        else if shift > 0 {
            updateReadVolumes(shift)
            mangaCoordinator.updateVolumeCount(shift)
        }
    }
}

extension EditableVolumesEntryView {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let targetString: String = (textField.textString as NSString).replacingCharacters(in: range, with: string)
        
        if targetString.isEmpty {
            updateReadVolumes(0)
            mangaCoordinator.updateVolumeCount(0)
            return false
        }
        else if let volumes = Int(targetString) {
            let maxVolumes = mangaCoordinator.numberOfVolumesInSeries()
            if maxVolumes > 0 && volumes > maxVolumes {
                updateReadVolumes(maxVolumes)
                mangaCoordinator.updateVolumeCount(maxVolumes)
                return false
            }
            else if volumes != 0 && targetString.starts(with: "0") {
                updateReadVolumes(volumes)
                mangaCoordinator.updateVolumeCount(volumes)
                return false
            }
            
            mangaCoordinator.updateVolumeCount(volumes)
            return true
        }
        return false
    }
}
