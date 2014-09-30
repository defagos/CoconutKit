//
//  HLSPreviewItem.m
//  CoconutKit
//
//  Created by Samuel Défago on 29.08.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSPreviewItem.h"

#import "HLSAssert.h"

@interface HLSPreviewItem ()

@property (nonatomic, strong) NSURL *previewItemURL;
@property (nonatomic, strong) NSString *previewItemTitle;

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

- (instancetype)init
{
    HLSForbiddenInheritedMethod();
    return [self initWithPreviewItemURL:nil previewItemTitle:nil];
}

@end
