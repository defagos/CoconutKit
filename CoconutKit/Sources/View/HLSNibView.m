//
//  HLSNibView.m
//  CoconutKit
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSNibView.h"

#import "HLSLogger.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToHeightMap = nil;

@implementation HLSNibView

#pragma mark Class methods for creation

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [HLSNibView class]) {
        return;
    }
    
    s_classNameToHeightMap = [[NSMutableDictionary dictionary] retain];
}

+ (id)view
{   
    if ([self isMemberOfClass:[HLSNibView class]]) {
        HLSLoggerError(@"HLSNibView cannot be instantiated directly");
        return nil;
    }
    
    // A xib has been found, use it
    NSString *nibName = [self nibName];
    if ([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"]) {
        NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        if ([bundleContents count] == 0) {
            HLSLoggerError(@"Missing view object in xib file %@", nibName);
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
        UIView *view = [self view];
        viewHeight = [NSNumber numberWithFloat:CGRectGetHeight(view.frame)];
        [s_classNameToHeightMap setObject:viewHeight forKey:[self className]];
    }
    return [viewHeight floatValue];
}

+ (NSString *)nibName
{
    return [self className];
}

@end
