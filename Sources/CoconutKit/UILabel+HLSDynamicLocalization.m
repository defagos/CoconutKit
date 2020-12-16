//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
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
static void (*s_dealloc)(__unsafe_unretained id, SEL) = NULL;
static void (*s_awakeFromNib)(id, SEL) = NULL;
static void (*s_setText)(id, SEL, id) = NULL;
static void (*s_setAttributedText)(id, SEL, id) = NULL;
static void (*s_setBackgroundColor)(id, SEL, id) = NULL;

// Swizzled method implementations
static void swizzle_dealloc(__unsafe_unretained UILabel *self, SEL _cmd);
static void swizzle_awakeFromNib(UILabel *self, SEL _cmd);
static void swizzle_setText(UILabel *self, SEL _cmd, NSString *text);
static void swizzle_setAttributedText(UILabel *self, SEL _cmd, NSAttributedString *attributedText);
static void swizzle_setBackgroundColor(UILabel *self, SEL _cmd, UIColor *backgroundColor);

@interface UILabel (HLSDynamicLocalizationPrivate)

@property (nonatomic) HLSLabelLocalizationInfo *localizationInfo;

- (void)setAndLocalizeAttributedText:(NSAttributedString *)attributedText text:(NSString *)text;
- (void)localizeWithLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo;

- (void)currentLocalizationDidChange:(NSNotification *)notification;

@end

@interface UIView (HLSDynamicLocalizationPrivate)

@property (nonatomic, copy) NSString *locTable;
@property (nonatomic, copy) NSString *locBundle;

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
    HLSSwizzleSelector(self, sel_getUid("dealloc"), swizzle_dealloc, &s_dealloc);
    HLSSwizzleSelector(self, @selector(awakeFromNib), swizzle_awakeFromNib, &s_awakeFromNib);
    HLSSwizzleSelector(self, @selector(setText:), swizzle_setText, &s_setText);
    HLSSwizzleSelector(self, @selector(setAttributedText:), swizzle_setAttributedText, &s_setAttributedText);
    HLSSwizzleSelector(self, @selector(setBackgroundColor:), swizzle_setBackgroundColor, &s_setBackgroundColor);
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
        return buttonStateToLocalizationInfoMap[buttonStateKey];
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
        
        hls_setAssociatedObject(button, s_localizationInfosKey, buttonStateToLocalizationInfoMap, HLS_ASSOCIATION_STRONG_NONATOMIC);
    }
    // Standalone label
    else {
        hls_setAssociatedObject(self, s_localizationInfosKey, localizationInfo, HLS_ASSOCIATION_STRONG_NONATOMIC);
    }
}

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
- (void)setAndLocalizeAttributedText:(NSAttributedString *)attributedText text:(NSString *)text
{
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    if (! localizationInfo) {
        NSString *tableName = self.locTable;
        if (! tableName) {
            UIView *parentView = self.superview;
            while (parentView && ! parentView.locTable.filled) {
                parentView = parentView.superview;
            }
            tableName = parentView.locTable;
        }
        
        NSString *bundleName = self.locBundle;
        if (! bundleName) {
            UIView *parentView = self.superview;
            while (parentView && ! parentView.locBundle.filled) {
                parentView = parentView.superview;
            }
            bundleName = parentView.locBundle;
        }
        
        localizationInfo = [[HLSLabelLocalizationInfo alloc] initWithAttributedText:attributedText text:text tableName:tableName bundleName:bundleName];
        [self setLocalizationInfo:localizationInfo];
        
        // For labels localized with prefixes only: Listen to localization change notifications
        if (localizationInfo.localized) {
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(currentLocalizationDidChange:) 
                                                         name:HLSCurrentLocalizationDidChangeNotification 
                                                       object:nil];
        }
    }
    
    // Update the label text
    if (localizationInfo.localized) {
        [self localizeWithLocalizationInfo:localizationInfo];
    }
    else if (attributedText) {
        s_setAttributedText(self, @selector(setAttributedText:), attributedText);
    }
    else {
        s_setText(self, @selector(setText:), text);
    }
}

