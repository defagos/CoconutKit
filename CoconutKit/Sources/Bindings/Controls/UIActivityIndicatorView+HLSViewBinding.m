//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "UIActivityIndicatorView+HLSViewBinding.h"

@implementation UIActivityIndicatorView (HLSViewBinding)

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    if ([value boolValue]) {
        [self startAnimating];
    }
    else {
        [self stopAnimating];
    }
}

@end
