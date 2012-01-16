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

@implementation HLSLabelLocalizationInfo

#pragma mark Object creation and destruction

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
