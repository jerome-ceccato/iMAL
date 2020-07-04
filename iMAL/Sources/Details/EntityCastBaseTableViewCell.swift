//
//  EntityCastBaseTableViewCell.swift
//  iMAL
//
//  Created by Jérôme Ceccato on 04/02/2017.
//  Copyright © 2017 IATGOF. All rights reserved.
//

import UIKit

class EntityCastBaseTableViewCell: SelectableTableViewCell {
    enum Position {
        case left
        case right
    }
    
    @IBOutlet var leftImageView: UIImageView?
    @IBOutlet var leftMainLabel: UILabel!
    @IBOutlet var leftSubtitleLabel: UILabel!
    
    @IBOutlet var rightImageView: UIImageView?
    @IBOutlet var rightMainLabel: UILabel!
    @IBOutlet var rightSubtitleLabel: UILabel!
    
    @IBOutlet var separatorView: UIView?
    
    var action: ((Position) -> Void)?
    
    private var tapRecognizer: UIGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [leftImageView, rightImageView].compactMap({ $0 }).forEach { imageView in
            imageView.layer.cornerRadius = 3
            imageView.layer.masksToBounds = true
        }
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(_:)))
        addGestureRecognizer(tapRecognizer!)
        
        applyTheme { [unowned self] theme in
            [self.leftMainLabel, self.rightMainLabel].forEach { mainLabel in
                mainLabel?.textColor = theme.genericView.importantText.color
            }
            [self.leftSubtitleLabel, self.rightSubtitleLabel].forEach { subtitleLabel in
                subtitleLabel?.textColor = theme.genericView.subtitleText.color
            }
            [self.leftImageView, self.rightImageView].forEach { imageView in
                imageView?.backgroundColor = theme.entity.pictureBackground.color
            }
            
            self.separatorView?.backgroundColor = theme.separators.heavy.color
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        action = nil
    }
    
    private func imageView(at position: Position) -> UIImageView? {
        switch position {
        case .left:
            return leftImageView
        case .right:
            return rightImageView
        }
    }
    
    private func mainLabel(at position: Position) -> UILabel? {
        switch position {
        case .left:
            return leftMainLabel
        case .right:
            return rightMainLabel
        }
    }
    
    private func subtitleLabel(at position: Position) -> UILabel? {
        switch position {
        case .left:
            return leftSubtitleLabel
        case .right:
            return rightSubtitleLabel
        }
    }
    
    func fillContent(imageURL: String, main: String, subtitle: String?, position: Position) {
        imageView(at: position)?.image = nil
        imageView(at: position)?.setImageWithURLString(imageURL)
        
        mainLabel(at: position)?.text = main
        subtitleLabel(at: position)?.text = subtitle
    }
    
    @objc func didTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let touchPoint = gestureRecognizer.location(in: self)
            let position: Position = touchPoint.x > (frame.width / 2) ? .right : .left
            action?(position)
        }
    }
}
