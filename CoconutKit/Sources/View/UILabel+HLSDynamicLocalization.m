//
//  UILabel+HLSDynamicLocalization.m
//  CoconutKit
//
//  Created by Samuel Défago on 08.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "UILabel+HLSDynamicLocalization.h"

#import "HLSLabelLocalizationInfo.h"
#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "NSBundle+HLSDynamicLocalization.h"
#import "NSDictionary+HLSExtensions.h"
#import "NSString+HLSExtensions.h"

static BOOL s_missingLocalizationsVisible = NO;

// Keys for associated objects
static void *s_localizationInfosKey = &s_localizationInfosKey;
static void *s_originalBackgroundColorKey = &s_originalBackgroundColorKey;

static void *s_localizationTableNameKey = &s_localizationTableNameKey;
static void *s_localizationBundleNameKey = &s_localizationBundleNameKey;

// Original implementation of the methods we swizzle
static void (*s_UILabel__dealloc_Imp)(__unsafe_unretained id, SEL) = NULL;
static void (*s_UILabel__awakeFromNib_Imp)(id, SEL) = NULL;
static void (*s_UILabel__setText_Imp)(id, SEL, id) = NULL;
static void (*s_UILabel__setBackgroundColor_Imp)(id, SEL, id) = NULL;

// Swizzled method implementations
static void swizzled_UILabel__dealloc_Imp(__unsafe_unretained UILabel *self, SEL _cmd);
static void swizzled_UILabel__awakeFromNib_Imp(UILabel *self, SEL _cmd);
static void swizzled_UILabel__setText_Imp(UILabel *self, SEL _cmd, NSString *text);
static void swizzled_UILabel__setBackgroundColor_Imp(UILabel *self, SEL _cmd, UIColor *backgroundColor);

@interface UILabel (HLSDynamicLocalizationPrivate)

- (HLSLabelLocalizationInfo *)localizationInfo;
- (void)setLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo;

- (void)setAndLocalizeText:(NSString *)text;
- (void)localizeTextWithLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo;

- (void)currentLocalizationDidChange:(NSNotification *)notification;

@end

@interface UIView (HLSDynamicLocalizationPrivate)

@property (nonatomic, strong) NSString *locTable;
@property (nonatomic, strong) NSString *locBundle;

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
    s_UILabel__dealloc_Imp = (void (*)(__unsafe_unretained id, SEL))hls_class_swizzleSelector(self,
                                                                                              NSSelectorFromString(@"dealloc"),
                                                                                              (IMP)swizzled_UILabel__dealloc_Imp);
    s_UILabel__awakeFromNib_Imp = (void (*)(id, SEL))hls_class_swizzleSelector(self,
                                                                               @selector(awakeFromNib),
                                                                               (IMP)swizzled_UILabel__awakeFromNib_Imp);
    s_UILabel__setText_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                              @selector(setText:),
                                                                              (IMP)swizzled_UILabel__setText_Imp);
    s_UILabel__setBackgroundColor_Imp = (void (*)(id, SEL, id))hls_class_swizzleSelector(self,
                                                                                         @selector(setBackgroundColor:),
                                                                                         (IMP)swizzled_UILabel__setBackgroundColor_Imp);
}

#pragma mark Localization

