//
//  UILabel+HLSDynamicLocalization.h
//  CoconutKit
//
//  Created by Samuel Défago on 08.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Category for easier label localization in nib files. Instead of having to define and bind an outlet just 
 * to localize a UILabel or a UIButton, this category makes it easy to attach a localization key to a label
 * or a button label directly in a nib file. Simply set the text in the nib using one of the following
 * constructs:
 *   - LS/<localizationKey>[/T/<table>/]: Will be replaced by the localized string corresponding to the 
 *                                        localization key (lookup is performed in the main bundle 
 *                                        Localizable.strings file if no explicit table is provided)
 *   - ULS/<localizationKey>[/T/<table>/]: Same as LS:, but uppercase
 *   - LLS/<localizationKey>[/T/<table>/]: Same as LS:, but lowercase
 *   - CLS/<localizationKey>[/T/<table>/]: Same as LS:, but capitalized
 *
 * It is important to note that when a label has been localized in a nib using one of the above prefixes,
 * the attached localization key cannot be altered anymore. This is not a problem, though, since this
 * approach is intended for "static" labels which are defined once in a nib file and not altered later.
 * If you need to be able to change the text of a label, do not use prefixes in the nib, use outlets 
 * (after all, if you need to be able to change the text of a label, you probably need an outlet anyway, 
 * which is just what the prefix approach is intended to avoid).
 *
 * Some examples:
 *   LS/Cancel: Looks for a "Cancel" key in Localizable.strings
 *   ULS/Send link/T/LocalizationFileName: Looks for a "Send link" key in LocalizationFileName.strings
 *
 * Sadly UIBarButtonItem objects cannot be localized this way. Achieving this goal would require messing
 * with a toolbar's view hierarchy, an approach I considered not robust enough to deserve being implemented.
 *
 * Note that lookup is always performed in the main bundle only. If you want to use localization dictionaries
 * in other bundles, you will have to create and bind outlets.
 *
 * If the key is not found, the localization key itself is used instead. At runtime, you can reveal labels for 
 * which a localization entry is missing (for the current application language) by using the provided
 * +setMissingLocalizationsVisible: class method. You can of course still use the NSShowNonLocalizedStrings
 * default setting which logs missing keys to the console if you prefer:
 *   [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"NSShowNonLocalizedStrings"];
 *
 * This category integrates with HLSBundle+HLSDynamicLocalization so that localized labels are updated when the 
 * localization language is changed at runtime.
 *
 * This category currently has three limitations, but which should not be real issues:
 *   - only localization dictionaries in the main bundle are considered. For applications this should not be
 *     a problem since this is in general the only bundle you have. Libraries, on the other hand, might provide 
 *     their resources as a separate .bundle. But since nib files should be quite rare in libraries (usually, 
 *     library components are created completely in code) this should not be a problem either
 *   - no comment can be provided. This would have been too verbose, and in my experience comments added
 *     to NSLocalizedString macros are not really useful (they are seen by the programmer, not by the translator). 
 *     Having them only in the .strings files is what I usually recommend. Tools like Linguan or iLocalize can
 *     help you to add those comments after localization dictionaries have been extracted from the source code
 *   - this brings me to the (currently) really annoying limitation of this category: Automatic localization key 
 *     extraction using genstrings does not work, since genstrings is of course unable to find the constructs
 *     listed above in nib files. I intend to provide a modified genstrings command as part of CoconutKit, this 
 *     should therefore not be a problem anymore soon :-)
 */
@interface UILabel (HLSDynamicLocalization)

/**
 * When set to YES, reveals those labels for which a localization string is missing (for the current language)
 * (yellow background)
 */
+ (void)setMissingLocalizationsVisible:(BOOL)visible;

/**
 * Return YES iff missing localization visibility has been turned on
 */
+ (BOOL)missingLocalizationsVisible;

@end
