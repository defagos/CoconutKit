//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSPreviewItem.h"

@interface HLSPreviewItem ()

@property (nonatomic) NSURL *previewItemURL;
@property (nonatomic, copy) NSString *previewItemTitle;

@end

@implementation HLSPreviewItem

#pragma mark Object creation and destruction

- (instancetype)initWithPreviewItemURL:(NSURL *)previewItemURL previewItemTitle:(NSString *)previewItemTitle
{
    if (self = [super init]) {
        self.previewItemURL = previewItemURL;
        self.previewItemTitle = previewItemTitle;
    }
    return self;
}

- (instancetype)initWithPreviewItemURL:(NSURL *)previewItemURL
{
    return [self initWithPreviewItemURL:previewItemURL previewItemTitle:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (instancetype)init
{
    return nil;
}

#pragma clang diagnostic pop

@end
