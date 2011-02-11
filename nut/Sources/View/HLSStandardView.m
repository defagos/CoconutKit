//
//  HLSStandardView.m
//  nut
//
//  Created by Samuel Défago on 9/1/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSStandardView.h"

#import "NSObject+HLSExtensions.h"

@implementation HLSStandardView

#pragma mark Factory methods

+ (UIView *)view
{
    // Load from nib file
    NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:[self className] owner:self options:nil];
    return [bundleContents objectAtIndex:0];
}

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
