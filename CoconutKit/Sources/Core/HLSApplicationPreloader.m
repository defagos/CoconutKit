//
//  HLSApplicationPreloader.m
//  CoconutKit
//
//  Created by Samuel Défago on 02.07.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSApplicationPreloader.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"

// Keys for associated objects
static void *s_applicationPreloaderKey = &s_applicationPreloaderKey;

// Original implementations of the application:didFinishLaunchingWithOptions: methods we swizzle. We need to swizzle
// those methods for each class which conforms to the UIApplicationDelegate protocol, thus the need for a mapping 
// between class names and swizzled implementations
NSDictionary *s_classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap = nil;

// Swizzled method implementations
static BOOL swizzled_UIApplicationDelegate__application_didFinishLaunchingWithOptions(id self, SEL _cmd, UIApplication *application, NSDictionary *launchOptions);

@interface HLSApplicationPreloader ()

@property (nonatomic, assign) UIApplication *application;           // weak ref since retained by the application

@end

@interface HLSApplicationPreloader ()

- (id)initWithApplication:(UIApplication *)application;

- (void)preload;

@end

@implementation HLSApplicationPreloader

#pragma mark Class methods

+ (void)enable
{
    static BOOL s_enabled = NO;
    if (s_enabled) {
        HLSLoggerInfo(@"Application preloading already enabled");
        return;
    }
    
    NSMutableDictionary *classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap = [NSMutableDictionary dictionary];
    
    // Loop over all classes. Find the ones which implement the UIApplicationDelegate protocol and swizzle their application:didFinishLaunchingWithOptions: method
    // so that we can add an HLSApplicationPreloader 
    unsigned int numberOfClasses = 0;
    Class *classes = objc_copyClassList(&numberOfClasses);
    for (unsigned int i = 0; i < numberOfClasses; ++i) {
        Class class = classes[i];
        // TODO: Use hls_class_conformsToProtocol after merge with feature/url-connection
        if (class_conformsToProtocol(class, @protocol(UIApplicationDelegate))) {
            NSString *className = [NSString stringWithCString:class_getName(class) encoding:NSUTF8StringEncoding];
            IMP UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp = HLSSwizzleSelector(class, 
                                                                                                          @selector(application:didFinishLaunchingWithOptions:), 
                                                                                                          (IMP)swizzled_UIApplicationDelegate__application_didFinishLaunchingWithOptions);
            
            // If not implemented (which might happen if the application is initialized using a nib only, i.e. if the root view controller is set in
            // the application nib), inject a method
            if (! UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp) {
                class_addMethod(class, 
                                @selector(application:didFinishLaunchingWithOptions:), 
                                (IMP)swizzled_UIApplicationDelegate__application_didFinishLaunchingWithOptions, 
                                "c@:@@");
            }
            [classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap setObject:[NSValue valueWithPointer:UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp]
                                                                                  forKey:className];
        }
    }
    free(classes);
    
    s_classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap = [[NSDictionary dictionaryWithDictionary:classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap] retain];
    
    s_enabled = YES;
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
        
        // We do not need to load anything meaningful
        [webView loadHTMLString:@"" baseURL:nil];
    }
    else {
        HLSLoggerWarn(@"No key window found. Cannot preload UIWebView. To fix this issue, your application delegate must "
                      "implement the -application:didFinishLaunchingWithOptions: method to set the key window, either by "
                      "calling -makeKeyAndVisible or -makeKeyWindow");
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
    // Get the original implementation and call it (if any)
    NSString *className = [NSString stringWithCString:class_getName(object_getClass(self)) encoding:NSUTF8StringEncoding];
    BOOL (*UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp)(id, SEL, UIApplication *, NSDictionary *) = (BOOL (*)(id, SEL, id, id))[[s_classNameToSwizzledApplicationDidFinishLaunchingWithOptionsImpMap objectForKey:className] pointerValue];
    
    if (UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp) {
        if (! (*UIApplicationDelegate__application_didFinishLaunchingWithOptions_Imp)(self, _cmd, application, launchOptions)) {
            return NO;
        }
    }
    
    // Install the preloader
    HLSApplicationPreloader *applicationPreloader = [[[HLSApplicationPreloader alloc] initWithApplication:application] autorelease];
    objc_setAssociatedObject(self, s_applicationPreloaderKey, applicationPreloader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [applicationPreloader preload];
    
    return YES;
}
