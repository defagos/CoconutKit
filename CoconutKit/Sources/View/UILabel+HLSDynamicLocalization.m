//
//  UILabel+HLSDynamicLocalization.m
//  CoconutKit
//
//  Created by Samuel Défago on 08.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "UILabel+HLSDynamicLocalization.h"

#import "HLSCategoryLinker.h"
#import "HLSLabelLocalizationInfo.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSDictionary+HLSExtensions.h"

HLSLinkCategory(UILabel_HLSDynamicLocalization)

static BOOL s_missingLocalizationsVisible = NO;

// Keys for associated objects
static void *s_localizationInfosKey = &s_localizationInfosKey;

// Original implementations of the methods we swizzle
static id (*s_UILabel__initWithFrame_Imp)(id, SEL, CGRect) = NULL;
static id (*s_UILabel__initWithCoder_Imp)(id, SEL, id) = NULL;
static void (*s_UILabel__dealloc_Imp)(id, SEL) = NULL;
static void (*s_UILabel__awakeFromNib_Imp)(id, SEL) = NULL;
static void (*s_UILabel__setText_Imp)(id, SEL, id) = NULL;
static void (*s_UILabel__setBackgroundColor_Imp)(id, SEL, id) = NULL;

@interface UILabel (HLSDynamicLocalizationPrivate)

- (id)swizzledInitWithFrame:(CGRect)frame;
- (id)swizzledInitWithCoder:(NSCoder *)aDecoder;
- (void)swizzledDealloc;
- (void)swizzledAwakeFromNib;
- (void)swizzledSetText:(NSString *)text;
- (void)swizzledSetBackgroundColor:(UIColor *)backgroundColor;

- (HLSLabelLocalizationInfo *)localizationInfo;
- (void)setLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo;

- (void)localizeAndSetText:(NSString *)text;
- (void)localizeTextWithLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo;

- (void)registerForLocalizationChanges;

- (void)currentLocalizationDidChange:(NSNotification *)notification;

@end

@implementation UILabel (HLSDynamicLocalization)

#pragma mark Class methods

+ (void)setMissingLocalizationsVisible:(BOOL)visible
{
    s_missingLocalizationsVisible = visible;
    
    // Emit a localization notification to trigger a global label update
    [[NSNotificationCenter defaultCenter] postNotificationName:HLSCurrentLocalizationDidChangeNotification object:self];
}

+ (BOOL)missingLocalizationsVisible
{
    return s_missingLocalizationsVisible;
}

@end

@implementation UILabel (HLSDynamicLocalizationPrivate)

#pragma mark Class methods

+ (void)load
{
    s_UILabel__initWithFrame_Imp = (id (*)(id, SEL, CGRect))HLSSwizzleSelector(self, @selector(initWithFrame:), @selector(swizzledInitWithFrame:));
    s_UILabel__initWithCoder_Imp = (id (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(initWithCoder:), @selector(swizzledInitWithCoder:));
    s_UILabel__dealloc_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, @selector(dealloc), @selector(swizzledDealloc));
    s_UILabel__awakeFromNib_Imp = (void (*)(id, SEL))HLSSwizzleSelector(self, @selector(awakeFromNib), @selector(swizzledAwakeFromNib));
    s_UILabel__setText_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(setText:), @selector(swizzledSetText:));
    s_UILabel__setBackgroundColor_Imp = (void (*)(id, SEL, id))HLSSwizzleSelector(self, @selector(setBackgroundColor:), @selector(swizzledSetBackgroundColor:));
}

#pragma mark Swizzled method implementations

- (id)swizzledInitWithFrame:(CGRect)frame
{   
    if ((self = (*s_UILabel__initWithFrame_Imp)(self, @selector(initWithFrame:), frame))) {
        [self registerForLocalizationChanges];
    }
    return self;
}

