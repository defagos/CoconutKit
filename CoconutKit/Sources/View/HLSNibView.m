//
//  HLSNibView.m
//  CoconutKit
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSNibView.h"

#import "HLSLogger.h"
#import "NSArray+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToSizeMap = nil;

@implementation HLSNibView

#pragma mark Class methods for creation

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [HLSNibView class]) {
        return;
    }
    
    s_classNameToSizeMap = [[NSMutableDictionary dictionary] retain];
}

+ (id)view
{   
    if ([self isMemberOfClass:[HLSNibView class]]) {
        HLSLoggerError(@"HLSNibView cannot be instantiated directly");
        return nil;
    }
    
    NSBundle *bundle = [self bundle] ?: [NSBundle mainBundle];
    
    // A xib has been found, use it
    NSString *nibName = [self nibName];
    if ([bundle pathForResource:nibName ofType:@"nib"]) {
        NSArray *bundleContents = [bundle loadNibNamed:nibName owner:nil options:nil];
        if ([bundleContents count] == 0) {
            HLSLoggerError(@"Missing view object in xib file %@", nibName);
            return nil;
        }
        
        // Get the first object and check that it is what we expect
        id firstObject = [bundleContents firstObject];
        if (! [firstObject isKindOfClass:self]) {
            HLSLoggerError(@"The view object must be the first one in the xib file, and must be of type %@", [self className]);
            return nil;
        }
        
        return firstObject;
    }
    else {
        HLSLoggerError(@"xib file not found");
        return nil;
    }
}

#pragma mark Class methods for customisation

+ (CGFloat)height
{
    return [self size].height;
}

+ (CGFloat)width
{
    return [self size].width;
}

+ (CGSize)size
{
    // Cache the view height
    NSValue *viewSizeValue = [s_classNameToSizeMap objectForKey:[self className]];
    if (! viewSizeValue) {
        UIView *view = [self view];
        viewSizeValue = [NSValue valueWithCGSize:view.bounds.size];
        [s_classNameToSizeMap setObject:viewSizeValue forKey:[self className]];
    }
    return [viewSizeValue CGSizeValue];
}

+ (NSString *)nibName
{
    return [self className];
}

+ (NSBundle *)bundle
{
    return nil;
}

@end
