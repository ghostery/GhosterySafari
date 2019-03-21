[![Ghostery](https://www.ghostery.com/wp-content/themes/ghostery/images/ghostery_logo_black.svg)](https://www.ghostery.com)
---

The Ghostery Lite app extension for the Safari desktop browser works alongside Apple’s new privacy ecosystem to bring Safari users comprehensive privacy protection. Check page performance, pause Ghostery Lite, trust a site and switch to your custom settings with a single click.

This project consists of three main components:

+ GhosteryLite: Native macOS container application that manages user settings and controls the Safari extensions
+ SafariExtension: UI Toolbar extension in Safari
+ ContentBlocker:  Content blocking extension in Safari

See [here](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionOverview.html#//apple_ref/doc/uid/TP40014214-CH2-SW2) for more information on Safari App Extensions.

## Production Download
**App Store** &ndash; [Download](https://itunes.apple.com/us/app/ghostery-lite/id1436953057?utm_source=github.com)

## Installation

```sh
# Install CocoaPods
$ sudo gem install cocoapods
```

```sh
# Install Dependencies
$ pod install
```

## Building

+ Run 'GhosteryLite' from XCode

## Compatibility

+ Safari: 12+

## Links
+ [Website](https://ghostery.com/)
+ [Support](https://ghostery.zendesk.com/)
+ [Twitter (@ghostery)](https://twitter.com/ghostery)
+ [Facebook](https://www.facebook.com/ghostery)
+ [Privacy Policy](https://www.ghostery.com/about-ghostery/browser-extension-privacy-policy/)

## License
[MPL-2.0](https://www.mozilla.org/en-US/MPL/2.0/) Copyright 2019 Ghostery, Inc. All rights reserved.

See [LICENSE](LICENSE)

## Tracker Databases
The [databases](/⁨GhosteryLite⁩/TrackerBlocking⁩/BlockListAssets⁩) folder contains JSON skeletons to show the schema expected by the content blocker. Ghostery's production tracker databases have been purposely excluded from this project, as they remain proprietary to Ghostery, Inc.

**Copyright Notice**

The proprietary databases are the intellectual property of Ghostery, Inc. and are protected by copyright and other applicable laws. All rights to them are expressly reserved by Ghostery, Inc. You may not use these databases or any portion thereof for any purpose that is not expressly granted in writing by Ghostery, Inc. All inquires should be sent to [legal@ghostery.com](legal@ghostery.com).  Ghostery, Inc. retains the sole discretion in determining whether or not to grant permission to use the databases. Unauthorized use of the databases, or any portion of them, will cause irreparable harm to Ghostery, Inc. and may result in legal proceedings against you, seeking monetary damages and an injunction against you, including the payment of legal fees and costs.
