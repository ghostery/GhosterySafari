//
//  MainVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

class MainVC: NSViewController {
    fileprivate var sectionListVC: SectionListVC? = nil
    fileprivate var sectionDetailVC: SectionDetailVC? = nil
    fileprivate var safariExtensionPromptVC: SafariExtensionPromptVC? = nil
    @IBOutlet weak var overlayView: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Preferences.isAppFirstLaunch() {
            overlayView.isHidden = false
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "SectionListVC" {
            self.sectionListVC = segue.destinationController as? SectionListVC
            self.sectionListVC?.delegate = self
        } else if segue.identifier?.rawValue == "SectionDetailVC" {
            self.sectionDetailVC = segue.destinationController as? SectionDetailVC
            self.sectionDetailVC?.delegate = self
        } else if segue.identifier?.rawValue == "SafariExtensionPromptVC" {
            self.safariExtensionPromptVC = segue.destinationController as? SafariExtensionPromptVC
            self.safariExtensionPromptVC?.delegate = self
        }
    }
    
}

extension MainVC : SectionListVCDelegate {
    func sectionListVC(_ vc: SectionListVC, didSelectSectionItem item: MenuItem) {
        sectionDetailVC?.switchToViewController(withStoryboardId: item.storyboardId)
    }
}

extension MainVC : SectionDetailVCDelegate {
    func showSettingsPanel() {
        self.sectionListVC?.selectItem(menuItem: .settings)
//        self.switchToViewController(withStoryboardId: MenuItem.settings.storyboardId)
    }
    
    func showTrustedSitesPanel() {
        self.sectionListVC?.selectItem(menuItem: .trustedSites)
//        self.switchToViewController(withStoryboardId: MenuItem.trustedSites.storyboardId)
    }
}

extension MainVC : SafariExtensionPromptVCDelegate {
    func hideSafariExtensionPopOver() {
        overlayView.isHidden = true
    }
}
