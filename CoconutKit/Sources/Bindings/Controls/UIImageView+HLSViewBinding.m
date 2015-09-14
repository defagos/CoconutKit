//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UIImageView+HLSViewBinding.h"

@implementation UIImageView (HLSViewBinding)

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[UIImage class], [NSString class], [NSURL class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    if ([value isKindOfClass:[UIImage class]]) {
        self.image = value;
    }
    else if ([value isKindOfClass:[NSString class]]) {
        UIImage *image = [UIImage imageNamed:value];
        if (! image) {
            image = [UIImage imageWithContentsOfFile:value];
        }
        self.image = image;
    }
    else {
        NSURL *URL = value;
        self.image = [URL isFileURL] ? [UIImage imageWithContentsOfFile:[URL path]] : nil;
    }
}

@end
