#
# Makefile
# Used by Xcode build schemes:
# Pre-Action: `make --directory ${PROJECT_DIR} clean bugs`
# Post-Action: `make --directory ${PROJECT_DIR} restore`
#
# Ghostery Lite for Safari
# https://www.ghostery.com/
#
# Copyright 2019 Ghostery, Inc. All rights reserved.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0

DB_DIR := GhosteryLite/Resources/BlockListAssets

clean:
	@echo "Cleaning up..."
	rm -rf ~/Library/Application\ Scripts/com.ghostery.lite/
	rm -rf ~/Library/Application\ Scripts/com.ghostery.lite.contentBlocker/
	rm -rf ~/Library/Application\ Scripts/com.ghostery.lite.contentBlockerCosmetic/
	rm -rf ~/Library/Application\ Scripts/com.ghostery.lite.contentBlockerNetwork/
	rm -rf ~/Library/Application\ Scripts/com.ghostery.lite.safariExtension/
	rm -rf ~/Library/Containers/com.ghostery.lite/
	rm -rf ~/Library/Containers/com.ghostery.lite.contentBlocker/
	rm -rf ~/Library/Containers/com.ghostery.lite.contentBlockerCosmetic/
	rm -rf ~/Library/Containers/com.ghostery.lite.contentBlockerNetwork/
	rm -rf ~/Library/Containers/com.ghostery.lite.safariExtension/
	rm -rf ~/Library/Group\ Containers/HPY23A294X.ghostery.lite/

bugs:
	@echo "Fetching Safari block list json files..."
	curl "https://cdn.ghostery.com/update/v4/safari/safariContentBlocker.json" -o $(DB_DIR)/safariContentBlocker.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_advertising.json" -o $(DB_DIR)/cat_advertising.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_audio_video_player.json" -o $(DB_DIR)/cat_audio_video_player.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_comments.json" -o $(DB_DIR)/cat_comments.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_customer_interaction.json" -o $(DB_DIR)/cat_customer_interaction.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_essential.json" -o $(DB_DIR)/cat_essential.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_pornvertising.json" -o $(DB_DIR)/cat_pornvertising.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_site_analytics.json" -o $(DB_DIR)/cat_site_analytics.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/safari/cat_social_media.json" -o $(DB_DIR)/cat_social_media.json --compressed --fail
	curl "https://cdn.ghostery.com/update/v4/versions.json" -o $(DB_DIR)/version.json --compressed --fail

restore:
	@echo "Restore default block list files..."
	git checkout -- ${DB_DIR}

incrementBuildNumber:
	@echo "Bumping project build number..."
	xcrun agvtool next-version

.PHONY: clean
