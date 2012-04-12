//
//  UIImageView+HLSURLConnection.h
//  CoconutKit
//
//  Created by Samuel Défago on 11.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSURLConnection.h"

@interface UIImageView (HLSURLConnection) <HLSURLConnectionDelegate>

- (void)loadWithImageRequest:(NSURLRequest *)request;

// TODO: Document the cache policy used, or get rid of this method (after all, NSURLRequest is far more flexible, this
//       shortcut method is not really useful)
- (void)loadWithImageAtURL:(NSURL *)url;

@end
