//
//  HLSWeakObjectWrapper.m
//  CoconutKit
//
//  Created by Samuel Defago on 21/11/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSWeakObjectWrapper.h"

@interface HLSWeakObjectWrapper ()

@property (nonatomic, weak) id object;

@end

@implementation HLSWeakObjectWrapper

- (instancetype)initWithObject:(id)object
{
    if (self = [super init]) {
        self.object = object;
    }
    return self;
}

@end