- (HLSLabelLocalizationInfo *)localizationInfo
{
    // Button label
    if ([self.superview isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.superview;
        
        // Get localization info for all states. Attached to the button (because it carries the states)
        NSDictionary *buttonStateToLocalizationInfoMap = hls_getAssociatedObject(button, s_localizationInfosKey);
        if (! buttonStateToLocalizationInfoMap) {
            return nil;
        }
        
        // Get the information for the current button state
        NSNumber *buttonStateKey = @(button.state);
        return [buttonStateToLocalizationInfoMap objectForKey:buttonStateKey];
    }
    // Standalone label
    else {
        return hls_getAssociatedObject(self, s_localizationInfosKey);
    }
}

- (void)setLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo
{
    // Button label
    if ([self.superview isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.superview;
        
        // Get localization info for all states (lazily added if needed). Attached to the button (because it carries the states)
        NSDictionary *buttonStateToLocalizationInfoMap = hls_getAssociatedObject(button, s_localizationInfosKey);
        if (! buttonStateToLocalizationInfoMap) {
            buttonStateToLocalizationInfoMap = @{};
        }
        
        // Attach the information to the current button state
        NSNumber *buttonStateKey = @(button.state);
        buttonStateToLocalizationInfoMap = [buttonStateToLocalizationInfoMap dictionaryBySettingObject:localizationInfo 
                                                                                                forKey:buttonStateKey];
        
        hls_setAssociatedObject(button, s_localizationInfosKey, buttonStateToLocalizationInfoMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // Standalone label
    else {
        hls_setAssociatedObject(self, s_localizationInfosKey, localizationInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setAndLocalizeText:(NSString *)text
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
        NSString *tableName = self.locTable;
        if (! tableName) {
            UIView *parentView = self.superview;
            while (parentView && ! [parentView.locTable isFilled]) {
                parentView = parentView.superview;
            }
            tableName = parentView.locTable;
        }
        
        NSString *bundleName = self.locBundle;
        if (! bundleName) {
            UIView *parentView = self.superview;
            while (parentView && ! [parentView.locBundle isFilled]) {
                parentView = parentView.superview;
            }
            bundleName = parentView.locBundle;
        }
        
        localizationInfo = [[HLSLabelLocalizationInfo alloc] initWithText:text tableName:tableName bundleName:bundleName];
        [self setLocalizationInfo:localizationInfo];
        
        // For labels localized with prefixes only: Listen to localization change notifications
        if ([localizationInfo isLocalized]) {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(currentLocalizationDidChange:) 
                                                         name:HLSCurrentLocalizationDidChangeNotification 
                                                       object:nil];
        }
    }
    
    // Update the label text
    if ([localizationInfo isLocalized]) {
        [self localizeTextWithLocalizationInfo:localizationInfo];
    }
    else {
        (*s_UILabel__setText_Imp)(self, @selector(setText:), text);
    }
}

- (void)localizeTextWithLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo
{
    NSString *localizedText = [localizationInfo localizedText];
    (*s_UILabel__setText_Imp)(self, @selector(setText:), localizedText);
    
    // Avoid button label truncation when the localization changes (setting the title triggers a sizeToFit), and fixes
    // issues with the button label tint color. If we only change the label text, we namely face some minor issues
    // related to how iOS 7 handles buttons. The expected behavior is:
    //   - the label tint color of buttons changes when clicking on them, if only a title is assigned for the normal
    //     state
    //   - when a popover is displayed, the tint color of button labels is changed (private UIViewVisitorEntertainVisitors)
    // If we only change the label text, not the button title, then buttons behave in both cases as if a title was assigned
    // for the highlighted state, i.e. the label tint color will not change, but the label disappears and reappears when
    // transitioning between states
    if ([self.superview isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)self.superview;
        [button setTitle:localizedText forState:button.state];
    }
    
    // Restore the original background color if it had been altered
    UIColor *originalBackgroundColor = hls_getAssociatedObject(self, s_originalBackgroundColorKey);
    (*s_UILabel__setBackgroundColor_Imp)(self, @selector(setBackgroundColor:), originalBackgroundColor);
    
    // Make labels with missing localizations visible (saving the original color first)
    if (s_missingLocalizationsVisible) {
        if ([localizationInfo isIncomplete]) {
            // Using the original implementation here. We do not want to update the color stored in the information object
            (*s_UILabel__setBackgroundColor_Imp)(self, @selector(setBackgroundColor:), [UIColor yellowColor]);
        }
    }
}

#pragma mark Notification callbacks

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    if ([localizationInfo isLocalized]) {
        [self localizeTextWithLocalizationInfo:localizationInfo];
    }
}

@end

@implementation UIView (HLSDynamicLocalizationPrivate)

#pragma mark Accessors and mutators

- (NSString *)locTable
{
    return hls_getAssociatedObject(self, s_localizationTableNameKey);
}

- (void)setLocTable:(NSString *)locTable
{
    hls_setAssociatedObject(self, s_localizationTableNameKey, locTable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)locBundle
{
    return hls_getAssociatedObject(self, s_localizationBundleNameKey);
}

- (void)setLocBundle:(NSString *)locBundle
{
    hls_setAssociatedObject(self, s_localizationBundleNameKey, locBundle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark Swizzled method implementations

// Marked as __unsafe_unretained to avoid ARC inserting incorrect memory management calls leading to crashes for -dealloc
static void swizzled_UILabel__dealloc_Imp(__unsafe_unretained UILabel *self, SEL _cmd)
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:HLSCurrentLocalizationDidChangeNotification 
                                                  object:nil];
    
    (*s_UILabel__dealloc_Imp)(self, _cmd);
}

static void swizzled_UILabel__awakeFromNib_Imp(UILabel *self, SEL _cmd)
{
    (*s_UILabel__awakeFromNib_Imp)(self, _cmd);
    
    // Here self.text returns the string filled by deserialization from the nib (which is not set using setText:)
    [self setAndLocalizeText:self.text];
}

static void swizzled_UILabel__setText_Imp(UILabel *self, SEL _cmd, NSString *text)
{
    [self setAndLocalizeText:text];
}

static void swizzled_UILabel__setBackgroundColor_Imp(UILabel *self, SEL _cmd, UIColor *backgroundColor)
{
    (*s_UILabel__setBackgroundColor_Imp)(self, _cmd, backgroundColor);
    
    // The background color is stored as separate associated object, not in the HLSLabelLocalizationInfo object. The reason
    // is that the HLSLabelLocalizationInfo is only attached when the text is first set, while the background color is
    // usually set earlier (i.e. when this object is not available)
    hls_setAssociatedObject(self, s_originalBackgroundColorKey, backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
