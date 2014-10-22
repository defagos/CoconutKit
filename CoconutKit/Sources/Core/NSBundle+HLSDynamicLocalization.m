//
//  NSBundle+HLSDynamicLocalization.m
//  CoconutKit
//
//  Created by Cédric Luthi on 08/15/11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "NSBundle+HLSDynamicLocalization.h"

#import <objc/runtime.h>
#import "HLSLogger.h"

NSString * const HLSCurrentLocalizationDidChangeNotification = @"HLSCurrentLocalizationDidChangeNotification";
NSString * const HLSMissingLocalization = @"HLSMissingLocalization";

static NSString * const HLSPreferredLocalizationDefaultsKey = @"HLSPreferredLocalization";

static NSString *currentLocalization = nil;

static void setDefaultLocalization(void);
static void exchangeNSBundleInstanceMethod(SEL originalSelector);
static void initialize(void);

NSString *HLSLanguageForLocalization(NSString *localization)
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localization];
    return [[locale displayNameForKey:NSLocaleLanguageCode value:localization] capitalizedString];
}

NSString *HLSLocalizedStringFromBundle(NSString *key, NSBundle *bundle)
{
    if (! bundle) {
        bundle = [NSBundle mainBundle];
    }
    
    NSString *localizedString = [bundle localizedStringForKey:key
                                                        value:HLSMissingLocalization
                                                        table:nil];    
    return localizedString;
}

NSString *HLSLocalizedStringFromUIKit(NSString *key)
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
    return HLSLocalizedStringFromBundle(key, bundle);
}

NSString *HLSLocalizedDescriptionForCFNetworkError(NSInteger errorCode)
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *key = [NSString stringWithFormat:@"Err%@", @(errorCode)];
    return HLSLocalizedStringFromBundle(key, bundle);
}

@implementation NSBundle (HLSDynamicLocalization)

static void setDefaultLocalization(void)
{
    NSArray *mainBundleLocalizations = [[NSBundle mainBundle] localizations];
    NSArray *preferredLocalizations = [NSBundle preferredLocalizationsFromArray:mainBundleLocalizations];
    if ([preferredLocalizations count] > 0) {
        currentLocalization = [[preferredLocalizations objectAtIndex:0] copy];
    }
    else {
        currentLocalization = [[[NSBundle mainBundle] developmentLocalization] copy];
    }
}

+ (void)load
{
    @autoreleasepool {
        NSString *preferredLocalization = [[NSUserDefaults standardUserDefaults] stringForKey:HLSPreferredLocalizationDefaultsKey];
        if (preferredLocalization) {
            [NSBundle setLocalization:preferredLocalization];
        }  
    }
}

+ (NSString *)localization
{
    if (!currentLocalization) {
        setDefaultLocalization();
    }
    return currentLocalization;
}

+ (void)setLocalization:(NSString *)localization
{
    initialize();
    
    NSString *previousLocalization = [currentLocalization copy];
    
    if (!localization) {
        setDefaultLocalization();
    }
    else {
        if (currentLocalization == localization) {
            return;
        }
        
        currentLocalization = [localization copy];
    }
    
    if (![currentLocalization isEqualToString:previousLocalization]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HLSCurrentLocalizationDidChangeNotification object:self];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:currentLocalization forKey:HLSPreferredLocalizationDefaultsKey];
}

// MARK: - Localized strings

