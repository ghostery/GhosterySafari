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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
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
}


extension MainVC : SectionListVCDelegate {
    func sectionListVC(_ vc: SectionListVC, didSelectSectionItem item: MenuItem) {
        
    }

}

extension MainVC : SectionDetailVCDelegate {
    
}
