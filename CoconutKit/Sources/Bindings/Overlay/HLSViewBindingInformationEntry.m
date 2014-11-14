//
//  HLSViewBindingInformationEntry.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingInformationEntry.h"

#import "HLSRuntime.h"
#import "UIColor+HLSExtensions.h"
#import "UIViewController+HLSExtensions.h"

@interface HLSViewBindingInformationEntry ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) id object;

@end

@implementation HLSViewBindingInformationEntry

#pragma mark Class methods

+ (NSString *)identityStringForObject:(id)object
{
    if (! object || object == [NSNull null]) {
        return nil;
    }
    
    // Class objects: Display class name
    if (hls_isClass(object)) {
        return [NSString stringWithFormat:@"'%@' class", object];
    }
    else {
        return [NSString stringWithFormat:@"%p\n\n(%@)", object, [object class]];
    }
}

#pragma mark Object creation and destruction

- (instancetype)initWithName:(NSString *)name text:(NSString *)text object:(id)object
{
    NSParameterAssert(name);
    
    if (self = [super init]) {
        self.name = name;
        self.object = object;
        
        if (object) {
            self.text = [HLSViewBindingInformationEntry identityStringForObject:object] ?: @"-";
        }
        else {
            self.text = text ?: @"-";
        }
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name text:(NSString *)text
{
    return [self initWithName:name text:text object:nil];
}

- (instancetype)initWithName:(NSString *)name object:(id)object
{
    return [self initWithName:name text:nil object:object];
}

#pragma mark Highlighting

- (UIView *)highlightedView
{
    if ([self.object isKindOfClass:[UIView class]]) {
        return self.object;
    }
    else if ([self.object isKindOfClass:[UIViewController class]]) {
        return [self.object viewIfLoaded];
    }
    else {
        return nil;
    }
}

- (BOOL)canHighlight
{
    return [self highlightedView] != nil;
}

- (void)highlight
{
    UIView *highlightedView = [self highlightedView];
    if (! highlightedView) {
        return;
    }
    
    // Highlight views
    CGFloat alpha = highlightedView.alpha;
    UIColor *backgroundColor = highlightedView.backgroundColor;
    
    [UIView animateWithDuration:0.2 animations:^{
        highlightedView.alpha = alpha / 2.f;
        highlightedView.backgroundColor = [backgroundColor invertedColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            highlightedView.alpha = alpha;
            highlightedView.backgroundColor = backgroundColor;
        }];
    }];
}

@end
