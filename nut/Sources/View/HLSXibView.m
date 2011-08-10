//
//  HLSXibView.m
//  nut
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSXibView.h"

#import "HLSLogger.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToHeightMap = nil;

@implementation HLSXibView

#pragma mark Class methods for creation

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [HLSXibView class]) {
        return;
    }
    
    s_classNameToHeightMap = [[NSMutableDictionary dictionary] retain];
}

+ (UIView *)xibView
{   
    if ([self isMemberOfClass:[HLSXibView class]]) {
        HLSLoggerError(@"HLSXibView cannot be instantiated directly");
        return nil;
    }
    
    // A xib has been found, use it
    NSString *xibFileName = [self xibFileName];
    if ([[NSBundle mainBundle] pathForResource:xibFileName ofType:@"nib"]) {
        NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:xibFileName owner:self options:nil];
        if ([bundleContents count] == 0) {
            HLSLoggerError(@"Missing view object in xib file %@", xibFileName);
            return nil;
        }        
        return [bundleContents objectAtIndex:0];
    }
    else {
        HLSLoggerError(@"xib file not found");
        return nil;
    }
}

#pragma mark Class methods for customization

+ (CGFloat)height
{
    // Cache the view height
    NSNumber *viewHeight = [s_classNameToHeightMap objectForKey:[self className]];
    if (! viewHeight) {
        viewHeight = [NSNumber numberWithFloat:CGRectGetHeight([self xibView].frame)];
        [s_classNameToHeightMap setObject:viewHeight forKey:[self className]];
    }
    return [viewHeight floatValue];
}

+ (NSString *)xibFileName
{
    return [self className];
}

@end
