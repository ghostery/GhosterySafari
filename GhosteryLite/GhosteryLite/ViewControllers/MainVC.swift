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
    @IBOutlet weak var overlayView: NSBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Preferences.isAppFirstLaunch() {
            showSafariExtensionPopOver()
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "SectionListVC" {
            self.sectionListVC = segue.destinationController as? SectionListVC
            self.sectionListVC?.delegate = self
        } else if segue.identifier?.rawValue == "SectionDetailVC" {
            self.sectionDetailVC = segue.destinationController as? SectionDetailVC
            self.sectionListVC?.delegate = self
        }
    }
    
    private func showSafariExtensionPopOver() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "SafariExtensionPromptVC")
        if let viewController = storyboard.instantiateController(withIdentifier: identifier) as? NSViewController {
            overlayView.addSubview(viewController.view)
            overlayView.isHidden = false
        }
    }
}

extension MainVC : SectionListVCDelegate {
    func sectionListVC(_ vc: SectionListVC, didSelectSectionItem item: MenuItem) {
        sectionDetailVC?.switchToViewController(withStoryboardId: item.storyboardId)
    }
}

extension MainVC : SectionDetailVCDelegate {
    
}
