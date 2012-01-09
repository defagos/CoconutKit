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

static BOOL m_missingLocalizationsVisible = NO;

// Keys for associated objects
static void *s_localizationKeyKey = &s_localizationKeyKey;
static void *s_localizationAttributeKey = &s_localizationAttributeKey;
static void *s_localizationTableKey = &s_localizationTableKey;

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
    m_missingLocalizationsVisible = visible;
    
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
    // TODO: Extract prefix first. Then extract table and key
    
    NSString *localizationKey = nil;
    LocalizationAttribute attribute = LocalizationAttributeNormal;
    if ([self.text hasPrefix:@"LS:"]) {
        localizationKey = [self.text substringFromIndex:3];
        attribute = LocalizationAttributeNormal;
    }
    else if ([self.text hasPrefix:@"ULS:"]) {
        localizationKey = [self.text substringFromIndex:4];
        attribute = LocalizationAttributeUppercase;
    }
    else if ([self.text hasPrefix:@"LLS:"]) {
        localizationKey = [self.text substringFromIndex:4];
        attribute = LocalizationAttributeLowercase;
    }
    
    if (localizationKey) {
        objc_setAssociatedObject(self, s_localizationKeyKey, localizationKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, s_localizationAttributeKey, [NSNumber numberWithInt:attribute], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self localizeText];
    }
}

// Localize the current text using the attached localization key (if any)
- (void)localizeText
{
    NSString *localizationKey = objc_getAssociatedObject(self, s_localizationKeyKey);
    if (! localizationKey) {
        return;
    }
    
    // We use an explicit constant string for missing localizations since otherwise the key would be returned
    static NSString * const kMissingLocalizedString = @"UILabel_HLSDynamicLocalization_missing";
    NSString *text = [[NSBundle mainBundle] localizedStringForKey:localizationKey value:kMissingLocalizedString table:nil];
    
    // Use the localization key as text if missing
    if ([text isEqualToString:kMissingLocalizedString]) {
        text = localizationKey;
        
        // Make labels with missing localizations visible
        if (m_missingLocalizationsVisible) {
            self.textColor = [UIColor redColor];
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
