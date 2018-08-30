//
//  SectionDetailVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

protocol SectionDetailVCDelegate {
    
    func showSettingsPanel()
    func showTrustedSitesPanel()
}

class SectionDetailVC: NSViewController {
    
    @IBOutlet weak var container: NSView!
    
    var delegate: SectionDetailVCDelegate?
    var viewControllers = [String: NSViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        initViewControllers()
    }
    
    func switchToViewController(withStoryboardId storyboardId: String) {
        if let viewController = viewControllers[storyboardId] {
            removePreviousView()
            container.addSubview(viewController.view)
        }
    }
    
    private func initViewControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        
        for menuItem in MenuItem.toArray() {
            let storyboardId = menuItem.storyboardId
            let identifier = NSStoryboard.SceneIdentifier(rawValue: storyboardId)
            if let viewController = storyboard.instantiateController(withIdentifier: identifier) as? NSViewController {
                viewControllers[storyboardId] = viewController
                
                if let homeVC = viewController as? HomeVC {
                    homeVC.delegate = self.delegate
                }
            }
        }
    }
    
    private func removePreviousView() {
        if let oldView: NSView = container.subviews.first {
            oldView.removeFromSuperview()
        } else {
            print("No previous view found")
        }
    }
}


