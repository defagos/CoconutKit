//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "UILabel+HLSViewBinding.h"

#import <objc/runtime.h>

// Associated object keys
static void *s_bindPlaceholderKey = &s_bindPlaceholderKey;

@implementation UILabel (HLSViewBindingImplementation)

#pragma mark Accessors and mutators

- (NSString *)bindPlaceholder
{
    return objc_getAssociatedObject(self, s_bindPlaceholderKey);
}

- (void)setBindPlaceholder:(NSString *)bindPlaceholder
{
    objc_setAssociatedObject(self, s_bindPlaceholderKey, bindPlaceholder, OBJC_ASSOCIATION_COPY);
}

#pragma mark HLSViewBindingImplementation protocol implementation

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    self.text = value ?: self.bindPlaceholder;
}

@end
