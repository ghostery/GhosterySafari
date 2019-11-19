//
// SafariExtensionHandler
// SafariExtension
//
// Ghostery Lite for Safari
// https://www.ghostery.com/
//
// Copyright 2019 Ghostery, Inc. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
	/// This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
	override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
		if messageName == "recordPageInfo" {
			page.getPropertiesWithCompletionHandler { (properties) in
				if let ui = userInfo,
					let latency = ui["latency"] as? String,
					let url = ui["domain"] as? String,
					url == properties?.url?.fullPath {
					PageLatency.shared.pageLoaded(url: url, latency: latency)
					SafariExtensionViewController.shared.updatePageLatency(url, latency)
				}
			}
		}
	}

	/// This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
	override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
		TelemetryManager.shared.sendSignal(.active, ghostrank: 2)
		handleTabUrlChange(window) { (url) in
			Preferences.setGlobalPreference(key: "newDomain", value: url?.normalizedHost ?? "")
		}
		validationHandler(true, "")
	}
	
	/// Called when the Content Blocker matches a URL on a given page
	override func contentBlocker(withIdentifier contentBlockerIdentifier: String, blockedResourcesWith urls: [URL], on page: SFSafariPage) {
		// TODO: Implement this in a future version
		//	for u in urls {
		//		print("pattern matched \(u.absoluteString)")
		//	}
	}
	
	/// Called when page navigation has been triggered
	override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
		// TODO: Implement this in a future version
		// print("navigating to \(url?.absoluteString ?? "")")
	}

	override func popoverViewController() -> SFSafariExtensionViewController {
		return SafariExtensionViewController.shared
	}

	override func popoverWillShow(in window: SFSafariWindow) {
		self.updatePopoverUrl(window)
	}

	private func updatePopoverUrl(_ window: SFSafariWindow) {
		handleTabUrlChange(window) { (url) in
			SafariExtensionViewController.shared.currentUrl = url?.fullPath ?? ""
			SafariExtensionViewController.shared.currentDomain = url?.normalizedHost ?? ""
		}
	}

	private func handleTabUrlChange(_ window: SFSafariWindow, handler: @escaping((URL?) -> Void)) {
		window.getActiveTab { (tab) in
			tab?.getActivePage(completionHandler: { (activePage) in
				activePage?.getPropertiesWithCompletionHandler({ (properties) in
					handler(properties?.url)
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
