//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

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
