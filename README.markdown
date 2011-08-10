### What is CoconutKit?

CoconutKit is a library of high-quality iOS components written at [hortis le studio](http://www.hortis.ch/) and in my spare time. It includes several tools for dealing with view controllers, multi-threading, view animations, as well as some new controls and various utility classes. CoconutKit is distributed under a permissive [MIT license](http://www.opensource.org/licenses/mit-license.php), which means you can freely use it in your own projects (commercial or not).

### Where can I download CoconutKit?
You can download CoconutKit from [my github page](https://github.com/defagos), both in binary and source forms.

### What can I find in CoconutKit?
CoconutKit provides your with several kinds of classes covering various aspects of iOS development:

* High-quality view controller containers (view controller embedding, view controller stacking) with several transition animations
* View controllers for web browsing and for easier table view search management
* Multi-threaded task management, including task grouping, cancelation, progress status, task dependencies and remaining time estimation
* New controls (text field moving automatically with the keyboard, new kind of segmented control)
* Various extensions to Cocoa and UIKit classes (date and time, collections, notifications, etc.)
* Classes for common UI tasks (keyboard management, interface locking)
* Classes for single-line table view cell and view instantiations
* Classes for creating complex view animations made of several sub-animations
* Lightweight logger, assertions, float comparisons, etc.
* ... and more!
* ... and even more to come!

### How should I use CoconutKit?
The easiest and recommended way to use CoconutKit is to use the latest tagged binary package available for download. Simply drag and drop the .staticframework package onto your project (adding references to it), remove the language files you do not use from your project, include the CoconutKit.h header file in your project .pch file, and you are ready to go! If you enjoyed the library, [hortis](http://www.hortis.ch/) and I would sincerely love being credited somewhere in your application, for example on some about page. Thanks for your support!

### With which versions of iOS is CoconutKit compatible?
CoconutKit should be compatible with iOS 3.2 and later (this might change as old OS versions get deprecated), both for iPhone and iPad projects. Please file a bug if you discover it is not the case.

### How can I learn using CoconutKit?
Learning how to use CoconutKit components always starts with header documentation (I try to keep documentation close to the code). All you need to know should be written there. After you have read this documentation, have a look at the demos to see how the component is used in a concrete case.

### Why have you released CoconutKit?
My company, [hortis](http://www.hortis.ch/), has a long tradition of open source development. This is one of the major reasons why I  started to work for its entity devoted to mobile development, hortis le studio. After months of hard work, I felt the library was getting mature enough to deserve being published. I sincerely hope people will find this work interesting and start contributing code or ideas, so that a fruitful collaboration process can arise.

### Why should I use CoconutKit?
When designing components, I strongly emphasize on clean and documented interfaces, as well as on code quality. My goal is to create components that are easy to use, reliable, and which do what they claim they do, without nasty surprises. You should never have to look at a component implementation to know how it works, this should be obvious just by looking at its interface. I also strive to avoid components that leak or crash. If those are qualities you love to find in libraries, then you should start using CoconutKit now! Moreover, CoconutKit will never use any private API and will therefore always be AppStore friendly.

### Can I contribute?
You can, and you are strongly encouraged to. Use github pull requests to submit your improvements and bug fixes. You can submit everything you want, documentation and comment fixes included! Everything that tends to increase code quality is always warmly welcome.

There are some requirements when contributing, though:

* Code style guidelines are not formalized anywhere, but try to stay as close as possible to the style I use. This saves me some work when merging pull requests. IMHO, having a consistent way of organizing and writing source code makes it easier to read, write and maintain
* Read my [article about the memory management techniques](http://subjective-objective-c.blogspot.com/2011/04/use-objective-c-properties-to-manage.html) I use, and apply the same rules
* Use of private APIs is strictly forbidden
* Development and demo projects are also included. Both are almost the same, except that the demo project uses the library in its binary form. New components should be written using the development project, so that an example with good code coverage is automatically available when your new component is ready. The demo project should then be updated accordingly

### How can write code for CoconutKit?
After checking out the code, open the Xcode 4 workspace. Three projects have been created:

* CoconutKit: The project used to build the CoconutKit static library (see below)
* CoconutKit-demo: The project used to test the CoconutKit .staticframework package. I use it to check that no link issues arise when the library is packaged as .staticframework. If you contribute to the project, I will usually do this for you
* CoconutKit-dev: The project used when working on CoconutKit. This project is an almost empty shell referencing files from both the CoconutKit and CoconutKit-demo projects

Use the CoconutKit-dev project to easily write and test code. When you are done, update the CoconutKit and CoconutKit-demo to mirror the changes you made to the project file list. Any new public header file must be added to CoconutKit-dev pch file, as well as to the publicHeaders.txt file located in the CoconutKit-dev directory. Source files with link issues (source files containing categories only, or meant to be used in Interface Builder) must also be added to the bootstrap.txt file. Please refer to the make-fmwk.sh documentation for more information.

If you really do want to check that no link issues arise with the library when it is packaged as .staticframework, here is roughly how:

* Build the CoconutKit .staticframework packages (see below)
* Add the release package to the CoconutKit-demo project, as any project using the library would do
* Test your code

### How can I build CoconutKit?
CoconutKit is meant to be built into a .staticframework package using the [make-fmwk command](https://github.com/defagos/make-fmwk). After having installed the command somewhere in your path, run it from the CoconutKit directory, as follows:

* make-fmwk.sh -o <output_directory> -u <version> Release
* make-fmwk.sh -o <output_directory> -u <version> Debug
    
e.g.

* make-fmwk.sh -o ~/MyBuilds -u 1.0 Release
* make-fmwk.sh -o ~/MyBuilds -u 1.0 Debug

### Why are all classes prefixed with HLS?
HLS stands for hortis le studio.

### Acknowledgements
I really would like to thank my company for having allowed me to publish this work, as well as all my colleagues which have contributed and given me invaluable advice. This work is yours as well!

HLSWebViewController was kindly contributed by [0xced](http://0xced.blogspot.com/).

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
