//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIProgressView+HLSViewBinding.h"

@implementation UIProgressView (HLSViewBindingImplementation)

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    [self setProgress:[value floatValue] animated:animated];
}

@end
