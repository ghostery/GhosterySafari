//
// CategoryType
// GhosteryLite
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

import Foundation

enum CategoryType: Int {
	case advertising
	case audioVideoPlayer
	case comments
	case customerInteraction
	case essential
	case pornvertising
	case siteAnalytics
	case socialMedia
	case uncategorized
	
	static func allCategoriesCount() -> Int {
		return 8
	}
	
	func fileName() -> String {
		switch self {
			case .advertising:
				return "cat_advertising"
			case .audioVideoPlayer:
				return "cat_audio_video_player"
			case .comments:
				return "cat_comments"
			case .customerInteraction:
				return "cat_customer_interaction"
			case .essential:
				return "cat_essential"
			case .pornvertising:
				return "cat_pornvertising"
			case .siteAnalytics:
				return "cat_site_analytics"
			case .socialMedia:
				return "cat_social_media"
			case .uncategorized:
				return "cat_unclassifed"
		}
	}
	
	static func allCases() -> [CategoryType] {
		return [.advertising, .audioVideoPlayer, .comments, .customerInteraction, .essential, .pornvertising, .siteAnalytics, .socialMedia, .uncategorized]
	}
}
