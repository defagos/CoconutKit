//
//  UILabel+HLSDynamicLocalization.h
//  CoconutKit
//
//  Created by Samuel Défago on 08.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Private category for easier label localization in nib files. Instead of having to define and bind an outlet
 * just to localize a label or a button, this category makes it easy to attach a localization key to a label
 * or a button label directly in a nib file. Simply set the text in the nib using one of the following
 * constructs:
 *   - LS:<localizationKey>: For standard localized strings
 *   - ULS:<localizationKey>: Same as LS:, but uppercase
 *   - LLS:<localizationKey>: Same as LS:, but lowercase
 * This category integrates with HLSBundle+HLSDynamicLocalization so that the text is updated when the localization
 * language is updated at runtime.
 *
 * If the key is not found, the text is set to "(missing)"
 *
 * TODO: Add LST:<table>: (and similar constructs) for localized strings from other tables
 */
@interface UILabel (HLSDynamicLocalization)

- (id)swizzledInitWithFrame:(CGRect)frame;
- (id)swizzledInitWithCoder:(NSCoder *)aDecoder;
- (void)swizzledDealloc;
- (void)swizzledAwakeFromNib;
- (void)swizzledSetText:(NSString *)text;

- (void)initCommon;
- (void)updateLocalizationKey;
- (void)localizeText;

- (void)currentLocalizationDidChange:(NSNotification *)notification;

@end
