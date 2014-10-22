//
//  HLSPreviewItem.h
//  CoconutKit
//
//  Created by Samuel Défago on 29.08.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

/**
 * Simple QLPreviewItem implementation. Should be self-explanatory
 */
@interface HLSPreviewItem : NSObject <QLPreviewItem>

- (instancetype)initWithPreviewItemURL:(NSURL *)previewItemURL previewItemTitle:(NSString *)previewItemTitle NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPreviewItemURL:(NSURL *)previewItemURL;

@end

@interface HLSPreviewItem (Unavailalble)

- (instancetype)init NS_UNAVAILABLE;

@end
