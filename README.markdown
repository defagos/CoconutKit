### What is CoconutKit?

CoconutKit is a library of high-quality iOS components written at my company and in my spare time. It includes several tools for dealing with view controllers, multi-threading, animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.

Most of CoconutKit components are not sexy as is, but rather useful. Do not be freaked out! These components are meant to make you more productive, less focused on debugging, so that you can spend more time working on the design of your application (if you have a great designer at hand, of course). Give CoconutKit a try, your life as an iOS programmer will never be the same afterwards!

CoconutKit is distributed under a permissive [MIT license](http://www.opensource.org/licenses/mit-license.php), which means you can freely use it in your own projects (commercial or not).

### What can I find in CoconutKit?

CoconutKit provides your with several kinds of classes covering various aspects of iOS development:

* High-quality view controller containers. These containers are the result of two years of hard work, and exceed by far the capabilities of UIKit built-in containers. In particular, view controllers can be combined or stacked, using any kind of transition animation (even yours). Your applications will never look the same as before!
* View controller containment API, richer, easier to use and far more powerful than the UIKit containment API. Writing your own view controller containers correctly has never been easier!
* Easy way to change the language used by an application at runtime, without having to alter system preferences
* Localization of labels and buttons directly in nib files, without having to create and bind outlets anymore
* Classes for creating animations made of several UIView block-based or Core Animation-based sub-animations in a declarative way. Such animations can be paused, reversed, played instantaneously, cancelled, repeated, and even more! Animations have never been so fun and easy to create!
* Core Data model management and validation made easy. The usual boilerplate Core Data code has been completely eliminated. Interactions with managed contexts have been made simple by introducing context-free methods acting on a context stack. Core Data validation boilerplate code is never required anymore, and text field bindings make form creation painless
* View controllers for web browsing and easier table view search management
* Multi-threaded task management, including task grouping, cancelation, progress status, task dependencies and remaining time estimation
* New controls
	* cursor
	* slideshow with several transition animations (cross fade, Ken Burns, etc.)
	* label with vertical alignment
* Classes for common UI tasks (keyboard management, interface locking)
* Classes for single-line table view cell and view instantiations
* Lightweight logger, assertions, float comparisons, etc.
* Various extensions to Cocoa and UIKit classes (calendrical calculations, collections, notifications, etc.)
* ... and more!
* ... and even more to come!

### Where can I download CoconutKit?

You can download CoconutKit from [the official github page](https://github.com/defagos/CoconutKit), though you should in general directly checkout the git repository. Note that there are submodules you must update using the `git submodule update --init` command.

### Supporting development

CoconutKit is and will stay free. However, if you enjoy using it, you can support the countless hours of work that are invested into its creation. Thank you in advance! 

[![Donate to author](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=3V35ZXWYXGAYG&lc=CH&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted)

### Credits

If you enjoy the library, I would sincerely love being credited somewhere in your application, for example on some about page. Thanks for your support!

### How can I discover CoconutKit components?

Check out the CoconutKit source code repository by visiting [the official project github page](https://github.com/defagos/CoconutKit), open the workspace and either run the `CoconutKit-demo` or the `CoconutKit-dev` targets. The result of running those targets is the same, the only difference is that `CoconutKit-demo` compiles and builds CoconutKit as a static framework before linking the demo against it, whereas `CoconutKit-dev` builds and links CoconutKit as a project dependency.

### Why should I use CoconutKit?

When designing components, I strongly emphasize on clean and documented interfaces, as well as on code quality. My goal is to create components that are easy to use, reliable, and which do what they claim they do, without nasty surprises. You should never have to look at a component implementation to know how it works, this should be obvious just by looking at its interface. I also strive to avoid components that leak or crash. If those are qualities you love to find in libraries, then you should start using CoconutKit now!

### How should I add CoconutKit to my project?

You can add CoconutKit to your project in several different ways:

#### Adding binaries manually

To compile the binaries, checkout the project and run the `staticframework` scheme. The build product is a `.staticframework` package which you must add to your project (the _Create groups for any added folders_ option must be checked). The project must be linked against the following frameworks:

* `CoreData.framework`
* `CoreGraphics.framework`
* `CoreText.framework`
* `Foundation.framework`
* `MobileCoreServices.framework`
* `QuartzCore.framework`
* `QuickLook.framework`
* `UIKit.framework`
* `WebKit.framework`

Explicit linkig is only needed if you disable the auto-linking feature available since Xcode 5.

#### Adding source files using CocoaPods

Since CoconutKit 2.0, the easiest way to add CoconutKit to a project is using [CocoaPods](https://github.com/CocoaPods/CocoaPods). The CoconutKit specification file is available from the official CocoaPods [specification repository](https://github.com/CocoaPods/Specs). Simply edit your project `Podfile` file to add an entry for CoconutKit:

    platform :ios
    pod 'CoconutKit', '~> <version>'

#### Enabling logging

CoconutKit uses a logger to provide valuable information about its internal status. This should help you easily discover any issue you might encounter when using CoconutKit. To enable internal CoconutKit logging:

* If you are using CoconutKit binaries, link your project against the debug version of the CoconutKit `.staticframework` (edit your project debug configuration settings so that the debug binaries are used)
* If you are using CocoaPods, edit the generated `Pods.xcodeproj` project settings, adding `-DHLS_LOGGER` to the _Other C Flags_ setting for the debug configuration. This setting is sadly lost every time your run `pod install` to generate the CocoaPods workspace

The default logging level is info. To change the logging level or to display an in-app interface for logger management, please refer to `HLSLogger` documentation.

CoconutKit logger also supports [XcodeColors](https://github.com/robbiehanson/XcodeColors). Simply install the XcodeColors plugin and enable colors when debugging your project within Xcode by adding an environment variable called `XcodeColors` to your project schemes. Projects in the CoconutKit workspace all have this environment variable set. If you see strange `[fg` sequences in your Xcode debugging console, either install XcodeColors or disable the `XcodeColors` environment variable by editing the corresponding project schemes.

### How should I use CoconutKit?

After CoconutKit has been added to your project, simply import its global public header file in your project `.pch` file:

* If you are using CoconutKit binaries, use `#import <CoconutKit/CoconutKit.h>`
* If you are using CocoaPods, use `#import "CoconutKit.h"`

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

Two projects are available:

* `CoconutKit`: The project used to build the CoconutKit static library
* `CoconutKit-demo`: Demos for most of CoconutKit functionalities. This is also the project I use when working on new CoconutKit components

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
* `CoconutKit-tests`: CoconutKit unit tests

### Frequently asked questions

#### With which versions of iOS is CoconutKit compatible?

In general, I try to keep CoconutKit compatible with at least the two most recent major versions of iOS. Currently, CoconutKit is therefore officially compatible with iOS 7 and 8, both for iPhone and iPad projects.

#### With which versions of Xcode and the iOS SDK is CoconutKit compatible?

CoconutKit is best used with the most recent Xcode and iOS SDK releases. In general you should be able to use and compile CoconutKit with prior versions of Xcode, though this is not officially supported. Currently, CoconutKit is therefore officially compatible with Xcode 6 and the iOS 8 SDK.

#### With which architectures is CoconutKit compatible?

CoconutKit is compatible with all 32-bit and 64-bit architectures.

#### Can I use CoconutKit with Swift projects?

Yes, you can if you use CoconutKit as a `.staticframework`. Support with bridging headers is currently not officially supported. Add the `.staticframework` to your project and `import CoconutKit` where needed. If automatic linking is enabled no explicit linking against system frameworks is required.

#### Can I use CoconutKit for applications published on the AppStore?

CoconutKit does not use any private API and is therefore AppStore friendly. Several applications I developed use CoconutKit and have successfully been approved.

#### Why have you released CoconutKit?

When I started iOS development a few years ago, I immediately felt huge gaps needed to be filled in some areas, so that I could get more productive and write better applications. CoconutKit was born.

During the last years, I was able to develop some areas of expertise (most notably view controller management, animations and Core Data). I always try to push the envelope in those areas, and I humbly hope the iOS community will be able to benefit from my experience.

#### What does the HLS class prefix mean?

HLS stands for hortis le studio, the company I worked for when I started CoconutKit development. 

### Contributing to CoconutKit

You can contribute, and you are warmly encouraged to. Use github pull requests to submit your improvements and bug fixes. You can submit everything you want, documentation and comment fixes included! Everything that tends to increase code quality is always warmly welcome.

#### Requirements

There are some requirements when contributing, though:

* Code style guidelines are not formalized anywhere, but try to stay as close as possible to the style I use. This saves me some work when merging pull requests. IMHO, having a consistent way of organizing and writing source code makes it easier to read, write and maintain
* Use ARC
* Use of private APIs is strictly forbidden (except if the private method calls never make it into released binaries. You can still call private APIs to implement helpful debugging features, for example)
* New components should be added the demo project, so that an example with good code coverage is available
* Unit tests require use of the [GHUnit framework for iOS](https://github.com/gabriel/gh-unit), supplied in the `Externals` directory

#### Writing code

Add new component files to the `CoconutKit` project. Use the `CoconutKit-dev` project to create a corresponding demo. If your component requires resources, those must be added to the `CoconutKit-resources` target of the `CoconutKit` project. 

Any new public header file must be added to the `CoconutKit-dev-Prefix.pch` file, as well as to the `publicHeaders.txt` file located in the `CoconutKit-dev` directory. Source files with linker issues (source files containing categories only, or meant to be used in Interface Builder) must also be added to the `bootstrap.txt` file. Please refer to the `make-fmwk.sh` documentation for more information.

For non-interactive components, you should consider adding some test cases to the `CoconutKit-tests` target as well.

#### Code repository

Branches are managed using [git-flow](https://github.com/nvie/gitflow/):

* `master` is the stable branch on which commits are only made when a new official release is created
* `develop` is the main development branch and should be stable enough for use in between official releases
* all new features are developed on `feature` branches. You should avoid such branches since they might not be stable all the time

If you plan to develop for CoconutKit, install `git-flow` and setup your local repository by running `git flow init`, using the default settings.


### Acknowledgements

I really would like to thank my companies for having allowed me to publish this work, as well as all my colleagues which have contributed and given me invaluable advice. This work is yours as well!

#### Contributors

The following lists all people who contributed to CoconutKit:

* [Cédric Luthi (0xced)](http://0xced.blogspot.com/) wrote the clever dynamic localization functionality, as well as the HLSWebViewController class
*  Joris Heuberger wrote the HLSLabel class

### Release notes

#### Version 2.1.2

* Fixes for CocoaPods (public headers were incorrectly cleaned up after generation)

#### Version 2.1.1

* Fixes for CocoaPods

#### Version 2.1

* Compatibility with iOS 7 and 8. The deployment target is now iOS 7
* 64-bit compatibility
* Code modernization
* Migration to ARC (finally!)
* Removal of useless code and functionalities:
  * `HLSActionSheet` has been removed since `UIActionSheet` has been replaced by `UIAlertController`
  * Useless `HLSConverters` conversion methods
* Changes to `HLSLabel` behavior
* Improvement of the build process
* Fixed CocoaPods specification file

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

Copyright (c) 2011-2014 Samuel Défago

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Other licences

CoconutKit uses some external code. Thanks those indirect contributors for their awesome work. Here are the associated licence files:

#### MAZeroingWeakRef

MAZeroingWeakRef and all code associated with it is distributed under a BSD license, as listed below.


Copyright (c) 2010, Michael Ash
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of Michael Ash nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#### MAKVONotificationCenter

MAKVONotificationCenter and all code associated with it is distributed under a BSD license, as listed below.


Copyright (c) 2008, Michael Ash
Copyright (c) 2012, Gwynne Raskind
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of Michael Ash nor the name of Gwynne Raskind may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/defagos/coconutkit/trend.png)](https://bitdeli.com/free "Bitdeli Badge")