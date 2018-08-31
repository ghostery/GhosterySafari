//
//  TrustedSiteCollectionViewItem.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/30/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

protocol TrustedSiteDelegate: class {
	func trustedSiteDidRemove(indexPath: IndexPath, url: String)
}

class TrustedSiteCollectionViewItem: NSCollectionViewItem {

	weak var delegate: TrustedSiteDelegate?

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

	@IBAction func removeTrustedSite(_ sender: Any) {
		self.delegate?.trustedSiteDidRemove(indexPath: self.indexPath, url: self.siteLbl.stringValue)
	}
}
