//
//  HeaderView.m
//  CoconutKit-demo
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

@end
