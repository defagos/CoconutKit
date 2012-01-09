//
//  UILabel+HLSDynamicLocalization.m
//  CoconutKit
//
//  Created by Samuel Défago on 08.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UILabel+HLSDynamicLocalization.h"

#import <objc/runtime.h>
#import "HLSCategoryLinker.h"
#import "HLSRuntime.h"
#import "NSBundle+HLSDynamicLocalization.h"

HLSLinkCategory(UILabel_HLSDynamicLocalization)

typedef enum {
    LocalizationAttributeEnumBegin = 0,
    LocalizationAttributeNormal = LocalizationAttributeEnumBegin,
    LocalizationAttributeUppercase,
    LocalizationAttributeLowercase,
    LocalizationAttributeEnumEnd,
    LocalizationAttributeEnumSize = LocalizationAttributeEnumEnd - LocalizationAttributeEnumBegin
} LocalizationAttribute;

static BOOL s_missingLocalizationsVisible = NO;

// Keys for associated objects
static void *s_localizationKeyKey = &s_localizationKeyKey;
static void *s_localizationAttributeKey = &s_localizationAttributeKey;
static void *s_localizationTableKey = &s_localizationTableKey;
static void *s_originalBackgroundColorKey = &s_originalBackgroundColorKey;

// Original implementations of the methods we swizzle
static id (*s_UILabel__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UILabel__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UILabel__dealloc_Imp)(id, SEL) = NULL;
static void (*s_UILabel__awakeFromNib_Imp)(id, SEL) = NULL;
static void (*s_UILabel__setText_Imp)(id, SEL, id) = NULL;

@interface UILabel (HLSDynamicLocalizationPrivate)

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

@implementation UILabel (HLSDynamicLocalization)

+ (void)setMissingLocalizationsVisible:(BOOL)visible
{
    s_missingLocalizationsVisible = visible;
    
    // Emit a localization notification to trigger a global label update
    [[NSNotificationCenter defaultCenter] postNotificationName:HLSCurrentLocalizationDidChangeNotification object:self];
}

@end

@implementation UILabel (HLSDynamicLocalizationPrivate)

+ (void)load
{
    s_UILabel__initWithFrame_Imp = (id (*)(id, SEL, CGRect))HLSSwizzleSelector(self, @selector(initWithFrame:), @selector(swizzledInitWithFrame:));
    s_UILabel__initWithCoder_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(initWithCoder:), @selector(swizzledInitWithCoder:));
    s_UILabel__dealloc_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, @selector(dealloc), @selector(swizzledDealloc));
    s_UILabel__awakeFromNib_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, @selector(awakeFromNib), @selector(swizzledAwakeFromNib));
    s_UILabel__setText_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(setText:), @selector(swizzledSetText:));
}

- (id)swizzledInitWithFrame:(CGRect)frame
{   
    if ((self = (*s_UILabel__initWithFrame_Imp)(self, @selector(initWithFrame:), frame))) {
        [self initCommon];
    }
    return self;
}

- (id)swizzledInitWithCoder:(NSCoder *)aDecoder
{
    if ((self = (*s_UILabel__initWithCoder_Imp)(self, @selector(initWithCoder:), aDecoder))) {
        [self initCommon];
    }
    return self;
}

- (void)swizzledDealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:HLSCurrentLocalizationDidChangeNotification 
                                                  object:nil];
    
    (*s_UILabel__dealloc_Imp)(self, @selector(dealloc));
}

- (void)swizzledAwakeFromNib
{
    (*s_UILabel__awakeFromNib_Imp)(self, @selector(awakeFromNib));
    
    [self updateLocalizationKey];
}

- (void)swizzledSetText:(NSString *)text
{
    (*s_UILabel__setText_Imp)(self, @selector(setText:), text);
    
    [self updateLocalizationKey];
}

- (void)initCommon
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(currentLocalizationDidChange:) 
                                                 name:HLSCurrentLocalizationDidChangeNotification 
                                               object:nil];
}

