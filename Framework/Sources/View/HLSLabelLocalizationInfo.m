//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSLabelLocalizationInfo.h"

#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"

static NSString * const kMissingLocalizedString = @"UILabel_HLSDynamicLocalization_missing";

static NSString *stringForLabelRepresentation(HLSLabelRepresentation representation);

@interface HLSLabelLocalizationInfo ()

@property (nonatomic, copy) NSAttributedString *originalAttributedText;
@property (nonatomic, copy) NSString *localizationKey;
@property (nonatomic, copy) NSString *tableName;
@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic) HLSLabelRepresentation representation;

@end

@implementation HLSLabelLocalizationInfo

#pragma mark Object creation and destruction

- (instancetype)initWithAttributedText:(NSAttributedString *)attributedText tableName:(NSString *)tableName bundleName:(NSString *)bundleName
{
    if (self = [super init]) {
        [self parseAttributedText:attributedText];
        
        self.originalAttributedText = attributedText;
        self.tableName = tableName;
        self.bundleName = bundleName;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Parsing text

- (void)parseAttributedText:(NSAttributedString *)attributedText
{
    static NSString * const kNormalLeadingPrefix = @"LS/";
    static NSString * const kUppercaseLeadingPrefix = @"ULS/";
    static NSString * const kLowercaseLeadingPrefix = @"LLS/";
    static NSString * const kCapitalizedLeadingPrefix = @"CLS/";
    
    NSString *text = attributedText.string;
    
    // Check prefix
    NSString *prefix = nil;
    if ([text hasPrefix:kNormalLeadingPrefix]) {
        self.representation = HLSLabelRepresentationNormal;
        prefix = kNormalLeadingPrefix;
    }
    else if ([text hasPrefix:kUppercaseLeadingPrefix]) {
        self.representation = HLSLabelRepresentationUppercase;
        prefix = kUppercaseLeadingPrefix;
    }
    else if ([text hasPrefix:kLowercaseLeadingPrefix]) {
        self.representation = HLSLabelRepresentationLowercase;
        prefix = kLowercaseLeadingPrefix;
    }
    else if ([text hasPrefix:kCapitalizedLeadingPrefix]) {
        self.representation = HLSLabelRepresentationCapitalized;
        prefix = kCapitalizedLeadingPrefix;
    }
    else {
        // If no leading prefix, we are done
        return;
    }
    
    // Extract localization key
    self.localizationKey = [text stringByReplacingCharactersInRange:NSMakeRange(0, prefix.length) withString:@""];
}

#pragma mark Localizing

- (BOOL)isLocalized
{
    return self.localizationKey != nil;
}

- (BOOL)isIncomplete
{
    // Missing localization key
    if (self.localizationKey.length == 0) {
        return YES;
    }
    
    // Missing translation
    NSBundle *bundle = [NSBundle bundleWithName:self.bundleName];
    if (! bundle) {
        HLSLoggerWarn(@"The bundle %@ was not found", self.bundleName);
        return NO;
    }
    
    NSString *text = [bundle localizedStringForKey:self.localizationKey
                                             value:kMissingLocalizedString
                                             table:self.tableName];
    if ([text isEqualToString:kMissingLocalizedString]) {
        return YES;
    }
    
    return NO;
}

- (NSAttributedString *)localizedAttributedText
{    
    if (! self.localizationKey) {
        return nil;
    }
    
    NSString *text = nil;
    
    // Missing localization key. Return some label to make it clear when the label is displayed on screen
    if (self.localizationKey.length == 0) {
        text = @"(no key)";
    }
    else {
        // We use an explicit constant string for missing localizations since otherwise the localization key itself would
        // be returned by the localizedStringForKey:value:table method
        NSBundle *bundle = [NSBundle bundleWithName:self.bundleName];
        if (! bundle) {
            HLSLoggerWarn(@"The bundle %@ was not found", self.bundleName);
            text = self.localizationKey;
        }
        else {
            text = [bundle localizedStringForKey:self.localizationKey
                                           value:kMissingLocalizedString
                                           table:self.tableName];
            
            // Use the localization key as text if missing
            if ([text isEqualToString:kMissingLocalizedString]) {
                text = self.localizationKey;
            }
            
            // Formatting
            switch (self.representation) {
                case HLSLabelRepresentationUppercase: {
                    text = text.localizedUppercaseString;
                    break;
                }
                    
                case HLSLabelRepresentationLowercase: {
                    text = text.localizedLowercaseString;
                    break;
                }
                    
                case HLSLabelRepresentationCapitalized: {
                    text = text.localizedCapitalizedString;
                    break;
                }
                    
                default: {
                    break;
                }
            }
        }
    }
    
    NSMutableAttributedString *attributedText = [self.originalAttributedText mutableCopy];
    [attributedText replaceCharactersInRange:NSMakeRange(0, attributedText.length) withString:text];
    return [attributedText copy];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; localizationKey: %@; tableName: %@; bundleName: %@; representation: %@>",
            [self class],
            self,
            self.localizationKey,
            self.tableName,
            self.bundleName,
            stringForLabelRepresentation(self.representation)];
}

@end

#pragma mark Helper functions

static NSString *stringForLabelRepresentation(HLSLabelRepresentation representation)
{
    static NSDictionary *s_names;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_names = @{ @(HLSLabelRepresentationNormal) : @"normal",
                     @(HLSLabelRepresentationUppercase) : @"uppercase",
                     @(HLSLabelRepresentationLowercase) : @"lowercase",
                     @(HLSLabelRepresentationCapitalized) : @"capitalized" };
    });
    return s_names[@(representation)] ?: @"unknown";    
}
