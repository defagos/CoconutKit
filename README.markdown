### What is CoconutKit?

CoconutKit is a library of high-quality iOS components written at [hortis le studio](http://www.hortis.ch/) and in my spare time. It includes several tools for dealing with view controllers, multi-threading, view animations, as well as some new controls and various utility classes. These components are meant to make the life of an iOS programmer easier by reducing the boilerplate code written every day, improving code quality and enforcing solid application architecture.

Most of CoconutKit components are not sexy, but rather useful. Do not be freaked out! These components are meant to make you more productive, less focused on debugging, so that you can spend more time working on the design of your application (if you have a great designer at hand, of course).

CoconutKit is distributed under a permissive [MIT license](http://www.opensource.org/licenses/mit-license.php), which means you can freely use it in your own projects (commercial or not).

### What can I find in CoconutKit?

CoconutKit provides your with several kinds of classes covering various aspects of iOS development:

* High-quality view controller containers (view controller embedding, view controller stacking) with several transition animations
* Easy way to change the language used by an application at runtime, without having to alter system preferences
* Localization of labels and buttons directly in nib files, without having to create and bind outlets anymore
* Core Data validation made easy: No more boilerplate code to write so that your code can focus on business logic. Moreover, text fields can be bound for field formatting and synchronization, both in model -> view and view -> model directions. Forms managed by Core Data have never been easier to write!
* View controllers for web browsing and easier table view search management
* Multi-threaded task management, including task grouping, cancelation, progress status, task dependencies and remaining time estimation
* Classes for creating complex view animations made of several sub-animations
* New controls (text field moving automatically with the keyboard, new kind of segmented control, Ken Burns slideshow)
* Classes for common UI tasks (keyboard management, interface locking)
* Classes for single-line table view cell and view instantiations
* Methods for skinning some built-in controls prior to iOS 5 appearance API
* Lightweight logger, assertions, float comparisons, etc.
* Various extensions to Cocoa and UIKit classes (calendrical calculations, collections, notifications, etc.)
* ... and more!
* ... and even more to come!

### Where can I download CoconutKit?

You can download CoconutKit from [the official github page](https://github.com/defagos/CoconutKit), both in binary and source forms. [A companion repository](https://github.com/defagos/CoconutKit-binaries) exists for easy installation using CocoaPods, but you do not need to check it out directly.

### Why should I use CoconutKit?

When designing components, I strongly emphasize on clean and documented interfaces, as well as on code quality. My goal is to create components that are easy to use, reliable, and which do what they claim they do, without nasty surprises. You should never have to look at a component implementation to know how it works, this should be obvious just by looking at its interface. I also strive to avoid components that leak or crash. If those are qualities you love to find in libraries, then you should start using CoconutKit now!

### How should I add CoconutKit to my project?

You can add CoconutKit to your project in several different ways.

#### Adding binaries using CocoaPods

Since CoconutKit 1.1.4, the easiest and recommended way to add CoconutKit to a project is using [CocoaPods](https://github.com/CocoaPods/CocoaPods). The CoconutKit specification file should be available from the official CocoaPods [specification repository](https://github.com/CocoaPods/Specs). If this is the case, simply edit your project `Podfile` file to add an entry for CoconutKit:

    platform :ios
    dependency 'CoconutKit', '~> <version>'

If the specification file is not available from the official CocoaPods specification repository, use the specification file available in the `Tools/CocoaPods` directory. Either add it to your `~/.cocoapods` local specification repository (creating the dedicated folder structure), or edit your project `Podfile` to tell CocoaPods to use the file directly:

    platform :ios
    dependency 'CoconutKit', :podspec => '/absolute/path/to/CoconutKit/Tools/CocoaPods/CoconutKit.podspec'
    
The specification file has successfully been tested with the latest stable CocoaPods release (0.5.1).

#### Adding binaries manually

You can grab the latest tagged binary package available from [the project download page](https://github.com/defagos/CoconutKit/downloads). Add the `.staticframework` directory to your project ("Create groups for any added folders" must be checked) and link your project against the following system frameworks:

* CoreData.framework
* MessageUI.framework
* QuartzCore.framework

#### Adding CoconutKit in source form

CoconutKit is meant to be used in binary form to reduce compile times and executable size. You can add the CoconutKit project as a project dependency, but this is an approach I do not endorse and therefore do not officially support.

### How should I use CoconutKit?

After CoconutKit has been added to your project, simply import the headers you need using the `#import <CoconutKit/HeaderFile.h>` syntax. Though you can import files only where you need them, I strongly recommend importing the CoconutKit global header file from your project `.pch` file once for all (`#import <CoconutKit/CoconutKit.h>`). This file includes all CoconutKit public headers so that you do not need any other import.

Some code snippets have been provided in the `Snippets` directory (and more will probably be added in the future). Add them to your favorite snippet manager to make working with CoconutKit classes even more easier!

### How can I learn using CoconutKit?

Learning how to use CoconutKit components always starts with header documentation. I try to keep documentation close to the code, that is why header documentation is rather extensive. All you need to know should be written there since I avoid external documentation which often gets outdated. After you have read the documentation of a class, have a look at the demos and unit tests to see how the component is used in a concrete case.

Good documentation is critical. If you think some documentation is missing, unclear or incorrect, please file a ticket.

### Credits

If you enjoy the library, [hortis](http://www.hortis.ch/) and I would sincerely love being credited somewhere in your application, for example on some about page. Thanks for your support!

### Frequently asked questions

#### With which versions of iOS is CoconutKit compatible?

CoconutKit should be compatible with iOS 3.2 and later (this will change as old OS versions get deprecated), both for iPhone and iPad projects. Please file a bug if you discover it is not the case.

#### With which versions of Xcode is CoconutKit compatible?

CoconutKit should be used with the latest versions of Xcode and of the iOS SDK. Binaries themselves have been compiled using GCC so that projects built using GCC or LLVM can link against it. As LLVM is adopted I will start building binaries using LLVM.

#### Can I use CoconutKit with ARC projects?

Yes. As long as you use binaries, no additional configuration is required.

#### Can I use CoconutKit for applications published on the AppStore?

CoconutKit does not use any private API and is therefore AppStore friendly. Several applications hortis developed use CoconutKit and have successfully been approved.

#### Why have you released CoconutKit?

My company, [hortis](http://www.hortis.ch/), has a long tradition of open source development. This is one of the major reasons why I  started to work for its entity devoted to mobile development, hortis le studio. After months of hard work, I felt the library was getting mature enough to deserve being published. I sincerely hope people will find this work interesting and start contributing code or ideas, so that a fruitful collaboration process can arise.

#### Does CoconutKit use ARC?

No, CoconutKit currently does not use ARC. This will maybe change in the future as ARC is adopted.

#### What does the HLS class prefix mean?

HLS stands for hortis le studio.

### Contributing to CoconutKit

You can contribute, and you are strongly encouraged to. Use github pull requests to submit your improvements and bug fixes. You can submit everything you want, documentation and comment fixes included! Everything that tends to increase code quality is always warmly welcome.

#### Requirements

There are some requirements when contributing, though:

* Code style guidelines are not formalized anywhere, but try to stay as close as possible to the style I use. This saves me some work when merging pull requests. IMHO, having a consistent way of organizing and writing source code makes it easier to read, write and maintain
* Read my [article about the memory management techniques](http://subjective-objective-c.blogspot.com/2011/04/use-objective-c-properties-to-manage.html) I use, and apply the same rules
* Do not use ARC
* Use of private APIs is strictly forbidden
* Development and demo projects are also included. Both are almost the same, except that the demo project uses the library in its binary form. New components should be written using the development project, so that an example with good code coverage is automatically available when your new component is ready. The demo project should then be updated accordingly
* Unit tests require the [GHUnit framework](https://github.com/gabriel/gh-unit) `GHUnitIOS.framework` to be installed under `/Developer/Frameworks`.

#### Writing code

After checking out the source code repository, open the Xcode 4 workspace. Five projects have been created:

* CoconutKit: The project used to build the CoconutKit static library
* CoconutKit-resources: The project building the `.bundle` containing all resources needed by CoconutKit
* CoconutKit-demo: The project used to test CoconutKit binaries against linker issues
* CoconutKit-dev: The main project used when working on CoconutKit. This project is an almost empty shell referencing files from both the CoconutKit and CoconutKit-demo projects
* CoconutKit-test: The project used for writing unit tests. This project references files from the CoconutKit project

Use the CoconutKit-dev project to easily write and test your code. When you are done with the CoconutKit-dev project, update the CoconutKit and CoconutKit-demo projects to mirror the changes you made to the source tree. Any new public header file must be added to the CoconutKit-dev `.pch` file, as well as to the `publicHeaders.txt` file located in the CoconutKit-dev directory. Source files with linker issues (source files containing categories only, or meant to be used in Interface Builder) must also be added to the `bootstrap.txt` file. Please refer to the `make-fmwk.sh` documentation for more information.

For "non-interactive" components, you should consider adding some test cases to the CoconutKit-test project as well. Update it to mirror the changes made to the source and resource files of the CoconutKit project, and update the `.pch` to reference any new public header.

#### Building binaries

CoconutKit is meant to be built into a .staticframework package using the [make-fmwk command](https://github.com/defagos/make-fmwk). After having installed the command somewhere in your path, run it from the CoconutKit static library project directory, as follows:

    make-fmwk.sh -o <output_directory> -u <version> Release
    make-fmwk.sh -o <output_directory> -u <version> Debug
    
e.g.

    make-fmwk.sh -o ~/MyBuilds -u 1.0 Release
    make-fmwk.sh -o ~/MyBuilds -u 1.0 Debug

### Acknowledgements

I really would like to thank my company for having allowed me to publish this work, as well as all my colleagues which have contributed and given me invaluable advice. This work is yours as well!

Several clever classes (e.g. dynamic localization, web view controller) and other contributions by [Cédric Luthi (0xced)](http://0xced.blogspot.com/). Thanks!

### Release notes

#### Version 1.1.4

* CocoaPods can now be used for easy installation
* Resources have been packaged into a bundle
* Added new fade-in animation
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

Copyright (c) 2011 hortis le studio, Samuel Défago

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
