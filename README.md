[![Ghostery](https://www.ghostery.com/wp-content/themes/ghostery/images/ghostery_logo_black.svg)](https://www.ghostery.com)
---

The Ghostery Lite app extension for the Safari desktop browser works alongside Apple’s new privacy ecosystem to bring Safari users comprehensive privacy protection. Check page performance, pause Ghostery Lite, trust a site and switch to your custom settings with a single click.

This project consists of the following components:

+ GhosteryLite: Native macOS container application that manages user settings and controls the Safari extensions
+ SafariExtension: Toolbar extension in Safari
+ ContentBlocker:  Content Blocker extension in Safari with Ghostery Privacy filters
+ ContentBlockerCosmetic:  Content Blocker extension in Safari with Cosmetic ad-blocking filters
+ ContentBlockerNetwork:  Content Blocker extension in Safari with network ad-blocking filters

See [here](https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionOverview.html#//apple_ref/doc/uid/TP40014214-CH2-SW2) for more information on Safari App Extensions.

## Production Download
**App Store** &ndash; [Download](https://itunes.apple.com/us/app/ghostery-lite/id1436953057?utm_source=github.com)

## Development

+ Open `GhosteryLite.xcodeproj` in Xcode.

## Building

+ Run 'GhosteryLite' from XCode

### Clean Install

In Xcode, use `CMD + SHFT + K` to execute 'Clean Build Folder'. Then run:  

```sh
# Clean Ghostery Lite from ~/Library
$ make clean
```

## Internationalization

This project is configured to use the Transifex CLI. See their [documentation](https://docs.transifex.com/client/installing-the-client) to get started. *Note*:  You do not need to run `tx config` as the project [configuration file](.tx/config) has already been generated.

Generate a Transifex API Token [link](https://www.transifex.com/user/settings/api/)

```sh
# Configure the Transifex CLI
$ tx init
```

```sh
# Submit translation files to Transifex
$ tx push -s
```

```sh
# Download translated files from Transifex
$ tx pull -a
```

## Compatibility

+ Safari: 12+
+ MacOS Sierra 10.12+

## Links
+ [Website](https://ghostery.com/)
+ [Support](https://www.ghostery.com/support/)
+ [Twitter (@ghostery)](https://twitter.com/ghostery)
+ [Facebook](https://www.facebook.com/ghostery)
+ [Privacy Policy](https://www.ghostery.com/about-ghostery/browser-extension-privacy-policy/)

## License
[MPL-2.0](https://www.mozilla.org/en-US/MPL/2.0/) Copyright 2019 Ghostery, Inc. All rights reserved.

See [LICENSE](LICENSE)

## Tracker Databases
The [BlockListAssets](https://github.com/ghostery/GhosterySafari/tree/master/GhosteryLite/Resources/BlockListAssets) folder contains JSON skeletons to show the schema expected by the content blocker. Ghostery's production tracker databases have been purposely excluded from this project, as they remain proprietary to Ghostery, Inc.

**Copyright Notice**

The proprietary databases are the intellectual property of Ghostery, Inc. and are protected by copyright and other applicable laws. All rights to them are expressly reserved by Ghostery, Inc. You may not use these databases or any portion thereof for any purpose that is not expressly granted in writing by Ghostery, Inc. All inquires should be sent to [legal@ghostery.com](legal@ghostery.com).  Ghostery, Inc. retains the sole discretion in determining whether or not to grant permission to use the databases. Unauthorized use of the databases, or any portion of them, will cause irreparable harm to Ghostery, Inc. and may result in legal proceedings against you, seeking monetary damages and an injunction against you, including the payment of legal fees and costs.
