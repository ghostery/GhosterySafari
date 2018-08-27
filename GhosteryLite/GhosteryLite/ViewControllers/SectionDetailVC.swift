//
//  SectionDetailVC.swift
//  GhosteryLite
//
//  Created by Mahmoud Adam on 8/27/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Cocoa

protocol SectionDetailVCDelegate {

}

class SectionDetailVC: NSViewController {
    
    var delegate: SectionDetailVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
