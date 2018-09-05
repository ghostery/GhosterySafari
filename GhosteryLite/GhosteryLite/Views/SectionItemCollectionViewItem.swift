//
//  SectionItemCollectionViewItem.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class SectionItemCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var imgIcon: NSImageView!
    @IBOutlet weak var sideNavImgIcon: NSImageView!
    private var item: MenuItem? = nil
    private var indexPath: IndexPath!
    
    override var isSelected: Bool {
        didSet {
            // set text color
            lblTitle.textColor = isSelected ? NSColor.white : NSColor(rgb: 0xa9b9be)
            
            if let item = self.item {
                self.imgIcon.image = NSImage(named: NSImage.Name(rawValue: item.iconName(active: isSelected)))
            }
            
            // set title text & underline style
            let text = NSMutableAttributedString(string: lblTitle.stringValue)
            if isSelected {
                let attrs = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
                text.addAttributes(attrs, range: NSRange(location: 0, length: text.length))
            }
            self.lblTitle.attributedStringValue = text
            self.sideNavImgIcon.isHidden = !isSelected
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
    }
    
    func update(_ item: MenuItem, for indexPath: IndexPath?) {
        self.item = item
        self.indexPath = indexPath
        self.lblTitle.stringValue = item.title
        self.imgIcon.image = NSImage(named: NSImage.Name(rawValue: item.iconName(active: false)))
    }
    
}
