//
//  HLSBindingInformationEntry.m
//  CoconutKit
//
//  Created by Samuel Défago on 04.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSBindingInformationEntry.h"

#import "HLSRuntime.h"

@interface HLSBindingInformationEntry ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) id object;

@end

@implementation HLSBindingInformationEntry

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
    else if ([object isKindOfClass:[UIViewController class]]) {
        return [NSString stringWithFormat:@"%p\n\n(%@)", object, [object class]];
    }
    else {
        return [NSString stringWithFormat:@"%@\n\n(%@)", object, [object class]];
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
            self.text = text ?: [HLSBindingInformationEntry identityStringForObject:object] ?: @"-";
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

@end
