//
//  TrustedSiteCollectionViewItem.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/30/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class TrustedSiteCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var siteLbl: NSTextField!
    
    private var indexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
    }
    
    func update(_ url: String, for indexPath: IndexPath?) {
        self.siteLbl.stringValue = url
        self.indexPath = indexPath
    }
}
