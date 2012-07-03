//
//  HLSApplicationPreLoader.m
//  CoconutKit
//
//  Created by Samuel Défago on 02.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSApplicationPreLoader.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"

// Keys for associated objects
static void *s_applicationPreLoaderKey = &s_applicationPreLoaderKey;

// Original implementations of the application:didFinishLaunchingWithOptions: methods we swizzle. We need to swizzle
// those methods for each class which conforms to the UIApplicationDelegate protocol, thus the need for a mapping 
// between class names and swizzled implementations
CFMutableDictionaryRef s_classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap = NULL;

// Swizzled method implementations
static BOOL swizzled_UIApplicationDelegate__application_didFinishLaunchingWithOptions(id self, SEL _cmd, UIApplication *application, NSDictionary *launchOptions);

@interface HLSApplicationPreLoader ()

@property (nonatomic, assign) UIApplication *application;           // weak ref since retained by the application

@end

@implementation HLSApplicationPreLoader

#pragma mark Class methods

+ (void)load
{
    s_classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap = CFDictionaryCreateMutable(NULL, 
                                                                                                    0,
                                                                                                    &kCFTypeDictionaryKeyCallBacks /* store CFString keys */,
                                                                                                    NULL /* store raw pointers as values. No memory management */);
    
    // Loop over all classes. Find the ones which implement the UIApplicationDelegate protocol and swizzle their application:didFinishLaunchingWithOptions: method
    // so that we can add an HLSApplicationPreLoader 
    unsigned int numberOfClasses = 0;
    Class *classes = objc_copyClassList(&numberOfClasses);
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];
        // TODO: Use hls_class_conformsToProtocol after merge with feature/url-connection
        if (class_conformsToProtocol(class, @protocol(UIApplicationDelegate))) {
            CFStringRef className = CFStringCreateWithCString(kCFAllocatorDefault, class_getName(class), kCFStringEncodingUTF8);
            IMP UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp = HLSSwizzleSelector(class, 
                                                                                                          @selector(application:didFinishLaunchingWithOptions:), 
                                                                                                          (IMP)swizzled_UIApplicationDelegate__application_didFinishLaunchingWithOptions);
            CFDictionarySetValue(s_classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap, className, UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp);
            CFRelease(className);
        }
    }
    free(classes);
}

#pragma mark Object creation and destruction

- (id)initWithApplication:(UIApplication *)application
{
    if ((self = [super init])) {
        self.application = application;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.application = nil;

    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize application = _application;

#pragma mark Pre-loading

- (void)preload
{
	// To avoid the delay which occurs when loading a UIWebView for the first time, we display one as soon as possible
    // (out of screen bounds). It seems that loading a large web view (here with the application frame size) is more 
    // effective
    CGRect applicationFrame = [UIScreen mainScreen].applicationFrame;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(applicationFrame), 
                                                                     CGRectGetMaxY(applicationFrame), 
                                                                     CGRectGetWidth(applicationFrame), 
                                                                     CGRectGetHeight(applicationFrame))];
    webView.delegate = self;
    
    UIWindow *keyWindow = self.application.keyWindow;
    if (keyWindow) {
        [keyWindow addSubview:webView];
        
        // No need to load anything meaningful
        [webView loadHTMLString:@"" baseURL:nil];
    }
    else {
        HLSLoggerWarn(@"No key window found. Cannot pre-load UIWebView");
    }    
}

#pragma mark UIWebViewDelegate protocol implementation

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // The web view is not needed anymore
    [webView removeFromSuperview];
    [webView release];
}

@end

#pragma mark Swizzled method implementations

static BOOL swizzled_UIApplicationDelegate__application_didFinishLaunchingWithOptions(id self, SEL _cmd, UIApplication *application, NSDictionary *launchOptions)
{
    // Get the original implementation and call it
    Class class = object_getClass(self);
    CFStringRef className = CFStringCreateWithCString(kCFAllocatorDefault, class_getName(class), kCFStringEncodingUTF8);
    BOOL (*UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp)(id, SEL, UIApplication *, NSDictionary *) = (BOOL (*)(id, SEL, id, id))CFDictionaryGetValue(s_classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap, className);
    CFRelease(className);
    
    if (! (*UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp)(self, _cmd, application, launchOptions)) {
        return NO;
    }
    
    // Install the preloader
    HLSApplicationPreLoader *applicationPreLoader = [[[HLSApplicationPreLoader alloc] initWithApplication:application] autorelease];
    objc_setAssociatedObject(self, s_applicationPreLoaderKey, applicationPreLoader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [applicationPreLoader preload];
    
    return YES;
}
