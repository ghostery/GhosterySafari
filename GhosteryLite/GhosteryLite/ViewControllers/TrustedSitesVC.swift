//
//  TrustedSitesVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/30/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class TrustedSitesVC: NSViewController {

    @IBOutlet weak var trustedSitesText: NSTextField!
    @IBOutlet weak var trustedSiteTextField: NSTextField!
    @IBOutlet weak var trustSiteBtn: NSButton!
    @IBOutlet weak var trustedStiesCollectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trustedSitesText.stringValue = Strings.TrustedSitesPanelText
        
        trustSiteBtn.attributedTitle = Strings.TrustedSitesPanelTrustSiteButtonTitle.attributedString(withTextAlignment: .center,
                                                                                                      fontName: "Roboto-Medium",
                                                                                                      fontSize: 12.0,
                                                                                                      fontColor: 0x9b9b9b)
    }
    
}

// MARK:- Collection view data source
// MARK:-
extension TrustedSitesVC : NSCollectionViewDataSource {
    
    // Section Header Count
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    // Section Item Count
    func collectionView(_ collectionView: NSCollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        //TODO: get the data from the datasource
        return 1
    }
    
    // Section Item
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let trustedSiteCollectionView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TrustedSiteCollectionViewItem"), for: indexPath)
        guard let trustedSiteView = trustedSiteCollectionView as? TrustedSiteCollectionViewItem else { return trustedSiteCollectionView }
        
        //TODOL update the cell with the actual data
        trustedSiteView.update("www.cnn.com", for: indexPath)
        return trustedSiteView
    }
}

// MARK:- Collectin view delegate
// MARK:-
extension TrustedSitesVC : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView,
                        didSelectItemsAt indexPaths: Set<IndexPath>) {
        
    }
}
