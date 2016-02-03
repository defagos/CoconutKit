//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSNibView.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToSizeMap = nil;

@implementation HLSNibView {
@private
    BOOL _loadedFromPlaceholder;
}

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
    // If no child views, consider we are deserializing a placeholder, and thus return a properly instantiated view instead. Since
    // we are swapping the object when it is deserialized, i.e. early in the process, all constraints which might be applied will
    // correctly reference the replacing object
    if ([self.subviews count] == 0) {
        HLSNibView *nibView = [[self class] view];
        nibView->_loadedFromPlaceholder = YES;
        nibView.frame = self.frame;
        nibView.alpha = self.alpha;
        nibView.autoresizingMask = self.autoresizingMask;
        
        // Copy constraints defined on the placeholder view itself (size constraints)
        for (NSLayoutConstraint *placeholderConstraint in self.constraints) {
            id firstItem = (placeholderConstraint.firstItem == self) ? nibView : placeholderConstraint.firstItem;
            id secondItem = (placeholderConstraint.secondItem == self) ? nibView : placeholderConstraint.secondItem;
            
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                          attribute:placeholderConstraint.firstAttribute
                                                                          relatedBy:placeholderConstraint.relation
                                                                             toItem:secondItem
                                                                          attribute:placeholderConstraint.secondAttribute
                                                                         multiplier:placeholderConstraint.multiplier
                                                                           constant:placeholderConstraint.constant];
            constraint.identifier = placeholderConstraint.identifier;
            constraint.shouldBeArchived = placeholderConstraint.shouldBeArchived;
            constraint.priority = placeholderConstraint.priority;
            
            // TODO: Remove when iOS 8 is the minimum required version for CoconutKit
            if ([constraint respondsToSelector:@selector(isActive)]) {
                constraint.active = placeholderConstraint.active;
            }
            
            [nibView addConstraint:constraint];
        }
        
        return nibView;
    }
    else {
        return self;
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Avoid conflicts with constraints generated from autoresizing masks (if the parent view uses constraints)
    if (_loadedFromPlaceholder && [self.superview.constraints count] > 0) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
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
