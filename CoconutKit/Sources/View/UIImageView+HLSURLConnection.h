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
- (void)loadWithImageAtURL:(NSURL *)url;

@end
