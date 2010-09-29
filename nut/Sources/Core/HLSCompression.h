//
//  GZipAdditions.h
//  nut
//
//  Created by Samuel Défago on 9/16/10.
//  Copyright 2010 Hortis. All rights reserved.
//

@interface HLSCompression : NSObject {
@private
    
}

/**
 * Inflate zlib and gzip data. Return nil on failure (most probably invalid data)
 */
+ (NSData *)zlibGzipInflateData:(NSData *)data;

@end
