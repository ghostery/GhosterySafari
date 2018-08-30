//
//  SafariExtensionViewController.swift
//  SafariExtension
//
//  Created by Sahakyan on 8/6/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import SafariServices

class SafariExtensionViewController: SFSafariExtensionViewController {
    
    static let shared = SafariExtensionViewController()

	@IBOutlet var urlLabel: NSTextField!
	@IBOutlet var pageLatencyLabel: NSTextField!
	@IBOutlet var pageLatencyImage: NSImageView!

	var currentDomain: String? {
		didSet {
			urlLabel?.stringValue = currentDomain ?? ""
		}
	}

	var currentUrl: String? {
		didSet {
			pageLatencyLabel?.stringValue = PageLatencyDataSource.shared.latencyFor(currentUrl ?? "")
			pageLatencyImage?.image = NSImage(named: NSImage.Name(PageLatencyDataSource.shared.latencyImageName(currentUrl ?? "")))
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.preferredContentSize = NSMakeSize(186, 273)
		self.view.layer?.backgroundColor = NSColor.white.cgColor
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		self.view.layer?.backgroundColor = NSColor.white.cgColor

		urlLabel?.stringValue = self.currentDomain ?? ""
	}

	@IBAction func pauseButtonPressed(sender: NSButton) {
		if sender.isEnabled {
			AntiTrackingManager.shared.pause()
		} else {
			AntiTrackingManager.shared.resume()
		}
	}

	@IBAction func trustButtonPressed(sender: NSButton) {
		AntiTrackingManager.shared.trustDomain(domain: self.currentDomain ?? "")
	}

	@IBAction func threedotsButtonPressed(sender: NSButton) {
		openSettings()
	}

	func updatePageLatency(_ url: String, _ latency: String) {
		self.currentUrl = url
//		pageLatencyLabel?.stringValue = latency
//		pageLatencyImage?.image = NSImage(byReferencingFile: PageLatencyDataSource.shared.latencyImageName(url))
	}

	private func openSettings() {
		
	}
}
