//
//  HLSLabelLocalizationInfo.m
//  CoconutKit
//
//  Created by Samuel Défago on 12.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLabelLocalizationInfo.h"

#import "HLSAssert.h"
#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"

static NSString * const kMissingLocalizedString = @"UILabel_HLSDynamicLocalization_missing";

static NSString *stringForLabelRepresentation(HLSLabelRepresentation representation);

@interface HLSLabelLocalizationInfo ()

@property (nonatomic, retain) NSString *localizationKey;
@property (nonatomic, retain) NSString *table;
@property (nonatomic, assign) HLSLabelRepresentation representation;

- (void)parseText:(NSString *)text;

@end

@implementation HLSLabelLocalizationInfo

#pragma mark Object creation and destruction

- (id)initWithText:(NSString *)text
{
    if ((self = [super init])) {
        [self parseText:text];
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.localizationKey = nil;
    self.table = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize localizationKey = m_localizationKey;

@synthesize table = m_table;

@synthesize representation = m_representation;

@synthesize locked = m_locked;

#pragma mark Parsing text

- (void)parseText:(NSString *)text
{
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
    NSArray *components = [text componentsSeparatedByString:kSeparator];
    if ([components count] == 0) {
        return;
    }
    
    // If no leading prefix, we are done
    NSString *leadingPrefix = [components firstObject_hls];
    if (! [s_leadingPrefixes containsObject:leadingPrefix]) {
        return;
    }
    
    // Extract representation
    if ([leadingPrefix isEqualToString:kUppercaseLeadingPrefix]) {
        self.representation = HLSLabelRepresentationUppercase;
    }
    else if ([leadingPrefix isEqualToString:kLowercaseLeadingPrefix]) {
        self.representation = HLSLabelRepresentationLowercase;
    }
    else if ([leadingPrefix isEqualToString:kCapitalizedLeadingPrefix]) {
        self.representation = HLSLabelRepresentationCapitalized;
    }
    else {
        self.representation = HLSLabelRepresentationNormal;
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
        HLSLoggerWarn(@"Leading localization prefix %@ detected, but empty localization key", [components firstObject_hls]);
    }
    self.localizationKey = localizationKey;
    
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
            HLSLoggerWarn(@"Table name prefix detected, but empty table name");
        }
        
        self.table = table;
    }
}

#pragma mark Localizing

- (BOOL)isLocalized
{
    return self.localizationKey != nil;
}

- (BOOL)isIncomplete
{
    // Missing localization key
    if ([self.localizationKey length] == 0) {
        return YES;
    }
    
    // Missing translation
    NSString *text = [[NSBundle mainBundle] localizedStringForKey:self.localizationKey
                                                            value:kMissingLocalizedString
                                                            table:self.table];
    if ([text isEqualToString:kMissingLocalizedString]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)localizedText
{    
    if (! self.localizationKey) {
        return nil;
    }
    
    // Missing localization key. Return some label to make it clear when the label is displayed on screenyy
    if ([self.localizationKey length] == 0) {
        return @"(no key)";
    }
    
    // We use an explicit constant string for missing localizations since otherwise the localization key itself would 
    // be returned by the localizedStringForKey:value:table method
    NSString *text = [[NSBundle mainBundle] localizedStringForKey:self.localizationKey
                                                            value:kMissingLocalizedString
                                                            table:self.table];
    
    // Use the localization key as text if missing
    if ([text isEqualToString:kMissingLocalizedString]) {
        text = self.localizationKey;
    }
    
    // Formatting
    switch (self.representation) {
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
    
    return text;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; localizationKey: %@; table: %@; representation: %@>", 
            [self class],
            self,
            self.localizationKey,
            self.table,
            stringForLabelRepresentation(self.representation)];
}

@end

#pragma mark Helper functions

static NSString *stringForLabelRepresentation(HLSLabelRepresentation representation)
{
    switch (representation) {
        case HLSLabelRepresentationNormal: {
            return @"normal";
            break;
        }
            
        case HLSLabelRepresentationUppercase: {
            return @"uppercase";
            break;
        }
            
        case HLSLabelRepresentationLowercase: {
            return @"lowercase";
            break;
        }
            
        case HLSLabelRepresentationCapitalized: {
            return @"capitalized";
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown representation");
            return @"unknown";
            break;
        }
    }
}
