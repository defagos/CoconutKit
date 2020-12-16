//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Notification sent when the localization is changed at runtime
 */
OBJC_EXPORT NSString * const HLSCurrentLocalizationDidChangeNotification;

/**
 * This constant is returned when a localized string could not be found
 */
OBJC_EXPORT NSString * const HLSMissingLocalization;

/**
 * Return the language for a localization, nil if not found
 *
 * For example:
 *   HLSLanguageForLocalization(@"de") returns @"Deutsch"
 *   HLSLanguageForLocalization(@"en") returns @"English"
 */
OBJC_EXPORT NSString * __nullable HLSLanguageForLocalization(NSString * __nullable localization);

/**
 * Return a localized string from the specified bundle (if the bundle is nil, then
 * the main bundle is searched)
 *
 * If no match is found, return HLSMissingLocalization
 */
OBJC_EXPORT NSString *HLSLocalizedStringFromBundle(NSString * __nullable key, NSBundle * __nullable bundle);

/**
 * Return the localized description matching an error code
 *
 * If no match is found, return HLSMissingLocalization
 */
OBJC_EXPORT NSString *HLSLocalizedDescriptionForCFNetworkError(NSInteger errorCode);

/**
 * This category makes it possible to change the application language at runtime without leaving the application. 
 * Changes are identified by a HLSCurrentLocalizationDidChangeNotification notification being posted. In order 
 * to easily support the dynamic localization feature in your application, you should use HLSViewController as
 * base class for your view controllers and override the -localize method (see HLSViewController.h for more
 * information)
 *
 * Setting the current localization affects the following instance methods of NSBundle:
 *   - localizedStringForKey:value:table:, i.e. also the NSLocalizedString, NSLocalizedStringFromTable,
 *     NSLocalizedStringFromTableInBundle and NSLocalizedStringWithDefaultValue macros
 *   - URLForResource:withExtension:
 *   - URLForResource:withExtension:subdirectory:
 *   - URLsForResourcesWithExtension:subdirectory:
 *   - pathForResource:ofType:
 *   - pathForResource:ofType:inDirectory:
 *   - pathsForResourcesOfType:inDirectory:
 *
 * It does not affect any class method of NSBundle.
 *
 * To localize images, you cannot use the usual -[UIImage imageNamed:] method because of the cache it maintains
 * (there is no public API to flush it). Instead, find the path of your image using one of the above URL... or
 * path... methods, and call -[UIImage imageWithContentsOfFile:]. You of course lose the benefits of the cache,
 * but you can still implement a basic cache mechanism yourself if you want
 */
@interface NSBundle (HLSDynamicLocalization)

/**
 * Return the current localization used by all bundles.
 */
+ (NSString *)localization;

/**
 * Set the current localization used by all bundles.
 *
 * The localization parameter must be an element of the [[NSBundle mainBundle] localizations] array.
 * If the localization parameter is nil or invalid, the default localization is restored.
 *
 * The new localization is stored in the standard user defaults under the HLSPreferredLocalizationDefaultsKey key.
 */
+ (void)setLocalization:(nullable NSString *)localization;

@end

NS_ASSUME_NONNULL_END
