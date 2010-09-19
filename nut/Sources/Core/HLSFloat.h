//
//  HLSFloat.h
//  nut
//
//  Created by Samuel Défago on 9/19/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#define HLS_FLOAT_DEFAULT_MAX_DIST              5

#define floateq(x, y)                       floateq_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)
#define doubleeq(x, y)                      doubleeq_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)

#define floatle(x, y)                       floatle_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)
#define floatge(x, y)                       floatge_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)
#define floatlt(x, y)                       floatlt_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)
#define floatgt(x, y)                       floatgt_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)

#define doublele(x, y)                      doublele_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)
#define doublege(x, y)                      doublege_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)
#define doublelt(x, y)                      doublelt_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)
#define doublegt(x, y)                      doublegt_dist((x), (y), HLS_FLOAT_DEFAULT_MAX_DIST)

#define floatle_dist(x, y, maxDist)         ((x) < (y) || floateq_dist((x), (y), (maxDist)))
#define floatge_dist(x, y, maxDist)         ((x) > (y) || floateq_dist((x), (y), (maxDist)))
#define floatlt_dist(x, y, maxDist)         ! floatge_dist((x), (y), (maxDist))
#define floatgt_dist(x, y, maxDist)         ! floatle_dist((x), (y), (maxDist))

#define doublele_dist(x, y, maxDist)        ((x) < (y) || doubleeq_dist((x), (y), (maxDist)))
#define doublege_dist(x, y, maxDist)        ((x) > (y) || doubleeq_dist((x), (y), (maxDist)))
#define doublelt_dist(x, y, maxDist)        ! doublege_dist((x), (y), (maxDist))
#define doublegt_dist(x, y, maxDist)        ! doublele_dist((x), (y), (maxDist))

/**
 * Comparison function for floats numbers
 *  @param x First number
 *  @param y Second number
 *  @param maxDist Maximum distance between two (discrete) numbers considered to be equal
 *  @return bool true iff the two numbers are equal
 */
BOOL floateq_dist(float x, float y, int32_t maxDist);

/**
 * Comparison function for double numbers
 *  @param x First number
 *  @param y Second number
 *  @param maxDist Maximum distance between two (discrete) numbers considered to be equal
 *  @return bool true iff the two numbers are equal
 */
BOOL doubleeq_dist(double x, double y, int64_t maxDist);
