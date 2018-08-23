//
//  SafariExtensionHandler.swift
//  SafariExtension
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
        }
    }

    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        NSLog("The extension's toolbar item was clicked")
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
    }

	override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
	}

	override func popoverWillShow(in window: SFSafariWindow) {
		self.updatePopoverUrl(window)
	}

	/*
	private func urlChanges(window: SFSafariWindow) {
		window.getActiveTab { (tab) in
			if let t = tab {
				self.getTabURL(t)
			} else {
				AntiTrackingManager.shared.domainChanged(nil)
			}
		}
	}
*/
	private func updatePopoverUrl(_ window: SFSafariWindow) {
		window.getActiveTab { (tab) in
			tab?.getActivePage(completionHandler: { (activePage) in
				activePage?.getPropertiesWithCompletionHandler({ (properties) in
					SafariExtensionViewController.shared.currentUrl = properties?.url?.normalizedHost
				})
			})
		}
	}

	private func reloadCurrentPage() {
		SFSafariApplication.getActiveWindow(completionHandler: { (window) in
			window?.getActiveTab(completionHandler: { (tab) in
				tab?.getActivePage(completionHandler: { (page) in
					page?.reload()
				})
			})
		})
	}
}
