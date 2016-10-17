//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSBindingContext.h"

#import "HLSViewBindingInformation.h"

@interface HLSBindingContext ()

@property (nonatomic) HLSViewBindingInformation *bindingInformation;

@end

@implementation HLSBindingContext

#pragma mark Object creation and destruction

- (instancetype)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    NSParameterAssert(bindingInformation);
    
    if (self = [super init]) {
        self.bindingInformation = bindingInformation;
    }
    return self;
}

#pragma mark Accessors

- (id)objectTarget
{
    return self.bindingInformation.objectTarget;
}

- (NSString *)keyPath
{
    return self.bindingInformation.keyPath;
}

- (id)value
{
    return self.bindingInformation.rawValue;
}

- (NSString *)lastKeyPathComponent
{
    return self.bindingInformation.lastKeyPathComponent;
}

- (id)lastObjectTarget
{
    return self.bindingInformation.lastObjectTarget;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; objectTarget: %@; keyPath: %@; value: %@; lastKeyPathComponent: %@; lastObjectTarget: %@>",
            [self class],
            self,
            self.objectTarget,
            self.keyPath,
            self.value,
            self.lastKeyPathComponent,
            self.lastObjectTarget];
}

@end
