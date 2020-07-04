//
//  AnimeSchedule.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 23/03/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import Foundation
import SwiftyJSON

class AnimeSchedule {
    class Section {
        var name: String
        var items: [Anime]
        var metadata: Metadata
        
        init(name: String = "", items: [Anime] = [], thisWeek: Bool = false) {
            self.name = name
            self.items = items
            self.metadata = Metadata(thisWeek: thisWeek)
        }
        
        init(json: JSON, sectionName: String) {
            metadata = Metadata()
            
            name = sectionName
            items = json.arrayValue.map { Anime(json: $0) }
        }
        
        struct Metadata {
            var expanded: Bool = true
            var thisWeek: Bool = false
            
            init(expanded: Bool = true, thisWeek: Bool = false) {
                self.expanded = expanded
                self.thisWeek = thisWeek
            }
        }
    }
    
    var sections: [Section] = []
    
    init() {}
    init(json: JSON) {
        let sectionData: [(identifier: String, name: String)] = [
            ("monday", "Monday"),
            ("tuesday", "Tuesday"),
            ("wednesday", "Wednesday"),
            ("thursday", "Thursday"),
            ("friday", "Friday"),
            ("saturday", "Saturday"),
            ("sunday", "Sunday"),
            ("other", "Other"),
            ("unknown", "Unknown")
        ]
        
        sectionData.forEach { item in
            sections.append(Section(json: json[item.identifier], sectionName: item.name))
        }
    }
}
