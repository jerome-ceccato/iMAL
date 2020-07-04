//
//  EditableTagsEntryView.swift
//  iMAL
//
//  Created by Jerome Ceccato on 29/08/16.
//  Copyright © 2016 IATGOF. All rights reserved.
//

import UIKit

class EditableTagsEntryView: EditableUserEntryView {
    @IBOutlet var overlayButton: UIButton!
    
    @IBAction func editPressed() {
        if let controller = UIStoryboard(name: "EntityDetailsShared", bundle: nil).instantiateViewController(withIdentifier: "TagEditViewController") as? TagEditViewController {
            controller.coordinator = coordinator
            coordinator.delegate?.presentEditController(controller: controller)
        }
    }
}

