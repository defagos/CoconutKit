//
//  HLSStandardView.m
//  nut
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSStandardView.h"

#import "HLSLogger.h"
#import "HLSStandardWidgetConstants.h"
#import "NSObject+HLSExtensions.h"

@implementation HLSStandardView

#pragma mark Factory methods

+ (UIView *)view
{   
    if ([self isMemberOfClass:[HLSStandardView class]]) {
        logger_error(@"HLSStandardView cannot be instantiated directly");
        return nil;
    }
    
    // A xib has been found, use it
    if ([[NSBundle mainBundle] pathForResource:[self xibFileName] ofType:@"nib"]) {
        NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:[self xibFileName] owner:self options:nil];
        return [bundleContents objectAtIndex:0];
    }
    else {
        logger_error(@"xib file not found");
        return nil;
    }
}

#pragma mark Class methods

+ (CGFloat)height
{
    return kViewStandardHeight;
}

+ (NSString *)xibFileName
{
    return [self className];
}

@end
