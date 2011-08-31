//
//  HLSFloat.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/19/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Default distance used by macros without distance parameter
#define HLSFloatDefaultMaxDist              5

/**
 * Macros for comparing float or double values
 */
#define floatle_dist(x, y, maxDist)         ((x) < (y) || floateq_dist((x), (y), (maxDist)))
#define floatge_dist(x, y, maxDist)         ((x) > (y) || floateq_dist((x), (y), (maxDist)))
#define floatlt_dist(x, y, maxDist)         ! floatge_dist((x), (y), (maxDist))
#define floatgt_dist(x, y, maxDist)         ! floatle_dist((x), (y), (maxDist))

#define doublele_dist(x, y, maxDist)        ((x) < (y) || doubleeq_dist((x), (y), (maxDist)))
#define doublege_dist(x, y, maxDist)        ((x) > (y) || doubleeq_dist((x), (y), (maxDist)))
#define doublelt_dist(x, y, maxDist)        ! doublege_dist((x), (y), (maxDist))
#define doublegt_dist(x, y, maxDist)        ! doublele_dist((x), (y), (maxDist))

#define floateq(x, y)                       floateq_dist((x), (y), HLSFloatDefaultMaxDist)
#define doubleeq(x, y)                      doubleeq_dist((x), (y), HLSFloatDefaultMaxDist)

#define floatle(x, y)                       floatle_dist((x), (y), HLSFloatDefaultMaxDist)
#define floatge(x, y)                       floatge_dist((x), (y), HLSFloatDefaultMaxDist)
#define floatlt(x, y)                       floatlt_dist((x), (y), HLSFloatDefaultMaxDist)
#define floatgt(x, y)                       floatgt_dist((x), (y), HLSFloatDefaultMaxDist)

#define doublele(x, y)                      doublele_dist((x), (y), HLSFloatDefaultMaxDist)
#define doublege(x, y)                      doublege_dist((x), (y), HLSFloatDefaultMaxDist)
#define doublelt(x, y)                      doublelt_dist((x), (y), HLSFloatDefaultMaxDist)
#define doublegt(x, y)                      doublegt_dist((x), (y), HLSFloatDefaultMaxDist)

#define floatmin(x, y)                      floatmin_dist((x), (y), HLSFloatDefaultMaxDist)
#define floatmax(x, y)                      floatmax_dist((x), (y), HLSFloatDefaultMaxDist)

#define doublemin(x, y)                     doublemin_dist((x), (y), HLSFloatDefaultMaxDist)
#define doublemax(x, y)                     doublemax_dist((x), (y), HLSFloatDefaultMaxDist)

/**
 * Comparison function for floating point numbers. The parameter maxDist is the maximum distance between two (discrete)
 * numbers so that they can be considered to be equal
 */
BOOL floateq_dist(float x, float y, uint32_t maxDist);
BOOL doubleeq_dist(double x, double y, uint64_t maxDist);

/**
 * Max / min functions (not macros; this would have provided weaker type-checking)
 */
float floatmin_dist(float x, float y, uint32_t maxDist);
float floatmax_dist(float x, float y, uint32_t maxDist);
double doublemin_dist(double x, double y, uint64_t maxDist);
double doublemax_dist(double x, double y, uint64_t maxDist);
