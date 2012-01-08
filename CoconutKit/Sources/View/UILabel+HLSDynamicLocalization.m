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

HLSLinkCategory(UILabel_HLSDynamicLocalization)

typedef enum {
    LocalizationAttributeEnumBegin = 0,
    LocalizationAttributeNormal = LocalizationAttributeEnumBegin,
    LocalizationAttributeUppercase,
    LocalizationAttributeLowercase,
    LocalizationAttributeEnumEnd,
    LocalizationAttributeEnumSize = LocalizationAttributeEnumEnd - LocalizationAttributeEnumBegin
} LocalizationAttribute;

// Keys for associated objects
static void *s_localizationKeyKey = &s_localizationKeyKey;
static void *s_localizationAttributeKey = &s_localizationAttributeKey;

// Original implementations of the methods we swizzle
static id (*s_UILabel__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UILabel__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UILabel__dealloc_Imp)(id, SEL) = NULL;
static void (*s_UILabel__awakeFromNib_Imp)(id, SEL) = NULL;
static void (*s_UILabel__setText_Imp)(id, SEL, id) = NULL;

@implementation UILabel (HLSDynamicLocalization)

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
                                                 name:HLSCurrentLocalizationDidChangeNotification object:nil];
}

// Update the attached localization key by extracting it (if there is one) from the current text
- (void)updateLocalizationKey
{
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
    
    NSString *text = [[NSBundle mainBundle] localizedStringForKey:localizationKey value:@"(missing)" table:nil];
    
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
