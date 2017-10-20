#import <Foundation/Foundation.h>
#import "CBLExposureStops.h"

#define CBLStopKitLocalizedString(key, table) NSLocalizedStringFromTableInBundle(key, table, [NSBundle bundleForClass:[CBLExposureStops class]], @"")

#define STANDARD_FLOAT_WIGGLE_ROOM 0.0000001
static inline BOOL CBLFloatAlmostEqual(double x, double y, double delta) { return fabs(x - y) <= delta; }
