//
//  HLSFloat.m
//  nut
//
//  Created by Samuel Défago on 9/19/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSFloat.h"

#import "HLSAssert.h"

/**
 * For a discussion of float comparison functions, see
 *   http://www.cygnus-software.com/papers/comparingfloats/comparingfloats.htm
 */

BOOL floateq_dist(float x, float y, int32_t maxDist)
{
    HLS_STATIC_ASSERT(sizeof(float) == sizeof(int32_t));
    
    int32_t i_x = *(int32_t *)&x;
    if (i_x < 0) {
        i_x = 0x80000000L - i_x;
    }
    
    int32_t i_y = *(int32_t *)&y;
    if (i_y < 0) {
        i_y = 0x80000000L - i_y;
    }
    
    return(abs(i_x - i_y) <= maxDist);
}

BOOL doubleeq_dist(double x, double y, int64_t maxDist)
{
    HLS_STATIC_ASSERT(sizeof(double) == sizeof(int64_t));
    
    int64_t i_x = *(int64_t *)&x;
    if (i_x < 0) {
        i_x = 0x8000000000000000LL - i_x;
    }
    
    int64_t i_y = *(int64_t *)&y;
    if (i_y < 0) {
        i_y = 0x8000000000000000LL - i_y;
    }
    
    return(llabs(i_x - i_y) <= maxDist);
}

float floatmin_dist(float x, float y, int32_t maxDist)
{
    return floatlt_dist(x, y, maxDist) ? x : y;
}

float floatmax_dist(float x, float y, int32_t maxDist)
{
    return floatlt_dist(x, y, maxDist) ? y : x;
}

float doublemin_dist(double x, double y, int64_t maxDist)
{
    return doublelt_dist(x, y, maxDist) ? x : y;
}

float doublemax_dist(double x, double y, int64_t maxDist)
{
    return doublelt_dist(x, y, maxDist) ? y : x;
}