// Update the attached localization key by extracting it (if there is one) from the current text
- (void)updateLocalizationKey
{
    static NSString * const kSeparator = @"/";
    static NSString * const kNormalLeadingPrefix = @"LS";
    static NSString * const kUppercaseLeadingPrefix = @"ULS";
    static NSString * const kLowercaseLeadingPrefix = @"LLS";
    static NSString * const kTableNamePrefix = @"T";
    
    static NSArray *s_leadingPrefixes = nil;
    if (! s_leadingPrefixes) {
        s_leadingPrefixes = [[NSArray arrayWithObjects:kNormalLeadingPrefix, kUppercaseLeadingPrefix, kLowercaseLeadingPrefix, nil] retain];
    }
    
    // Break into components
    NSArray *components = [self.text componentsSeparatedByString:kSeparator];
    if ([components count] == 0) {
        return;
    }
    
    // If no leading prefix, nothing to do
    NSString *leadingPrefix = [components firstObject];
    if (! [s_leadingPrefixes containsObject:leadingPrefix]) {
        return;
    }
    
    // Extract attribute
    LocalizationAttribute attribute = LocalizationAttributeNormal;
    if ([leadingPrefix isEqualToString:kNormalLeadingPrefix]) {
        attribute = LocalizationAttributeNormal;
    }
    else if ([leadingPrefix isEqualToString:kUppercaseLeadingPrefix]) {
        attribute = LocalizationAttributeUppercase;
    }
    else if ([leadingPrefix isEqualToString:kLowercaseLeadingPrefix]) {
        attribute = LocalizationAttributeLowercase;
    }
    
    objc_setAssociatedObject(self, s_localizationAttributeKey, [NSNumber numberWithInt:attribute], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Extract the localization key
    NSString *localizationKey = @"";
    NSUInteger index = 1;
    BOOL hasTable = NO;
    while (index < [components count]) {
        NSString *component = [components objectAtIndex:index];
        
        // Stop when we find the table prefix
        if ([component isEqualToString:kTableNamePrefix]) {
            hasTable = YES;
            ++index;
            break;
        }
        
        localizationKey = [localizationKey stringByAppendingFormat:@"%@%@", component, kSeparator];
        ++index;
    }
    
    // Remove the last separator we might have incorrectly added
    if ([localizationKey length] >= 1) {
        localizationKey = [localizationKey substringToIndex:[localizationKey length] - 1];
    }
    
    if ([localizationKey length] == 0) {
        HLSLoggerWarn(@"Leading localization prefix %@ detected, but empty localization key", [components firstObject]);
    }
    
    objc_setAssociatedObject(self, s_localizationKeyKey, localizationKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Extract the table name
    if (hasTable) {
        NSString *table = @"";
        while (index < [components count]) {
            NSString *component = [components objectAtIndex:index];
            table = [table stringByAppendingFormat:@"%@%@", component, kSeparator];
            ++index;
        }
        
        // Remove the last separator we might have incorrectly added
        if ([table length] >= 1) {
            table = [table substringToIndex:[table length] - 1];
        }
        
        if ([table length] == 0) {
            HLSLoggerWarn(@"Table name prefix detected, but empty table name", [components firstObject]);
        }
        
        objc_setAssociatedObject(self, s_localizationTableKey, table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self localizeText];
}

// Localize the current text using the attached localization key (if any)
- (void)localizeText
{
    NSString *localizationKey = objc_getAssociatedObject(self, s_localizationKeyKey);
    if (! localizationKey) {
        return;
    }
    
    // We use an explicit constant string for missing localizations since otherwise the key would be returned by 
    // localizedStringForKey:value:table
    static NSString * const kMissingLocalizedString = @"UILabel_HLSDynamicLocalization_missing";
    NSString *table = objc_getAssociatedObject(self, s_localizationTableKey);
    NSString *text = [[NSBundle mainBundle] localizedStringForKey:localizationKey value:kMissingLocalizedString table:table];
    
    // Restore the original background color if it had been altered
    UIColor *originalBackgroundColor = objc_getAssociatedObject(self, s_originalBackgroundColorKey);
    self.backgroundColor = originalBackgroundColor;
    objc_setAssociatedObject(self, s_originalBackgroundColorKey, self.backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    // Use the localization key as text if missing
    if ([text isEqualToString:kMissingLocalizedString]) {
        text = [localizationKey length] != 0 ? localizationKey : @"(no key)";
        
        // Make labels with missing localizations visible (saving the original color first)
        if (s_missingLocalizationsVisible) {
            self.backgroundColor = [UIColor yellowColor];
        }    
    }
    
    LocalizationAttribute attribute = [objc_getAssociatedObject(self, s_localizationAttributeKey) intValue];
    if (attribute == LocalizationAttributeUppercase) {
        text = [text uppercaseString];
    }
    else if (attribute == LocalizationAttributeLowercase) {
        text = [text lowercaseString];
    }
    
    self.text = text;
    
    // Special case of buttons: Must adjust the label when the string is updated
    if ([[self superview] isKindOfClass:[UIButton class]]) {
        [self sizeToFit];
    }
}

#pragma mark Notification callbacks

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    [self localizeText];
}

@end
