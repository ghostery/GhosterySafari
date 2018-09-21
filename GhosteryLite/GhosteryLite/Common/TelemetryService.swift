//
//  TelemetryService.swift
//  GhosteryLite
//
//  Created by Sahakyan on 9/21/18.
//  Copyright © 2018 Ghostery. All rights reserved.
//

import Foundation
import Alamofire

class TelemetryService {

	enum SignalType {
		case install
		case uninstall
		case engage
	}

	static let shared = TelemetryService()

	func sendSignal() {
		let url = "https://staging-d.ghostery.com/install/all?gr=-1&v=1.0.0&l=en"
		Alamofire.request(url)
			.validate()
			.response(completionHandler: { (response) in
				print("\(response.error)")
				if let d = response.data {
					let str = String(data: d, encoding: .utf8)
					print(str)
				}
//				response.data
			})
//			.responseJSON { (response) in
//				guard response.result.isSuccess else {
//					completion(response.result.error, nil)
//					return
//				}
//				completion(nil, response.data)
//			}
	}
}
