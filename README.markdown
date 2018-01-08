<p align="center"><img src="README-images/coconutkit_header.png"/></p>

CoconutKit is a **productivity framework for iOS**, crafted with love and focusing on ease of use. It provides a convenient, Cocoa-friendly toolbox to help you efficiently write robust and polished native applications.

| Build status | Latest version | Integration | License |
|--------------|----------------|-------------|---------|
| [![Build Status](https://img.shields.io/travis/defagos/CoconutKit/master.svg)](https://travis-ci.org/defagos/CoconutKit) | [![Latest version](https://img.shields.io/github/tag/defagos/CoconutKit.svg)](https://github.com/defagos/CoconutKit) | [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage) | ![License](https://img.shields.io/github/license/defagos/CoconutKit.svg) |

_Logo by Kilian Amendola ([@kilianamendola](https://twitter.com/kilianamendola))_

[![Donate to author](https://www.paypalobjects.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=3V35ZXWYXGAYG&lc=CH&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHosted)

## About

Unlike most libraries which focus on a specific task, like networking or image processing, CoconutKit addresses **developer productivity in general**. As an iOS developer, you namely face the same issues on each project you work on:

* Changes due to fast-paced iterative development, stakeholder indecision or design modifications
* Presenting data and gathering user input
* Localization

Most of the code related to these issues is written in view controllers, and clutters their implementation with redundant, boring boilerplate code.

CoconutKit provides a set of tools to **tackle the problem of fat view controller** classes by:

* Helping your **eliminate boilerplate code** and decluttering view controller implementations
* Making it easier to **decompose your application into smaller view controllers** with well-defined responsibilities
* Letting you **assemble and reorganize view controllers** effortlessly

Unlike approaches which apply patterns like [MVVM](http://www.objc.io/issue-13/mvvm.html), CoconutKit does not require any major changes to your code or to the way you work or think. You only need the good ol' language and patterns you are comfortable with.

## Features

The following is a brief introduction to various tools and component available in CoconutKit. More information is available on the [wiki](https://github.com/defagos/CoconutKit/wiki).

### Containers

CoconutKit makes it easy to divide your application into independent, reusable view controllers, by providing **UIKit-like containers** for view controller composition and stacking. Combined with the usual UIKit containers, several built-in transition animations and the possibility to write custom transitions, you will be able to reorder screens and change how they are presented in a few keystrokes. Storyboard support included.

<p align="center"><img src="README-images/containers.jpg"/></p>
<p align="center"><img src="README-images/containers.gif"/></p>

### Bindings

Were you longing for those **bindings** available when [writing Mac applications](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaBindings/Concepts/WhatAreBindings.html)? Well, now simply associate a view with a key path, set a formatter if required, and you are done. CoconutKit takes care of the rest:

* Keeping model and view synchronized
* Formatting data before display
* Parsing user input
* Validating values

All this magic happens without the need for outlets, and most of the time **without even writing a single line of code**. Most UIKit controls can be used with bindings, and you can add support for bindings to your own controls as well.

<p align="center"><img src="README-images/bindings.jpg"/></p>
<p align="center"><img src="README-images/bindings.gif"/></p>

For screens containing a lot of text fields, CoconutKit also provides reliable automatic keyboard management, so that the keyboard never gets in the way.

### Declarative animations

Also say goodbye to the spaghetti code mess usually associated with animations. CoconutKit lets you **create animations in a declarative way**. These animations can be easily stored for later use, reversed, repeated, paused, resumed and canceled. Best of all, they can involve as many views as you want, and work with Core Animation too!

Here is for example how a pulse animation could be defined:

```objective-c
// Increase size while decreasing opacity
HLSLayerAnimation *pulseLayerAnimation1 = [HLSLayerAnimation animation];
[pulseLayerAnimation1 scaleWithXFactor:2.f yFactor:2.f];
[pulseLayerAnimation1 addToOpacity:-1.f];
HLSLayerAnimationStep *pulseLayerAnimationStep1 = [HLSLayerAnimationStep animationStep];
pulseLayerAnimationStep1.duration = 0.8;
pulseLayerAnimationStep1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
[pulseLayerAnimationStep1 addLayerAnimation:pulseLayerAnimation1 forView:view];
    
// Wait
HLSLayerAnimationStep *pulseLayerAnimationStep2 = [HLSLayerAnimationStep animationStep];
pulseLayerAnimationStep2.duration = 0.5;

// Instantly bring back the view to its initial state
HLSLayerAnimation *pulseLayerAnimation3 = [HLSLayerAnimation animation];
[pulseLayerAnimation3 scaleWithXFactor:1.f / 2.f yFactor:1.f / 2.f];
[pulseLayerAnimation3 addToOpacity:1.f];
HLSLayerAnimationStep *pulseLayerAnimationStep3 = [HLSLayerAnimationStep animationStep];
pulseLayerAnimationStep3.duration = 0.;
[pulseLayerAnimationStep3 addLayerAnimation:pulseLayerAnimation3 forView:view];

// Create and repeat the animation forever
HLSAnimation *pulseAnimation = [HLSAnimation animationWithAnimationSteps:@[pulseLayerAnimationStep1, pulseLayerAnimationStep2, pulseLayerAnimationStep3]];
[pulseAnimation playWithRepeatCount:NSUIntegerMax animated:YES];
```

<p align="center"><img src="README-images/animations.gif"/></p>

### Localization

Localizing the interface of your application is usually tedious and requires a lot of boilerplate code. With CoconutKit, **localize labels and buttons directly in Interface Builder**, without the need for outlets, by using a prefix followed by your localization key. Several prefixes are available to automatically convert localized strings to their uppercase, lowercase or capitalized counterparts.

<p align="center"><img src="README-images/localization.jpg" width="512"/></p>

You can also change the language of your application with a single method call.

<p align="center"><img src="README-images/localization.gif" width="512"/></p>

### Easy view instantiation from nib files

To help you further decompose your view hierarchies, CoconutKit provides easy view instantiation from nib files. This way, you can design views separately, and simply aggregate them directly in Interface Builder.

<p align="center"><img src="README-images/nib_views.jpg"/></p>

Easy table view cell instantiation is available as well.

### Web browser

A web browser is available when you have to display some web site within your application.

```objective-c
NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://about.me/defagos"]];
HLSWebViewController *webViewController = [[HLSWebViewController alloc] initWithRequest:request];
UINavigationController *webNavigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
[self presentViewController:webNavigationController animated:YES completion:nil];
```
<p align="center"><img src="README-images/web_browser.jpg"/></p>

### Slideshow

Ever wanted to present images or backgrounds as an animated gallery? CoconutKit slideshow makes it possible in a snap. You can choose among several transition animations, ranging from the simple cross-dissolve to Ken Burns random zooming and panning.

<p align="center"><img src="README-images/slideshow.gif" width="256"/></p>

### Cursor

Tired of segmented controls? Then use CoconutKit cursor, which can be customized to match your needs.

<p align="center"><img src="README-images/cursor.gif"/></p>

### Parallax scrolling

Add parallax scrolling to your application by synchronizing scroll views with a single method call.

```objective-c
[treesScrollView synchronizeWithScrollViews:@[skyScrollView, mountainsScrollView, grassScrollView] bounces:NO];
```

<p align="center"><img src="README-images/parallax.gif"/></p>

### Simple Core Data management

To avoid clutter ususally associated with Core Data projects, you can create all necessary contexts and stores with a single model manager instantiation, pushed to make it the current one:

```objective-c
HLSModelManager *modelManager = [HLSModelManager SQLiteManagerWithModelFileName:@"Company"
                                                                       inBundle:nil
                                                                  configuration:nil 
                                                                 storeDirectory:HLSApplicationDocumentDirectoryPath()
                                                                    fileManager:nil
                                                                        options:HLSModelManagerLightweightMigrationOptions];
[HLSModelManager pushModelManager:modelManager];
```

You then do not need to play with Core Data contexts anymore. Operations are applied on the topmost model manager:

```objective-c
Employee *employee = [Employee insert];
employee.firstName = @"John";
employee.lastName = @"Doe";

NSError *error = nil;
if (! [HLSModelManager saveCurrentModelContext:&error]) {
    [HLSModelManager rollbackCurrentModelContext];
    
    // Deal with the error
}
```

Combined with [mogenerator](http://rentzsch.github.io/mogenerator/) for model file generation and CoconutKit bindings for data display and edition, creating a Core Data powered application is easy as pie.

## Compatibility

CoconutKit requires the most recent versions of Xcode and of the iOS SDK, currently:

* Xcode 9
* iOS 11 SDK

Deployment is supported for the three most recent major iOS versions, currently:

* iOS 9.x
* iOS 10.x
* iOS 11.x

All architectures are supported:

* i386 and x86_64
* armv7, armv7s and arm64

and bitcode as well.

Visual components are either device independent or support iPhone 4", 4.7", 5.5" and iPhone X screen sizes, as well as iPads.

CoconutKit can be used both from Objective-C or Swift files. It does not contain any private API method calls and is therefore App Store compliant.

## Installation

CoconutKit can be added using [Carthage](https://github.com/Carthage/Carthage).

Add CoconutKit as dependency in your `Cartfile`:

```
github "defagos/CoconutKit" == <version>
```

Then run `carthage update` to update the dependencies. You will need to manually add the `.framework` generated in the `Carthage/Build/iOS` folder to your projet. Refer to the [official documentation](https://github.com/Carthage/Carthage) for more information.

### Remark

CocoaPods is not supported anymore.

## Usage

A global `CoconutKit.h` header file is provided. You can of course individually import public header files if you prefer, though.

### Usage from Objective-C source files

Import the global header file using

```objective-c
#import <CoconutKit/CoconutKit.h>
```

You can similarly import individual files, e.g.

```objective-c
#import <CoconutKit/HLSStackController.h>
```

It might be easier to import the CoconutKit module itself where needed, though:

```objective-c
@import CoconutKit;
```

### Usage from Swift source files

Import the CoconutKit module where needed:

```swift
import CoconutKit
```

## Demo project

The CoconutKit workspace contains a demo project, also used for development. Simply run the `CoconutKit-demo` scheme.

## Documentation

Head over to the [wiki](https://github.com/defagos/CoconutKit/wiki) for documentation, tutorials and guidelines for contributors. If you want to learn more about a component in particular, have a look at the corresponding header documentation.

## Templates

A set of Xcode templates is provided to make CoconutKit file creation (and Objective-C file creation in general) easier. Those templates are available in the `Templates` directory and must be copied to `~/Library/Developer/Xcode/Templates/File Templates`.

## Contact

[Samuel Défago](https://github.com/defagos) ([@defagos](https://twitter.com/defagos))

## License

CoconutKit is available under the MIT license. See the [LICENSE](LICENSE) file for more information.
















