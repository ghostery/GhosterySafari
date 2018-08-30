//
//  SectionListVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

protocol SectionListVCDelegate {
    func sectionListVC(_ vc: SectionListVC, didSelectSectionItem item: MenuItem)
}

class SectionListVC: NSViewController {
    
    var delegate: SectionListVCDelegate? = nil
    let items: [MenuItem] = [.home, .settings, .trustedSites, .help]
    
    @IBOutlet weak var collectionView: NSCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
             self.selectItem(atIndex: 0)
        })
    }
    
    func selectItem(menuItem item: MenuItem) {
        if let itemIndex = items.index(of: item) {
            selectItem(atIndex: itemIndex)
        }
    }
    
    private func selectItem(atIndex itemIndex: Int) {
        self.collectionView.deselectItems(at: self.collectionView.selectionIndexPaths)
        
        let indexPath = IndexPath(item: itemIndex, section: 0)
        let indexPathSet = Set<IndexPath>(arrayLiteral: indexPath)
        self.collectionView.selectItems(at: indexPathSet, scrollPosition: .top)
        self.delegate?.sectionListVC(self, didSelectSectionItem: items[itemIndex])
    }
    
}



// MARK:- Collection view data source
// MARK:-
extension SectionListVC : NSCollectionViewDataSource {
    
    // Section Header Count
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    // Section Item Count
    func collectionView(_ collectionView: NSCollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // Section Item
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let itemView = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SectionItemCollectionViewItem"), for: indexPath)
        guard let sectionItemView = itemView as? SectionItemCollectionViewItem else { return itemView }
        
        let item = self.items[indexPath.item]
        sectionItemView.update(item, for: indexPath)
        return itemView
    }
}

// MARK:- Collectin view delegate
// MARK:-
extension SectionListVC : NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView,
                        didSelectItemsAt indexPaths: Set<IndexPath>) {
        let item = self.items[indexPaths.first!.item]
        self.delegate?.sectionListVC(self, didSelectSectionItem: item)
    }
}

// MARK:- Collection view flow layout delegate
// MARK:-
extension SectionListVC : NSCollectionViewDelegateFlowLayout {
    
}
