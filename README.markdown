![Header](README-images/coconutkit_header.png)

CoconutKit is a **productivity framework for iOS**, crafted with love and focusing on ease of use. It provides a convenient, Cocoa-friendly toolbox to help you efficiently write robust and polished native applications.

[![Platform](https://img.shields.io/cocoapods/p/CoconutKit.svg?style=flat)](http://cocoadocs.org/docsets/XCDYouTubeKit/)
[![Pod Version](https://img.shields.io/cocoapods/v/CoconutKit.svg?style=flat)](http://cocoadocs.org/docsets/XCDYouTubeKit/)
[![License](https://img.shields.io/cocoapods/l/CoconutKit.svg?style=flat)](LICENSE)
[![Donate to author](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=3V35ZXWYXGAYG&lc=CH&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted)


## About

Unlike most libraries which focus on a specific task, like networking or image processing, CoconutKit addresses **developer productivity in general**. As an iOS developer, you namely more or less face the same issues on each project you work on:

* Changes due to fast-paced iterative development, stakeholder indecision or design changes
* Presenting data and gathering user input
* Localization

Most of the code related to these issues is written in view controllers, and clutters their implementation with redundant, boring boilerplate code.

CoconutKit provides a set of tools to **tackle the problem of fat view controller** classes by:

* **Eliminating boilerplate code** and decluttering view controller implementations
* Making it easier to **decompose your application in smaller view controllers** with well-defined responsibilities
* Letting you **assemble and reorganize view controllers** effortlessly

Unlike approaches which apply patterns like [MVVM](http://www.objc.io/issue-13/mvvm.html), CoconutKit does not require any major changes to your code or to the way you work or think, only the good ol' language and patterns you are comfortable with.

## Features

To make it easy to create reusable, smaller view controllers with shorter implementations, CoconutKit provides a set of tools addressing many related issues.

### Containers

CoconutKit makes it easy to divide your application into independent, reusable view controllers, by providing **UIKit-like containers** for view controller composition and stacking. Combined with the usual UIKit containers, several built-in transition animations and the possibility to write custom transitions, you will be able to reorder screens and change how they are presented in a few keystrokes. Storyboard support included.

**image (view controller hierarchy & result)**

### Bindings

Were you longing for those **bindings** available when writing Mac applications? Well, using CoconutKit, simply associate a view with a key path, set a formatter if required, and you are done. CoconutKit takes care of the rest:

* Keeping model and view synchronized
* Formatting data before display
* Parsing user input
* Validating values

All this magic happens without the need for outlets, and **most of the time without even writing a single line of code**.

**image**

For screens containing a lot of text fields, CoconutKit also provides reliable automatic keyboard management.

### Declarative animations

Also say goodbye to the spaghetti code mess usually associated with animations. CoconutKit lets you **create animations in a declarative way**. These animations can be easily stored for later use, reversed, paused and resumed. Best of all, they work with Core Animation too!

**image**

### Localization

Localizing the interface of your application is usually tedious and requires a lot of boilerplate code. With CoconutKit, you can **localize labels and buttons directly in Interface Builder**, without the need for outlets.

**image**

You can also change the language of your application while it is running, for free!

## Compatibility

CoconutKit requires the most recent versions of Xcode and of the iOS SDK, currently:

* Xcode 6
* iOS 8 SDK

Deployment is supported for the two most recent major iOS versions, currently:

* iOS 7
* iOS 8

All architectures are supported:

* i386 and x86_64
* armv7, armv7s and arm64

CoconutKit can be used both from Objective-C or Swift files. It does not contain any private API method calls and is therefore App Store compliant.

## Installation

CoconutKit can either be installed with CocoaPods or as a compiled framework.

### Installation with CocoaPods

Add the following dependency to your `Podfile`

```ruby
pod 'CoconutKit', '<version>'
```

Then run `pod install` to update the dependencies.

For more information about CocoaPods and the `Podfile`, please refer to the [official documentation](http://guides.cocoapods.org/).

### Framework

Checkout CoconutKit source code from the command-line and update associated submodules:

```
$ git clone https://github.com/defagos/CoconutKit.git
$ cd CoconutKit
$ git submodule update --init
```

Open the `CoconutKit.xcworkspace` and run the `CoconutKit-staticframework` scheme. 

**image**

This produces a `.staticframework` package in the `Binaries` directory.

Add the `.staticframework` to your project and select the `CoconutKit.xcconfig` to setup the required compilation settings automatically. 

## Usage

A global `CoconutKit.h` header file is provided. You can individually import public header files if you prefer, though.

### Use in Objective-C

Import the global header file using

```objective-c
#import "CoconutKit.h"                            // Installation with CocoaPods
#import <CoconutKit/CoconutKit.h>                 // Framework
```

You can similarly import individual files

```objective-c
#import "HLSStackController.h"                    // Installation with CocoaPods
#import <CoconutKit/HLSStackController.h>         // Framework
```

It you use the framework, it is also possible to import the CoconutKit module itself where needed:

```objective-c
@import CoconutKit
```

### Use in Swift

If you installed CoconutKit with CocoaPods, import the global header from a bridging header:

```objective-c
#import "CoconutKit.h"                            // Installation with CocoaPods
```

If you use the framework, the CoconutKit module can be imported where needed:

```swift
import CoconutKit
```

## Demo project

The CoconutKit workspace contains a demo project, also used for development. Simply run the `CoconutKit-dev` scheme.

## Documentation

Head over to the [wiki](https://github.com/defagos/CoconutKit/wiki) for documentation, tutorials and guidelines for contributors. If you want to learn more about a component in particular, have a look at the corresponding header documentation.

## License

CoconutKit is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
















