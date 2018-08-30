//
//  MenuItem.swift
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
            return Strings.SideMenuHomeTitle
        case .settings:
            return Strings.SideMenuSettingsTitle
        case .trustedSites:
            return Strings.SideMenuTrustedSitesTitle
        case .help:
            return Strings.SideMenuHelpTitle
        }
    }
    
    var storyboardId: String {
        switch self {
        case .home:
            return "HomeVC"
        case .settings:
            return "SettingsVC"
        case .trustedSites:
            return "TrustedSitesVC"
        case .help:
            return "HelpVC"
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
    
    static func toArray() -> [MenuItem] {
        return [.home, .settings, .trustedSites, .help]
    }
}
