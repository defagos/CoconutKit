//
//  HeaderView.m
//  nut-demo
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.label = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize label = m_label;

#pragma mark Class methods

+ (CGFloat)height
{
    // Must match the size of the resource in the xib file
    return 60.f;
}

@end