- (id)swizzledInitWithCoder:(NSCoder *)aDecoder
{
    if ((self = (*s_UILabel__initWithCoder_Imp)(self, @selector(initWithCoder:), aDecoder))) {
        [self registerForLocalizationChanges];
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
    // Here self.text returns the string filled by deserialization from the nib (which is not set using setText:)
    [self localizeAndSetText:self.text];    
}

- (void)swizzledSetText:(NSString *)text
{
    [self localizeAndSetText:text];
}

- (void)swizzledSetBackgroundColor:(UIColor *)backgroundColor
{
    (*s_UILabel__setBackgroundColor_Imp)(self, @selector(setBackgroundColor:), backgroundColor);
    
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    localizationInfo.originalBackgroundColor = backgroundColor;
}

#pragma mark Localization

- (HLSLabelLocalizationInfo *)localizationInfo
{
    // Button label
    if ([[self superview] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[self superview];
        
        // Get localization info for all states. Attached to the button (because it carries the states)
        NSDictionary *buttonStateToLocalizationInfoMap = objc_getAssociatedObject(button, s_localizationInfosKey);
        if (! buttonStateToLocalizationInfoMap) {
            return nil;
        }
        
        // Get the information for the current button state
        NSNumber *buttonStateKey = [NSNumber numberWithInt:button.state];
        return [buttonStateToLocalizationInfoMap objectForKey:buttonStateKey];
    }
    // Standalone label
    else {
        return objc_getAssociatedObject(self, s_localizationInfosKey);
    }
}

- (void)setLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo
{
    // Button label
    if ([[self superview] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[self superview];
        
        // Get localization info for all states (lazily added if needed). Attached to the button (because it carries the states)
        NSDictionary *buttonStateToLocalizationInfoMap = objc_getAssociatedObject(button, s_localizationInfosKey);
        if (! buttonStateToLocalizationInfoMap) {
            buttonStateToLocalizationInfoMap = [NSDictionary dictionary];
        }
        
        // Attach the information to the current button state
        NSNumber *buttonStateKey = [NSNumber numberWithInt:button.state];
        buttonStateToLocalizationInfoMap = [buttonStateToLocalizationInfoMap dictionaryBySettingObject:localizationInfo 
                                                                                                forKey:buttonStateKey];
        
        objc_setAssociatedObject(button, s_localizationInfosKey, buttonStateToLocalizationInfoMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // Standalone label
    else {
        objc_setAssociatedObject(self, s_localizationInfosKey, localizationInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)localizeAndSetText:(NSString *)text
{
    // Each label is lazily associated with localization information the first time its text is set (even
    // if the label is not localized). The localization settings it contains (most notably the key) cannot 
    // be updated afterwards. 
    //
    // The reason of this behavior is that objects embedding labels (like buttons) might call setText: 
    // several times in their implementation, and for various reasons. Moreover, we cannot reliably 
    // know how many times setText: will be called in such cases. If we updated the localization
    // information each time setText: is called, this would lead to issues, as the explanation below
    // should make clear.
    //
    // Let us assume we have such an object. When setText: gets first called, localization might occur 
    // if a prefix is discovered. But when the extracted localized string gets further assigned to the 
    // object, this process might trigger another setText: internally. If we weren't assigning localization 
    // information permanently (i.e. if we were replacing any attached localization information the 
    // second time the text gets updated), we would not be able to tell that we do not want to change the 
    // localization key this time. We would therefore replace the existing localization information with
    // no information, losing the initial localization key which had been extracted.
    // 
    // To avoid this problem, localization information is assigned permanently. This is not limiting, 
    // though, since the prefix-in-nib trick makes really sense for static labels (those which do not have 
    // to be connected using outlets). By definition such labels have a constant text (except of course if 
    // you want to mess with the view hierarchy to set a label. But do you really want to?)
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    if (! localizationInfo) {
        localizationInfo = [[[HLSLabelLocalizationInfo alloc] initWithText:text] autorelease];
        [self setLocalizationInfo:localizationInfo];
    }
    
    if (localizationInfo.locked) {
        (*s_UILabel__setText_Imp)(self, @selector(setText:), text);
        localizationInfo.locked = NO;
        return;
    }
    
    if (localizationInfo.localizationKey) {
        [self localizeTextWithLocalizationInfo:localizationInfo];
    }
    else {
        (*s_UILabel__setText_Imp)(self, @selector(setText:), text);
    }
}

// Localize the current text using the corresponding localization information
- (void)localizeTextWithLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo
{
    // Restore the original background color if it had been altered
    // (*s_UILabel__setBackgroundColor_Imp)(self, @selector(setBackgroundColor:), localizationInfo.originalBackgroundColor);
    
#if 0
    // Restore the original background color if it had been altered
    UIColor *originalBackgroundColor = objc_getAssociatedObject(self, s_originalBackgroundColorKey);
    self.backgroundColor = originalBackgroundColor;
    objc_setAssociatedObject(self, s_originalBackgroundColorKey, self.backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

#endif
    
    // If no localization key, nothing to do
    if (! localizationInfo.localizationKey) {
        return;
    }
    
    // We use an explicit constant string for missing localizations since otherwise the key would be returned by 
    // localizedStringForKey:value:table
    static NSString * const kMissingLocalizedString = @"UILabel_HLSDynamicLocalization_missing";
    NSString *text = [[NSBundle mainBundle] localizedStringForKey:localizationInfo.localizationKey
                                                            value:kMissingLocalizedString
                                                            table:localizationInfo.table];
            
    // Use the localization key as text if missing
    if ([text isEqualToString:kMissingLocalizedString]) {
        text = [localizationInfo.localizationKey length] != 0 ? localizationInfo.localizationKey : @"(no key)";
        
        // Make labels with missing localizations visible (saving the original color first)
        if (s_missingLocalizationsVisible) {
            // We must use the original method here
            // (*s_UILabel__setBackgroundColor_Imp)(self, @selector(setBackgroundColor:), [UIColor yellowColor]);
        }    
    }
    
    // Formatting
    switch (localizationInfo.representation) {
        case HLSLabelRepresentationUppercase: {
            text = [text uppercaseString];
            break;
        }
            
        case HLSLabelRepresentationLowercase: {
            text = [text lowercaseString];
            break;
        }
            
        case HLSLabelRepresentationCapitalized: {
            text = [text capitalizedString];
            break;
        }
            
        default: {
            break;
        }
    }
    
    // Button label
    if ([[self superview] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[self superview];
        localizationInfo.locked = YES;
        [button setTitle:text forState:button.state];
    }
    // Standalone label
    else {
        (*s_UILabel__setText_Imp)(self, @selector(setText:), text);
    }
}

- (void)registerForLocalizationChanges
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(currentLocalizationDidChange:) 
                                                 name:HLSCurrentLocalizationDidChangeNotification 
                                               object:nil];
}

#pragma mark Notification callbacks

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    [self localizeTextWithLocalizationInfo:localizationInfo];
}

@end
