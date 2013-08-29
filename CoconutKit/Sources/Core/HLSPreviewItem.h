//
//  HLSPreviewItem.h
//  CoconutKit
//
//  Created by Samuel Défago on 29.08.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Simple QLPreviewItem implementation. Should be self-explanatory
 */
@interface HLSPreviewItem : NSObject <QLPreviewItem>

- (id)initWithPreviewItemURL:(NSURL *)previewItemURL previewItemTitle:(NSString *)previewItemTitle;
- (id)initWithPreviewItemURL:(NSURL *)previewItemURL;

@end
