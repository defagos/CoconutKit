//
//  NSBundle+DynamicLocalization.h
//  CoconutKit
//
//  Created by Cédric Luthi on 08/15/11.
//  Copyright 2011 Hortis. All rights reserved.
//

extern NSString * const HLSPreferredLocalizationDefaultsKey;
extern NSString * const HLSCurrentLocalizationDidChangeNotification;

/**
 * Returns the language for a localization
 * For example:
 *   HLSLanguageForLocalization(@"de") returns @"Deutsch"
 *   HLSLanguageForLocalization(@"en") returns @"English"
 */
NSString *HLSLanguageForLocalization(NSString *localization);

@interface NSBundle (DynamicLocalization)

/**
 * Returns the current localization used by all bundles.
 */
+ (NSString *)localization;

/**
 * Set the current localization used by all bundles.
 *
 * The localization parameter must be an element of the [[NSBundle mainBundle] localizations] array.
 * If the localization parameter is nil or invalid, the default localization is restored.
 *
 * When the localization changes, a HLSCurrentLocalizationDidChangeNotification is posted. In order to easily support
 * this dynamic localization feature, you should override the localize method of your HLSViewController instances.
 *
 * The new localization is stored in the standard user defaults under the HLSPreferredLocalizationDefaultsKey key.
 *
 * Setting the current localization affects the following instance methods of NSBundle:
 *   - localizedStringForKey:value:table:
 *     i.e. also the NSLocalizedString, NSLocalizedStringFromTable, NSLocalizedStringFromTableInBundle and NSLocalizedStringWithDefaultValue macros
 *   - URLForResource:withExtension:
 *   - URLForResource:withExtension:subdirectory:
 *   - URLsForResourcesWithExtension:subdirectory:
 *   - pathForResource:ofType:
 *   - pathForResource:ofType:inDirectory:
 *   - pathsForResourcesOfType:inDirectory:
 *
 * It does not affect any class method of NSBundle.
 */
+ (void)setLocalization:(NSString *)localization;

@end
