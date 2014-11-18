//
//  HLSNibView.m
//  CoconutKit
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSNibView.h"

#import "HLSLogger.h"
#import "HLSRuntime.h"
#import "NSArray+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToSizeMap = nil;

@implementation HLSNibView {
@private
    BOOL _isPlaceholder;
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

#pragma mark NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        // If no child views, consider we are deserializing a placeholder, and add an instance deserizalized from the nib
        // as subview. We cannot simply return this instance instead of self since decoding would otherwise throw an exception.
        // The view hierarchy contains an extra view level (the placeholder) which can only be later removed. To be able to
        // ensure outlet consistency, this must be made right after decoding, i.e. in -awakeFromNib
        if ([self.subviews count] == 0) {
            _isPlaceholder = YES;
            
            // The view we want to replace the placeholder with, which is complete since deserialized from its nib
            HLSNibView *nibView = [[self class] view];
            [self addSubview:nibView];
        }
    }
    return self;
}

#pragma mark Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (_isPlaceholder) {
        // Replace the placeholder with the nib-instantiated view it contains
        UIView *nibView = [self.subviews firstObject];
        
        // Replace references to the placeholder with references to the nib-instantiated view
        UIResponder *responder = self.superview;
        while (responder) {
            hls_object_replaceReferencesToObject(responder, self, nibView);
            responder = responder.nextResponder;
        }
        
        // Get rid of the placeholder and install the nib-instantiated view instead
        nibView.frame = self.frame;
        [self.superview insertSubview:nibView belowSubview:self];
        [self removeFromSuperview];
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
