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

- (void)registerForLocalizationChanges;
- (void)updateLocalizationInfos;
- (void)localizeText;

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
    (*s_UILabel__awakeFromNib_Imp)(self, @selector(awakeFromNib));
    
    [self updateLocalizationInfos];
    [self localizeText];
}

- (void)swizzledSetText:(NSString *)text
{
    (*s_UILabel__setText_Imp)(self, @selector(setText:), text);
    
    [self updateLocalizationInfos];
    [self localizeText];
}

- (void)swizzledSetBackgroundColor:(UIColor *)backgroundColor
{
    (*s_UILabel__setBackgroundColor_Imp)(self, @selector(setBackgroundColor:), backgroundColor);
    
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    localizationInfo.originalBackgroundColor = backgroundColor;
}

#pragma mark Localization

// Returns the localization information associated with the current label. This information is lazily created and
// attached to the appropriate object
- (HLSLabelLocalizationInfo *)localizationInfo
{
    // The label is a button label
    if ([[self superview] isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)[self superview];
        
        // Get localization info for all states (lazily added if needed). Attached to the button, see below
        NSDictionary *buttonStateToLocalizationInfoMap = objc_getAssociatedObject(button, s_localizationInfosKey);
        if (! buttonStateToLocalizationInfoMap) {
            buttonStateToLocalizationInfoMap = [NSDictionary dictionary];
        }
        
        // Get the information for the current button state (add it lazily if it does not exist yet)
        NSNumber *buttonStateKey = [NSNumber numberWithInt:button.state];
        HLSLabelLocalizationInfo *localizationInfo = [buttonStateToLocalizationInfoMap objectForKey:buttonStateKey];
        if (! localizationInfo) {
            localizationInfo = [[[HLSLabelLocalizationInfo alloc] init] autorelease];
            buttonStateToLocalizationInfoMap = [buttonStateToLocalizationInfoMap dictionaryBySettingObject:localizationInfo 
                                                                                                    forKey:buttonStateKey];
        }
        
        // Attach the localization to the button (cleaner; titles are button properties, and we cannot know for sure
        // whether the button label is reused or not)
        objc_setAssociatedObject(button, s_localizationInfosKey, buttonStateToLocalizationInfoMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return localizationInfo;
    }
    // Standalone label
    else {
        HLSLabelLocalizationInfo *localizationInfo = objc_getAssociatedObject(self, s_localizationInfosKey);
        if (! localizationInfo) {
            localizationInfo = [[[HLSLabelLocalizationInfo alloc] init] autorelease];
            objc_setAssociatedObject(self, s_localizationInfosKey, localizationInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        return localizationInfo;
    }
}

- (void)registerForLocalizationChanges
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(currentLocalizationDidChange:) 
                                                 name:HLSCurrentLocalizationDidChangeNotification 
                                               object:nil];
}

// Update the attached localization information by extracting it (if there is one) from the current text and label
// properties
- (void)updateLocalizationInfos
{
    // Get and reset any currently existing information
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    localizationInfo.localizationKey = nil;
    
    // Syntactic elements
    static NSString * const kSeparator = @"/";
    static NSString * const kNormalLeadingPrefix = @"LS";
    static NSString * const kUppercaseLeadingPrefix = @"ULS";
    static NSString * const kLowercaseLeadingPrefix = @"LLS";
    static NSString * const kCapitalizedLeadingPrefix = @"CLS";
    static NSString * const kTableNamePrefix = @"T";
    
    static NSArray *s_leadingPrefixes = nil;
    if (! s_leadingPrefixes) {
        s_leadingPrefixes = [[NSArray arrayWithObjects:kNormalLeadingPrefix, kUppercaseLeadingPrefix, kLowercaseLeadingPrefix, 
                              kCapitalizedLeadingPrefix, nil] retain];
    }
    
    // Break text into components
    NSArray *components = [self.text componentsSeparatedByString:kSeparator];
    if ([components count] == 0) {
        return;
    }
    
    // If no leading prefix, we are done
    NSString *leadingPrefix = [components firstObject];
    if (! [s_leadingPrefixes containsObject:leadingPrefix]) {
        return;
    }
    
    // Extract representation
    if ([leadingPrefix isEqualToString:kUppercaseLeadingPrefix]) {
        localizationInfo.representation = HLSLabelRepresentationUppercase;
    }
    else if ([leadingPrefix isEqualToString:kLowercaseLeadingPrefix]) {
        localizationInfo.representation = HLSLabelRepresentationLowercase;
    }
    else if ([leadingPrefix isEqualToString:kCapitalizedLeadingPrefix]) {
        localizationInfo.representation = HLSLabelRepresentationCapitalized;
    }
    else {
        localizationInfo.representation = HLSLabelRepresentationNormal;
    }
    
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
    localizationInfo.localizationKey = localizationKey;
    
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
        
        localizationInfo.table = table;
    }
}

// Localize the current text using the corresponding localization information
- (void)localizeText
{
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    
    if ([localizationInfo.localizationKey isEqualToString:@"LS/Button label, normal"]) {
        NSLog(@"localize text for key %@", localizationInfo.localizationKey);
    }
    
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
        [button setTitle:text forState:button.state];
    }
    // Standalone label
    else {
        (*s_UILabel__setText_Imp)(self, @selector(setText:), text);
    }
}

#pragma mark Notification callbacks

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    [self localizeText];
}

@end
