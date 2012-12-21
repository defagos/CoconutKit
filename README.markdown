### What is CoconutKit?

CoconutKit is a library of high-quality iOS components written at [hortis le studio](http://www.hortis.ch/) and in my spare time. It includes several tools for dealing with view controllers, multi-threading, animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.

Most of CoconutKit components are not sexy as is, but rather useful. Do not be freaked out! These components are meant to make you more productive, less focused on debugging, so that you can spend more time working on the design of your application (if you have a great designer at hand, of course). Give CoconutKit a try, your life as an iOS programmer will never be the same afterwards!

CoconutKit is distributed under a permissive [MIT license](http://www.opensource.org/licenses/mit-license.php), which means you can freely use it in your own projects (commercial or not).

### What can I find in CoconutKit?

CoconutKit provides your with several kinds of classes covering various aspects of iOS development:

* High-quality view controller containers. These containers are the result of two years of hard work, and exceed by far the capabilities of UIKit built-in containers. In particular, view controllers can be combined or stacked, using any kind of transition animation (even yours). Your applications will never look the same as before!
* View controller containment API (compatible with iOS 4), richer, easier to use and far more powerful than the iOS 5 UIKit containment API. Writing your own view controller containers correctly has never been easier!
* Easy way to change the language used by an application at runtime, without having to alter system preferences
* Localization of labels and buttons directly in nib files, without having to create and bind outlets anymore
* Classes for creating animations made of several UIView block-based or Core Animation-based sub-animations in a declarative way. Such animations can be paused, reversed, played instantaneously, cancelled, repeated, and even more! Animations have never been so fun and easy to create!
* Core Data model management and validation made easy. The usual boilerplate Core Data code has been completely eliminated. Interactions with managed contexts have been made simple by introducing context-free methods acting on a context stack. Core Data validation boilerplate code is never required anymore, and text field bindings make form creation painless
* View controllers for web browsing and easier table view search management
* Multi-threaded task management, including task grouping, cancelation, progress status, task dependencies and remaining time estimation
* New controls
	* text field moving automatically with the keyboard
	* cursor
	* slideshow with several transition animations (cross fade, Ken Burns, etc.)
	* label with vertical alignment
	* expanding / collapsing search bar
* Classes for common UI tasks (keyboard management, interface locking)
* Classes for single-line table view cell and view instantiations
* Methods for skinning some built-in controls prior to iOS 5 appearance API
* Lightweight logger, assertions, float comparisons, etc.
* Various extensions to Cocoa and UIKit classes (calendrical calculations, collections, notifications, etc.)
* ... and more!
* ... and even more to come!

### Where can I download CoconutKit?

You can download CoconutKit from [the official github page](https://github.com/defagos/CoconutKit), both in binary and source forms. [A companion repository](https://github.com/defagos/CoconutKit-CocoaPods) exists for easy installation using CocoaPods, but you do not need to check it out directly.

You can also directly checkout the git repository. Note that there are submodules you must update using the `git submodules update --init` command.

### Supporting development

CoconutKit is and will stay free. However, if you enjoy using it, you can support the countless hours of work that are invested into its creation. Thank you in advance! 

[![Donate to author](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=3V35ZXWYXGAYG&lc=CH&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted)

### Credits

If you enjoy the library, [hortis](http://www.hortis.ch/) and I would sincerely love being credited somewhere in your application, for example on some about page. Thanks for your support!

### How can I discover CoconutKit components?

Check out the CoconutKit source code repository by visiting [the official project github page](https://github.com/defagos/CoconutKit), open the workspace and either run the `CoconutKit-demo` or the `CoconutKit-dev` targets. The result of running those targets is the same, the only difference is that `CoconutKit-demo` compiles and builds the CoconutKit library source code before using the resulting binaries, whereas `CoconutKit-dev` includes and compiles all libary sources as part of the project itself.

### Why should I use CoconutKit?

When designing components, I strongly emphasize on clean and documented interfaces, as well as on code quality. My goal is to create components that are easy to use, reliable, and which do what they claim they do, without nasty surprises. You should never have to look at a component implementation to know how it works, this should be obvious just by looking at its interface. I also strive to avoid components that leak or crash. If those are qualities you love to find in libraries, then you should start using CoconutKit now!

### How should I add CoconutKit to my project?

You can add CoconutKit to your project in several different ways:

#### Adding binaries manually

You can grab the latest tagged binary package available from [the project download page](https://github.com/defagos/CoconutKit/downloads). Add the `.staticframework` directory to your project (the _Create groups for any added folders_ option must be checked) and link your project against the following system frameworks:

* `CoreData.framework`
* `MessageUI.framework`
* `QuartzCore.framework`

If your project targets iOS 4 as well as iOS 5 and above, you might encounter _symbol not found_ issues at runtime. When this happens:

* If the symbol belongs to UIKit, then weakly link your target with `UIKit.framework` (click on your target, select _Build Phases_, and under _Link Binary With Libraries_ set `UIKit.framework` as optional)
* If the symbol begins with `_objc`, then link your target with the ARC Lite libraries by adding the `-fobjc-arc` flag to your target `Other Linker Flags` settting

#### Adding source files using CocoaPods

Since CoconutKit 2.0, the easiest way to add CoconutKit to a project is using [CocoaPods](https://github.com/CocoaPods/CocoaPods). The CoconutKit specification file should be available from the official CocoaPods [specification repository](https://github.com/CocoaPods/Specs). If this is the case, simply edit your project `Podfile` file to add an entry for CoconutKit:

    platform :ios
    pod 'CoconutKit', '~> <version>'

If the specification file is not available from the official CocoaPods specification repository, use the specification file available in the `Tools/CocoaPods` directory. Either add it to your `~/.cocoapods` local specification repository (creating the dedicated folder structure), or edit your project `Podfile` to tell CocoaPods to use the file directly:

    platform :ios
    pod 'CoconutKit', :podspec => '/absolute/path/to/CoconutKit/Tools/CocoaPods/CoconutKit.podspec'
    
The specification file has successfully been tested with CocoaPods 0.15.2.

#### Enabling logging

CoconutKit uses a logger to provide valuable information about its internal status. This should help you easily discover any issue you might encounter when using CoconutKit. To enable internal CoconutKit logging:

* If you are using CoconutKit binaries:
	* Link your project against the debug version of the CoconutKit `.staticframework` (edit your project debug configuration settings so that the debug binaries are used)
	* Add an `HLSLoggerLevel` entry to your project `.plist` to set the desired logging level (`DEBUG`, `INFO`, `WARN`, `ERROR` or `FATAL`)
* If you are using CocoaPods:
	* Edit the generated `Pods.xcodeproj` project settings, adding `-DHLS_LOGGER` to the _Other C Flags_ setting for the debug configuration. This setting is sadly lost every time your run `pod install` to generate the CocoaPods workspace
	* Add an `HLSLoggerLevel` entry to your project `.plist` to set the desired logging level (`DEBUG`, `INFO`, `WARN`, `ERROR` or `FATAL`)

CoconutKit logger also supports [XcodeColors](https://github.com/robbiehanson/XcodeColors). Simply install the XcodeColors plugin and enable colors when debugging your project within Xcode by adding an environment variable called `XcodeColors` to your project schemes. Projects in the CoconutKit workspace all have this environment variable set. If you see strange `[fg` sequences in your Xcode debugging console, either install XcodeColors or disable the `XcodeColors` environment variable by editing the corresponding project schemes.

### How should I use CoconutKit?

After CoconutKit has been added to your project, simply import its global public header file in your project `.pch` file:

* If you are using CoconutKit binaries, use `#import <CoconutKit/CoconutKit.h>`
* If you are using CocoaPods, use `#import "CoconutKit.h"`

Some code snippets have been provided in the `Snippets` directory (and more will probably be added in the future), both for ARC and non-ARC projects. Add them to your favorite snippet manager to make working with CoconutKit classes even more easier!

### How can I learn using CoconutKit?

To discover what CoconutKit can do, read the [project wiki](https://github.com/defagos/CoconutKit/wiki) and, once you want to learn more, have a look at header documentation. I try to keep documentation close to the code, that is why header documentation is rather extensive. All you need to know should be written there since I avoid detailed external documentation which often gets outdated. After you have read the documentation of a class, have a look at the demos and unit tests to see how the component is used in a concrete case.

Good documentation is critical. If you think some documentation is missing, unclear or incorrect, please file a ticket.

### Versions and migration guide

I sadly have not enough time to develop new features and to refactor existing ones while keeping CoconutKit public APIs unchanged or backward compatible. Sometimes method prototypes or even class names must change, and I cannot afford marking methods or classes as deprecated while still maintaining them. Let's face the truth: CoconutKit is not yet widely enough used to justify the amount of work which would be required.

When updating the version of CoconutKit you use, your project might therefore not compile anymore. In general, you should keep in mind that:

* major versions might contain major changes to the public APIs
* minor versions should only contain minor changes

#### Migrating from 1.x to 2.x

Version 2.0 is a major improvement over 1.x, which means several classes have undergone major changes. As usual, please read the header documentation to find what has changed:

* View controller containers:
	* Placeholder view controllers can now display several insets simultaneously, intead of just one. The `placeholderView` outlet has therefore been replaced with a `placeholderViews` outlet collection, and you need to update your code and nib files accordingly. Methods to set an inset view controller now require a new index parameter specifying which inset must be set. Moreover, transition animations are not specified anymore using an enum value, but rather using a class
	* Stack controllers transition animations are not specified anymore using an enum value, but rather using a class. An `animated` parameter has also been added to push and pop methods
	* The CoconutKit container `forwardingProperties` setting has been removed. If you relied on it, you will need to update your code accordingly
* HLSViewController autorotation is now managed using the new methods introduced with iOS 6, on iOS 4 and 5 as well. All your HLSViewController subclasses must be updated accordingly by removing any existing `-shouldAutorotateToInterfaceOrientation:` implementation, replacing it with `-shouldAutorotate` and `-supportedInterfaceOrientations` implementations
* The way your create an `HLSAnimation` has changed. `HLSAnimationStep` has now been split into `HLSViewAnimationStep` (for UIView block-based animation steps) and `HLSLayerAnimationStep` (for Core Animation layer-based animation steps). The old `HLSViewAnimationStep` has been replaced with `HLSViewAnimation` for UIView block-based animations, and a corresponding `HLSLayerAnimation` has been introduced. The animations you previously defined by setting transforms on `HLSViewAnimationStep` are now created by calling translation, rotation or scale methods on `HLSViewAnimation`, respectively `HLSLayerAnimation`
* Core Data: Explicit managed contexts have been eliminated. You now must create an `HLSModelManager` object and use the corresponding class methods to push it onto a stack for the current thread. Then use the `HLSModelManager` context-free methods to interact with the store

### The CoconutKit workspace

The workspace file contains everything to build CoconutKit binaries, demos and unit tests.

Several projects are available:

* `CoconutKit`: The project used to build the CoconutKit static library
* `CoconutKit-resources`: The project creating the `.bundle` containing all resources needed by CoconutKit
* `CoconutKit-dev`: The main project used when working on CoconutKit. This project is an almost empty shell referencing files from both the `CoconutKit` and `CoconutKit-demo` projects
* `CoconutKit-demo`: The project used to test CoconutKit binaries against linker issues. When building the demo project, the CoconutKit `.staticframework` is first built and saved into the `Binaries` directory
* `CoconutKit-test`: The project running unit tests. This project references files from the `CoconutKit` project

Several schemes are available:

* `CoconutKit`: Builds the CoconutKit static library
* `CoconutKit-staticframework`: Builds the CoconutKit `.staticframework` into the `Binaries` directory, both for the Release and Debug configurations
* `CoconutKit-resources`: Builds the CoconutKit resource bundle into the `CoconutKit` directory
* `CoconutKit-(dev|demo)`: The standard CoconutKit component demo
* `CoconutKit-(dev|demo)-RootStack`: A demo where CoconutKit stack controller is the root view controller of an application
* `CoconutKit-(dev|demo)-RootSplitView`: A demo where a UIKit split view controller is the root view controller of an application
* `CoconutKit-(dev|demo)-RootTabBar`: A demo where a UIKit tab bar controller is the root view controller of an application
* `CoconutKit-(dev|demo)-RootNavigation`: A demo where a UIKit navigation controller is the root view controller of an application
* `CoconutKit-(dev|demo)-RootStoryboard`: A demo where a storyboard defines the whole application view controller hierarchy (itself managed using CoconutKit view controller containers). Runs on iOS 5 and above
* `CoconutKit-test`: CoconutKit unit tests

Schemes ending with `ios4` are similar, but with features not available on iOS 4 removed.

### Frequently asked questions

#### With which versions of iOS is CoconutKit compatible?

CoconutKit is compatible with iOS 4 and later (this will change as old OS versions get deprecated), both for iPhone and iPad projects. Please file a bug if you discover this is not the case.

#### With which versions of Xcode and the iOS SDK is CoconutKit compatible?

CoconutKit can be used with Xcode 4.4.1 (iOS SDK 5.1) and above, but is best used with the latest versions of Xcode and of the iOS SDK. Binaries themselves have been compiled using LLVM so that only projects built with LLVM will be able to successfully link against it (linking a project built with LLVM GCC against a library built with LLVM may result in crashes at runtime).

#### Can I use CoconutKit with ARC projects?

Yes. As long as you use binaries or CocoaPods, no additional configuration is required.

#### Can I use CoconutKit for applications published on the AppStore?

CoconutKit does not use any private API and is therefore AppStore friendly. Several applications hortis developed use CoconutKit and have successfully been approved.

#### Why have you released CoconutKit?

My company, [hortis](http://www.hortis.ch/), has a long tradition of open source development. This is one of the major reasons why I started to work for its entity devoted to mobile development, hortis le studio. 

When I started iOS development a few years ago, I immediately felt huge gaps needed to be filled in some areas, so that I could get more productive and write better applications. CoconutKit was born.

During the last years, I was able to develop some areas of expertise (most notably view controller management, animations and Core Data). I always try to push the envelope in those areas, and I humbly hope the iOS community will be able to benefit from my experience.

#### Does CoconutKit use ARC?

No, CoconutKit currently does not use ARC itself. This will maybe change in a not-so-near future as ARC is adopted.

#### What does the HLS class prefix mean?

HLS stands for hortis le studio.

### Contributing to CoconutKit

You can contribute, and you are strongly encouraged to. Use github pull requests to submit your improvements and bug fixes. You can submit everything you want, documentation and comment fixes included! Everything that tends to increase code quality is always warmly welcome.

#### Requirements

There are some requirements when contributing, though:

* Code style guidelines are not formalized anywhere, but try to stay as close as possible to the style I use. This saves me some work when merging pull requests. IMHO, having a consistent way of organizing and writing source code makes it easier to read, write and maintain
* Read my [article about the memory management techniques](http://subjective-objective-c.blogspot.com/2011/04/use-objective-c-properties-to-manage.html) I use, and apply the same rules
* Do not use ARC
* Use of private APIs is strictly forbidden (except if the private method calls never make it into released binaries. You can still call private APIs to implement helpful debugging features, for example)
* Development and demo projects should be updated. Both are almost the same, except that the demo project uses the library in its binary form. New components should be written using the development project, so that an example with good code coverage is automatically available when your new component is ready. The demo project should then be updated accordingly
* Unit tests require version 0.5.2 of the [GHUnit framework for iOS](https://github.com/gabriel/gh-unit) to be installed under `/Developer/Frameworks/GHUnitIOS/0.5.2/GHUnitIOS.framework`

#### Writing code

Use the `CoconutKit-dev` project to easily write and test your code. When you are done with the `CoconutKit-dev` project, update the `CoconutKit` and `CoconutKit-demo` projects to mirror the changes you made to the source tree. New resources must be added to the `CoconutKit-resources` project. 

Any new public header file must be added to the `CoconutKit-(dev|test).pch` file, as well as to the `publicHeaders.txt` file located in the `CoconutKit-dev` directory. Source files with linker issues (source files containing categories only, or meant to be used in Interface Builder) must also be added to the `bootstrap.txt` file. Please refer to the `make-fmwk.sh` documentation for more information.

For non-interactive components, you should consider adding some test cases to the `CoconutKit-test` project as well. Update it to mirror the changes made to the source and resource files of the `CoconutKit` project.

#### Code repository

Branches are managed using [git-flow](https://github.com/nvie/gitflow/):

* `master` is the stable branch on which commits are only made when a new official release is created
* `develop` is the main development branch and should be stable enough for use in between official releases
* all new features are developed on `feature` branches. You should avoid such branches since they might not be stable all the time

If you plan to develop for CoconutKit, install `git-flow` and setup your local repository by running `git flow init`, using the default settings.


### Acknowledgements

I really would like to thank my company for having allowed me to publish this work, as well as all my colleagues which have contributed and given me invaluable advice. This work is yours as well!

#### Contributors

The following lists all people who contributed to CoconutKit:

* [Cédric Luthi (0xced)](http://0xced.blogspot.com/) wrote the clever dynamic localization functionality, as well as the HLSWebViewController class
*  Joris Heuberger wrote the HLSLabel class

### Release notes

#### Version 2.0.2

* Fix an issue with non-running animations incorrectly started after the application wakes up from background
* Add HLSFileManager
* Fix default capacity for stacks used in storyboards
* Add bundle parameter to HLSModelManager creation methods

#### Version 2.0.1

* HLSCursor now fills the associated view frame and resizes properly, the spacing parameter has therefore been removed. The cursor behaviour has been improved. The animation duration can now be changed
* Fix a bug with responders

#### Version 2.0

* CoconutKit containers have been rewritten from scratch and are now more powerful than ever:
	* Support for iOS 4, 5 and 6
	* Correct implementation of all view controller methods introduced with iOS 4 and 5
	* Placeholder view controllers can now display several child view controllers (previously only one)
	* Full compatibility with UIKit built-in containers
	* New transition animations, which can now be completely customized
	* Segue support on iOS 5 and above
	* Insertion and removal of view controllers at arbitrary locations in a stack of view controllers
	* Support for container view resizing
* Complete API to implement your own correct view controller containers easily (HLSContainerStack). The old API (HLSContainerContent) is not available anymore
* Animations have been rewritten from scratch and are now more powerful than ever:
    * Core Animation layer-based animations are now supported
	* Core Animation layer-based and UIView block-based animations can be mixed
	* Animations can be paused and resumed
	* Animations can be played starting from an arbitrary start time, or delayed
	* Animations can be repeated or played in a loop
	* Animations are paused and resumed automatically when the application enters and exits background
	* Slow motion has been implemented for Core Animation layer-based animations (iOS simulator only)
* HLSViewController: iOS 6 autorotation methods provide a single consistent formalism to define autorotation behavior, even on iOS 4 and 5
* An aurototation mode property has been added to CoconutKit and UIKit containers, with which containers can decide whether their children decide whether rotation can occur or not
* Core Data: HLSModelManager has been improved:
    * Managed contexts are not visible anymore, all database operations are now made through context-free methods acting on a stack of model manager objects (on a per-thread basis)
    * All kinds of persistent stores are now supported
* HLSLabel has been added. This label performs automatic font size adjustment and provides a vertical alignment property
* The CoconutKit Xcode workspace has been improved. The `.staticframework` can now built within Xcode, and demo projects build it first as well
* Full iOS 6 support (autorotation, view unloading deprecation) 
* HLSReloadable has been removed as it was pretty useless
* Tools for the CocoaPods source code release have been added
* Optional web view preloading has been added when the application starts
* XcodeColors support has been added to HLSLogger
* A `-popoverController` method has been added to UIViewController so that parent popover controllers can easily be accessed
* And of course, many other minor fixes, additions and implementation improvements!

#### Version 1.1.4

* CocoaPods can and should now be used for easy setup
* Resources have been packaged into a bundle
* Added new fade-in animation
* Added zeroing weak references
* An HLSAnimation is now automatically canceled if it has a delegate which gets deallocated
* Animations can now be canceled (this inhibits remaining delegate events) or terminated (this does not inhibit them)
* HLSKenBurnsSlideshow is now a special case of the new HLSSlideshow class (several transition effects available). The HLSSlideshowDelegate protocol has been added
* Minor fixes and implementation improvements

#### Version 1.1.3

* Added scroll view synchronization. This makes parallax scrolling easy to implement
* Fixed bugs (tab bar controller in custom containers, simultaneous container add / removal operations, iOS 4 crashes) as well as link issues with HLSActionSheet

#### Version 1.1.2

* Container view controller bug fix for iOS 5: viewWillAppear: and viewDidAppear: are now forwarded correctly to child view controllers when the container is the root of an application or presented modally

#### Version 1.1.1

* CGAffineTransform replaced by CATransform3D for creating richer animations
* New transition styles for containers (Flipboard-like push, horizontal and vertical flips)
* Various bug fixes

#### Version 1.1

* Added easy Core Data validation
* Added UILabel and UIButton localization in nib files
* Added Ken Burns slideshow
* Added categories for UIToolbar, UINavigationBar and UIWebView skinning
* Various bug fixes

#### Version 1.0.1

* Added dynamic localization (thanks to Cédric Luthi)
* Added unit tests
* Added action sheet
* Added UIView category for conveying custom information and tagging a view using a string
* Added code snippets
* Renamed HLSXibView as HLSNibView, and the xibViewName method as nibName. Removed macros HLSTableViewCellGet and HLSXibViewGet (use class methods instead)
* Moved methods for calculating start and end dates to NSCalendar extension
* Flatter project layout
* Fixes for iOS 5
* Various bug fixes

#### Version 1.0

Initial release

### Contact

Feel free to contact me if you have any questions or suggestions:

* mail: defagos ((at)) gmail ((dot)) com
* Twitter: @defagos

Thanks for your feedback!

### Licence

Copyright (c) 2011-2012 hortis le studio, Samuel Défago

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
