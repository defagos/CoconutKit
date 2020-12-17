//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;
@import QuickLook;

NS_ASSUME_NONNULL_BEGIN

/**
 * Simple QLPreviewItem implementation. Should be self-explanatory
 */
@interface HLSPreviewItem : NSObject <QLPreviewItem>

- (instancetype)initWithPreviewItemURL:(nullable NSURL *)previewItemURL previewItemTitle:(nullable NSString *)previewItemTitle NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPreviewItemURL:(nullable NSURL *)previewItemURL;

@end

@interface HLSPreviewItem (Unavailalble)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