- (void)localizeWithLocalizationInfo:(HLSLabelLocalizationInfo *)localizationInfo
{
    if (localizationInfo.attributed) {
        NSAttributedString *localizedAttributedText = localizationInfo.localizedAttributedText;
        s_setAttributedText(self, @selector(setAttributedText:), localizedAttributedText);
        
        // Avoid button label truncation when the localization changes (setting the title triggers a sizeToFit), and fixes
        // issues with the button label tint color. If we only change the label text, we namely face some minor issues
        // related to how iOS handles buttons. The expected behavior is:
        //   - the label tint color of buttons changes when clicking on them, if only a title is assigned for the normal
        //     state
        //   - when a popover is displayed, the tint color of button labels is changed (private UIViewVisitorEntertainVisitors)
        // If we only change the label text, not the button title, then buttons behave in both cases as if a title was assigned
        // for the highlighted state, i.e. the label tint color will not change, but the label disappears and reappears when
        // transitioning between states
        if ([self.superview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)self.superview;
            [button setAttributedTitle:localizedAttributedText forState:button.state];
        }
    }
    else {
        NSString *localizedText = localizationInfo.localizedText;
        s_setText(self, @selector(setText:), localizedText);
        
        // See above
        if ([self.superview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)self.superview;
            [button setTitle:localizedText forState:button.state];
        }
    }
    
    // Restore the original background color if it had been altered
    UIColor *originalBackgroundColor = hls_getAssociatedObject(self, s_originalBackgroundColorKey);
    s_setBackgroundColor(self, @selector(setBackgroundColor:), originalBackgroundColor);
    
    // Make labels with missing localizations visible (saving the original color first)
    if (s_missingLocalizationsVisible) {
        if (localizationInfo.incomplete) {
            // Using the original implementation here. We do not want to update the color stored in the information object
            s_setBackgroundColor(self, @selector(setBackgroundColor:), [UIColor yellowColor]);
        }
    }
}

#pragma mark Notification callbacks

- (void)currentLocalizationDidChange:(NSNotification *)notification
{
    HLSLabelLocalizationInfo *localizationInfo = [self localizationInfo];
    if (localizationInfo.localized) {
        [self localizeWithLocalizationInfo:localizationInfo];
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
    hls_setAssociatedObject(self, s_localizationTableNameKey, locTable, HLS_ASSOCIATION_STRONG_NONATOMIC);
}

- (NSString *)locBundle
{
    return hls_getAssociatedObject(self, s_localizationBundleNameKey);
}

- (void)setLocBundle:(NSString *)locBundle
{
    hls_setAssociatedObject(self, s_localizationBundleNameKey, locBundle, HLS_ASSOCIATION_STRONG_NONATOMIC);
}

@end

#pragma mark Swizzled method implementations

// Marked as __unsafe_unretained to avoid ARC inserting incorrect memory management calls leading to crashes for -dealloc
static void swizzle_dealloc(__unsafe_unretained UILabel *self, SEL _cmd)
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:HLSCurrentLocalizationDidChangeNotification 
                                                  object:nil];
    
    s_dealloc(self, _cmd);
}

static void swizzle_awakeFromNib(UILabel *self, SEL _cmd)
{
    s_awakeFromNib(self, _cmd);
    
    // Here self.attributedText / self.text return the string filled by deserialization from the nib (which is not set using setAttributedText: / setText:)
    [self setAndLocalizeAttributedText:self.attributedText text:self.text];
}

// Swizzled for UIButton support (!)
static void swizzle_setText(UILabel *self, SEL _cmd, NSString *text)
{
    [self setAndLocalizeAttributedText:nil text:text];
}

static void swizzle_setAttributedText(UILabel *self, SEL _cmd, NSAttributedString *attributedText)
{
    [self setAndLocalizeAttributedText:attributedText text:nil];
}

static void swizzle_setBackgroundColor(UILabel *self, SEL _cmd, UIColor *backgroundColor)
{
    s_setBackgroundColor(self, _cmd, backgroundColor);
    
    // The background color is stored as separate associated object, not in the HLSLabelLocalizationInfo object. The reason
    // is that the HLSLabelLocalizationInfo is only attached when the text is first set, while the background color is
    // usually set earlier (i.e. when this object is not available)
    hls_setAssociatedObject(self, s_originalBackgroundColorKey, backgroundColor, HLS_ASSOCIATION_STRONG_NONATOMIC);
}
