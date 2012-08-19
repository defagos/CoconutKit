//
//  NSBundle+HLSDynamicLocalization.m
//  CoconutKit
//
//  Created by Cédric Luthi on 08/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSBundle+HLSDynamicLocalization.h"

#import <objc/runtime.h>
#import "HLSLogger.h"

NSString * const HLSPreferredLocalizationDefaultsKey = @"HLSPreferredLocalization";
NSString * const HLSCurrentLocalizationDidChangeNotification = @"HLSCurrentLocalizationDidChangeNotification";

NSString *HLSLanguageForLocalization(NSString *localization)
{
    NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier:localization] autorelease];
    return [[locale displayNameForKey:NSLocaleLanguageCode value:localization] capitalizedString];
}

NSString *HLSLocalizedStringFromUIKit(NSString *key)
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.UIKit"];
    if (! bundle) {
        HLSLoggerWarn(@"UIKit bundle not found; searching in main bundle instead");
        bundle = [NSBundle mainBundle];
    }
    
    // We use an explicit constant string for missing localizations since otherwise the localization key itself would 
    // be returned by the localizedStringForKey:value:table method
    static NSString * const kMissingLocalizedString = @"NSBundle_HLSDynamicLocalization_missing";
    NSString *localizedString = [bundle localizedStringForKey:key
                                                        value:kMissingLocalizedString
                                                        table:nil];
    
    // Use the localization key as text if missing
    if ([localizedString isEqualToString:kMissingLocalizedString]) {
        HLSLoggerWarn(@"Missing localization for key %@", key);
        localizedString = key;
    }
    
    return localizedString;
}

@implementation NSBundle (HLSDynamicLocalization)

static NSString *currentLocalization = nil;

static void setDefaultLocalization(void);
static void exchangeNSBundleInstanceMethod(SEL originalSelector);
static void initialize(void);

static void setDefaultLocalization(void)
{
    [currentLocalization release];
    
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
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *preferredLocalization = [[NSUserDefaults standardUserDefaults] stringForKey:HLSPreferredLocalizationDefaultsKey];
    if (preferredLocalization) {
        [NSBundle setLocalization:preferredLocalization];
    }
    
    [pool drain];
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
    
    NSArray *mainBundleLocalizations = [[NSBundle mainBundle] localizations];
    NSString *previousLocalization = [currentLocalization copy];
    
    if (localization == nil || ![mainBundleLocalizations containsObject:localization]) {
        setDefaultLocalization();
    }
    else {
        if (currentLocalization == localization) {
            [previousLocalization release];
            return;
        }
        
        [currentLocalization release];
        currentLocalization = [localization copy];
    }
    
    if (![currentLocalization isEqualToString:previousLocalization]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HLSCurrentLocalizationDidChangeNotification object:self];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:currentLocalization forKey:HLSPreferredLocalizationDefaultsKey];
    [previousLocalization release];
}

// MARK: - Localized strings

- (NSString *)dynamic_localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName;
{
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
    
    if (!currentLocalization || !lprojFound) {
        return [self dynamic_localizedStringForKey:key value:value table:tableName];
    }
    
    if (!key) {
        return value;
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
        return [value length] > 0 ? value : key;
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