- (NSString *)dynamic_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;
{
    // See -localizedStringForKey:value:table: return value documentation
    NSString *notFoundValue = [value length] > 0 ? value : key;
    
    if (!currentLocalization || !key) {    
        return notFoundValue;
    }
    
    NSString *localizationName = currentLocalization;
    BOOL lprojFound = YES;
    NSString *lprojPath = [[[self bundlePath] stringByAppendingPathComponent:currentLocalization] stringByAppendingPathExtension:@"lproj"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:lprojPath]) {
        // Handle old style English.lproj / French.lproj / German.lproj ...
        static NSLocale *enLocale = nil;
        if (!enLocale) {
            enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
        }
        NSString *displayLocalizationName = [enLocale displayNameForKey:NSLocaleLanguageCode value:currentLocalization];
        lprojPath = [[[self bundlePath] stringByAppendingPathComponent:displayLocalizationName] stringByAppendingPathExtension:@"lproj"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:lprojPath]) {
            localizationName = displayLocalizationName;
        }
        else {
            lprojFound = NO;
        }
    }
    
    if (!lprojFound) {
        return notFoundValue;
    }
    
    if ([tableName length] == 0) {
        tableName = @"Localizable";
    }
    
    NSString *tablePath = [self pathForResource:tableName ofType:@"strings" inDirectory:nil forLocalization:localizationName];
    NSDictionary *table = [NSDictionary dictionaryWithContentsOfFile:tablePath];
    
    NSString *localizedString = [table objectForKey:key];
    
    if (!localizedString) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"NSShowNonLocalizedStrings"]) {
            HLSLoggerWarn(@"Localizable string \"%@\" not found in strings table \"%@\" of bundle %@", key, tableName, self);
            return [key uppercaseString];
        }
        return notFoundValue;
    }
    
    return localizedString;
}

// MARK: - URLs

- (NSURL *)dynamic_URLForResource:(NSString *)name withExtension:(NSString *)extension subdirectory:(NSString *)subpath
{
    return [self URLForResource:name withExtension:extension subdirectory:subpath localization:currentLocalization];
}

- (NSURL *)dynamic_URLForResource:(NSString *)name withExtension:(NSString *)extension
{
    // -[NSBundle URLForResource:withExtension:] implementation does *not* call -[NSBundle URLForResource:withExtension:subdirectory:]
    return [self URLForResource:name withExtension:extension subdirectory:nil];
}

- (NSArray *)dynamic_URLsForResourcesWithExtension:(NSString *)extension subdirectory:(NSString *)subpath
{
    return [self URLsForResourcesWithExtension:extension subdirectory:subpath localization:currentLocalization];
}

// MARK: - Paths

- (NSString *)dynamic_pathForResource:(NSString *)name ofType:(NSString *)extension inDirectory:(NSString *)subpath
{
    return [self pathForResource:name ofType:extension inDirectory:subpath forLocalization:currentLocalization];
}

- (NSString *)dynamic_pathForResource:(NSString *)name ofType:(NSString *)extension
{
    // -[NSBundle pathForResource:ofType:] implementation does *not* call -[NSBundle pathForResource:ofType:inDirectory:]
    return [self pathForResource:name ofType:extension inDirectory:nil];
}

- (NSArray *)dynamic_pathsForResourcesOfType:(NSString *)extension inDirectory:(NSString *)subpath
{
    return [self pathsForResourcesOfType:extension inDirectory:subpath forLocalization:currentLocalization];
}

// MARK: - Swizzling

static void exchangeNSBundleInstanceMethod(SEL originalSelector)
{
    SEL dynamicSelector = NSSelectorFromString([@"dynamic_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
    Method originalMethod = class_getInstanceMethod([NSBundle class], originalSelector);
    Method dynamicMethod = class_getInstanceMethod([NSBundle class], dynamicSelector);
    if (!originalMethod || !dynamicMethod) {
        if (!originalMethod) {
            HLSLoggerError(@"NSBundle original '%@' method not found.", NSStringFromSelector(originalSelector));
        }
        if (!dynamicMethod) {
            HLSLoggerError(@"NSBundle dynamic '%@' method not found.", NSStringFromSelector(dynamicSelector));
        }
        return;
    }
    method_exchangeImplementations(originalMethod, dynamicMethod);
}

static void initialize(void)
{
    static BOOL initialized = NO;
    if (initialized) {
        return;
    }
    initialized = YES;
    
    exchangeNSBundleInstanceMethod(@selector(localizedStringForKey:value:table:));
    
    exchangeNSBundleInstanceMethod(@selector(URLForResource:withExtension:));
    exchangeNSBundleInstanceMethod(@selector(URLForResource:withExtension:subdirectory:));
    exchangeNSBundleInstanceMethod(@selector(URLsForResourcesWithExtension:subdirectory:));
    
    exchangeNSBundleInstanceMethod(@selector(pathForResource:ofType:));
    exchangeNSBundleInstanceMethod(@selector(pathForResource:ofType:inDirectory:));
    exchangeNSBundleInstanceMethod(@selector(pathsForResourcesOfType:inDirectory:));
}

@end
