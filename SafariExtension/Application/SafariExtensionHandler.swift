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

/// A base class to handle events in the Safari app extension.
class SafariExtensionHandler: SFSafariExtensionHandler {
	/// Called when a toolbar item associated with the app extension is clicked.
	/// - Parameter window: The window containing the clicked toolbar item
	override func toolbarItemClicked(in window: SFSafariWindow) {
		Telemetry.shared.sendSignal(.engaged, source: TelemetryService.PingSource.safariExtension)
		GhosteryApplication.shared.checkForUpdatedBlockLists()
	}
	
	/// Called in response to a requested update or a browser state change that may affect the toolbar item.
	/// - Parameters:
	///   - window: The window containing the clicked toolbar item
	///   - validationHandler: A code block used to set the state of the toolbar item
	override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
		Telemetry.shared.sendSignal(.active, source: TelemetryService.PingSource.safariExtension)
		validationHandler(true, "")
	}
	
	/// Tells the handler that the app extension's popover is about to be opened.
	/// - Parameter window: The window to display the popover in
	override func popoverWillShow(in window: SFSafariWindow) {
		self.updatePopoverUrl(window)
	}
	
	/// Asks the handler to provide a popover view controller for display.
	override func popoverViewController() -> SFSafariExtensionViewController {
		return SafariExtensionViewController.shared
	}
	
	/// Called when a message is received from an injected script. This method will be called when a
	/// content script provided by your extension calls safari.extension.dispatchMessage("message").
	/// - Parameters:
	///   - messageName: A string that identifies the message
	///   - page: The page that sent the message
	///   - userInfo: Optional message content
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
	
	/// Called when the Content Blocker matches a URL on a given page
	override func contentBlocker(withIdentifier contentBlockerIdentifier: String, blockedResourcesWith urls: [URL], on page: SFSafariPage) {
		// TODO: Implement this in a future version
		//	for u in urls {
		//		Utils.logger("Pattern matched \(u.absoluteString)")
		//	}
	}
	
	/// Called when page navigation has been triggered
	override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
		// TODO: Implement this in a future version
		// Utils.logger("Navigating to \(url?.absoluteString ?? "")")
	}
	
	/// Update the current webpage URL shown in the extension popover
	/// - Parameter window: The current active window
	private func updatePopoverUrl(_ window: SFSafariWindow) {
		self.handleTabUrlChange(window) { (url) in
			SafariExtensionViewController.shared.currentUrl = url?.fullPath ?? ""
			SafariExtensionViewController.shared.currentDomain = url?.normalizedHost ?? ""
		}
	}
	
	/// Get page properties for the for the active webpage
	/// - Parameters:
	///   - window: The current active window
	///   - handler: Callback handler
	private func handleTabUrlChange(_ window: SFSafariWindow, handler: @escaping((URL?) -> Void)) {
		window.getActiveTab { (tab) in
			tab?.getActivePage(completionHandler: { (activePage) in
				activePage?.getPropertiesWithCompletionHandler({ (properties) in
					handler(properties?.url)
				})
			})
		}
	}
	
	/// Reload the current webpage (not in use)
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
