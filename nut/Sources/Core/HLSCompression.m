//
//  HLSCompression.m
//  iPad_CRM
//
//  Created by Samuel Défago on 9/16/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSCompression.h"

// TODO: mmmhhh... EXC_BAD_ACCESS in inflate for small values (8, 12, ...). Crashes when ~8192 bytes have been read.
#define BUFFER_SIZE             1 << 12

#include <zlib.h>

@implementation HLSCompression

+ (NSData *)zlibGzipInflateData:(NSData *)data;
{
    if (! data) {
        return data;
    }
    
    // Stream initialization before calling inflateInit(2)
    z_stream stream;
    memset(&stream, 0, sizeof(z_stream));
    stream.next_in = (Bytef *)[data bytes];
    stream.avail_in = [data length];
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    
    // inflateInit does not allow to inflate gzipped streams. To be able to inflate gzipped streams, inflateInit2
    // must be used. To be able to inflate all streams (regardless of the window size with which they were
    // deflated), use maximal window size (15). To be able to deflate gzip and zlib, add 32 to this value
    // (refer to zlib.h for more information)
    if (inflateInit2(&stream, 15 + 32) != Z_OK) {
        return nil;
    }
    
    // Inflate in chunks until all input stream has been processed
    NSMutableData *inflatedData = [NSMutableData data];
    Byte chunkBuffer[BUFFER_SIZE];
    stream.next_out = chunkBuffer;
    int retValue = Z_OK;
    do {
        // Reset the buffer space
        memset(chunkBuffer, 0, sizeof(chunkBuffer));
        stream.avail_out = BUFFER_SIZE;

        // Inflate more data. Data has been decoded if Z_OK (more data available but output buffer has been filled; 
        // must call inflate again) or Z_STREAM_END (all data decoded; done). In all cases, inflate stops either
        // when the buffer has been filled or if the stream end has been reached
        retValue = inflate(&stream, Z_NO_FLUSH);
        if (retValue != Z_OK && retValue != Z_STREAM_END) {
            // Problem (probably corrupt data, but might be memory exhaustion or dictionary error)
            inflateEnd(&stream);
            return nil;
        }
        
        // Append the chunk to the data already inflated
        [inflatedData appendBytes:chunkBuffer length:sizeof(chunkBuffer)];
    } while (retValue != Z_STREAM_END);
    
    inflateEnd(&stream);
    
    // Input stream successfully inflated
    return [NSData dataWithData:inflatedData];
}

@end
