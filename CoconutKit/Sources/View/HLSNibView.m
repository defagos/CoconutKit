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
#import "NSBundle+HLSExtensions.h"
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
    
    s_classNameToSizeMap = [NSMutableDictionary dictionary];
}

+ (instancetype)view
{   
    if ([self isMemberOfClass:[HLSNibView class]]) {
        HLSLoggerError(@"HLSNibView cannot be instantiated directly");
        return nil;
    }
    
    NSBundle *bundle = [self bundle] ?: [NSBundle principalBundle];
    
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
        
        HLSNibView *view = firstObject;
        return view;
    }
    else {
        HLSLoggerError(@"xib file not found");
        return nil;
    }
}

#pragma mark Overrides

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    // If no child views, consider we are deserializing a placeholder, and thus must return a properly instantiated view
    // instead
    if ([self.subviews count] == 0) {
        HLSNibView *nibView = [[self class] view];
        nibView.frame = self.frame;
        nibView.alpha = self.alpha;
        nibView.autoresizingMask = self.autoresizingMask;
        
        // Avoid conflicts with constraints generated from autoresizing masks
        nibView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Replace constraints defined for the placeholder view with same constraints applied to the nib-instantiated view
        for (NSLayoutConstraint *placeholderConstraint in self.superview.constraints) {
            // Skip constraints which do not involve the placeholder
            if (placeholderConstraint.firstItem != self && placeholderConstraint.secondItem != self) {
                continue;
            }
            
            NSLayoutConstraint *constraint = nil;
            if (placeholderConstraint.firstItem == self && placeholderConstraint.secondItem == self) {
                constraint = [NSLayoutConstraint constraintWithItem:nibView
                                                          attribute:placeholderConstraint.firstAttribute
                                                          relatedBy:placeholderConstraint.relation
                                                             toItem:nibView
                                                          attribute:placeholderConstraint.secondAttribute
                                                         multiplier:placeholderConstraint.multiplier
                                                           constant:placeholderConstraint.constant];
            }
            else if (placeholderConstraint.firstItem == self) {
                constraint = [NSLayoutConstraint constraintWithItem:nibView
                                                          attribute:placeholderConstraint.firstAttribute
                                                          relatedBy:placeholderConstraint.relation
                                                             toItem:placeholderConstraint.secondItem
                                                          attribute:placeholderConstraint.secondAttribute
                                                         multiplier:placeholderConstraint.multiplier
                                                           constant:placeholderConstraint.constant];
            }
            else {
                constraint = [NSLayoutConstraint constraintWithItem:placeholderConstraint.firstItem
                                                          attribute:placeholderConstraint.firstAttribute
                                                          relatedBy:placeholderConstraint.relation
                                                             toItem:nibView
                                                          attribute:placeholderConstraint.secondAttribute
                                                         multiplier:placeholderConstraint.multiplier
                                                           constant:placeholderConstraint.constant];
            }
            
            // Copy constraint properties
            constraint.identifier = placeholderConstraint.identifier;
            constraint.shouldBeArchived = placeholderConstraint.shouldBeArchived;
            constraint.priority = placeholderConstraint.priority;
            constraint.active = placeholderConstraint.active;
            
            // Replace
            [self.superview removeConstraint:placeholderConstraint];
            [self.superview addConstraint:constraint];
        }
        return nibView;
    }
    else {
        return self;
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
