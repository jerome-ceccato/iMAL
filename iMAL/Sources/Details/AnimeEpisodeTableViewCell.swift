//
//  AnimeEpisodeTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 29/01/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class AnimeEpisodeTableViewCell: SelectableTableViewCell {
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var alternativeTitlesLabel: UILabel!
    @IBOutlet var airedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyTheme { [unowned self] theme in
            [self.titleLabel, self.numberLabel, self.airedLabel].forEach { mainLabel in
                mainLabel!.textColor = theme.genericView.importantText.color
            }
            self.alternativeTitlesLabel.textColor = theme.genericView.labelText.color
        }
    }
    
    func fill(with episode: Episode) {
        numberLabel.text = "\(episode.number)"
        titleLabel.text = episode.title
        alternativeTitlesLabel.text = episode.alternativeTitlesDisplayString
        airedLabel.text = episode.airedDate?.shortDateDisplayString
    }
}
