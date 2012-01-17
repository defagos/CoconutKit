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
    self.originalBackgroundColor = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize localizationKey = m_localizationKey;

@synthesize table = m_table;

@synthesize representation = m_representation;

@synthesize originalBackgroundColor = m_originalBackgroundColor;

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
    NSString *leadingPrefix = [components firstObject];
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
        HLSLoggerWarn(@"Leading localization prefix %@ detected, but empty localization key", [components firstObject]);
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
            HLSLoggerWarn(@"Table name prefix detected, but empty table name", [components firstObject]);
        }
        
        self.table = table;
    }
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
