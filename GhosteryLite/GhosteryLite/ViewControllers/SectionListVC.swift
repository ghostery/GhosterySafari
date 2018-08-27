//
//  SectionListVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

public enum MenuItem {
    case home
    case settings
    case trustedSites
    case help
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .settings:
            return "Settings"
        case .trustedSites:
            return "Trusted Sites"
        case .help:
            return "Help"
        }
    }
    
    func iconName(active: Bool) -> String {
        var iconName = ""
        switch self {
        case .home:
            iconName += "home"
        case .settings:
            iconName += "settings"
        case .trustedSites:
            iconName += "trusted"
        case .help:
            iconName += "help"
        }
        
        if active {
          return "\(iconName)-active"
        }
        return "\(iconName)-inactive"
    }
}

protocol SectionListVCDelegate {
    func sectionListVC(_ vc: SectionListVC, didSelectSectionItem item: MenuItem)
}

class SectionListVC: NSViewController {
    
    var delegate: SectionListVCDelegate? = nil
    let items: [MenuItem] = [.home, .settings, .trustedSites, .help]
    
    @IBOutlet weak var collectionView: NSCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        selectItem(atIndex: 0)
    }
    
    private func selectItem(atIndex itemIndex: Int) {
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
//        guard let item = self.sections?[indexPaths.first!.section].items?[indexPaths.first!.item] else { return }
//        self.delegate?.sectionListVC(self, didSelectSectionItem: item)
    }
}

// MARK:- Collection view flow layout delegate
// MARK:-
extension SectionListVC : NSCollectionViewDelegateFlowLayout {
    
}
