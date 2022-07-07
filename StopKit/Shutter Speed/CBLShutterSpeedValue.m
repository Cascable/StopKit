#import "CBLShutterSpeedValue.h"
#import "CBLIndeterminateShutterSpeedValue.h"
#import "CBLExposureStops.h"
#import "StopKit+Internal.h"

@interface CBLShutterSpeedValue ()
@property (nonatomic, readwrite) CBLExposureStops *stopsFromASecond;
@property (nonatomic, readwrite) NSNumberFormatter *formatter;
@end

@implementation CBLShutterSpeedValue

+(nonnull CBLShutterSpeedValue *)oneSecondShutterSpeed {
    return [[CBLShutterSpeedValue alloc] initWithStopsFromASecond:[CBLExposureStops stopsFromDecimalValue:0.0]];
}

+(nonnull CBLShutterSpeedValue *)oneTwoHundredFiftiethShutterSpeed {
    return [[self oneSecondShutterSpeed] valueByAddingStops:[CBLExposureStops stopsFromDecimalValue:-8.0]];
}

+(nonnull CBLShutterSpeedValue *)bulbShutterSpeed {
    static dispatch_once_t bulbOnceToken;
    static CBLShutterSpeedValue *bulb = nil;
    dispatch_once(&bulbOnceToken, ^{
        bulb = [[CBLIndeterminateShutterSpeedValue alloc] initWithName:@"BulbValue"];
    });
    return bulb;
}

+(nonnull CBLShutterSpeedValue *)automaticShutterSpeed {
    static dispatch_once_t autoOnceToken;
    static CBLShutterSpeedValue *automatic = nil;
    dispatch_once(&autoOnceToken, ^{
        automatic = [[CBLIndeterminateShutterSpeedValue alloc] initWithName:@"AutoValue"];
    });
    return automatic;
}

+(nullable NSArray *)shutterSpeedsBetween:(nonnull CBLShutterSpeedValue *)low and:(nonnull CBLShutterSpeedValue *)high {

    if (low == nil || high == nil) {
        return nil;
    }

    if ([low isEqual:high]) {
        return @[low];
    }

    if ([low compare:high] != NSOrderedAscending) {
        id temp = high;
        high = low;
        low = temp;
    }

    NSMutableArray *speeds = [NSMutableArray new];
    [speeds addObject:low];
    CBLShutterSpeedValue *lastSpeed = low;

    do {
        lastSpeed = [lastSpeed valueByAddingStops:[CBLExposureStops stopsFromDecimalValue:1.0]];
        [speeds addObject:lastSpeed];
        if ([lastSpeed compare:high] != NSOrderedAscending) {
            break;
        }
    } while (YES);

    return speeds;
}

-(nonnull id)init {
    return [self initWithStopsFromASecond:[CBLExposureStops zeroStops]];
}

-(nonnull id)initWithStopsFromASecond:(nonnull CBLExposureStops *)stops {
    self = [super init];
    if (self) {
        self.stopsFromASecond = stops;
        self.formatter = [[NSNumberFormatter alloc] init];
        self.formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.formatter.usesGroupingSeparator = NO;
        self.formatter.maximumFractionDigits = 1;
    }
    return self;
}

-(nullable id)initWithApproximateDuration:(NSTimeInterval)interval {

    if (interval <= 0.0) {
        return nil;
    }

    double stops = log(interval)/log(2.0);
    return [self initWithStopsFromASecond:[CBLExposureStops stopsFromDecimalValue:stops]];
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.stopsFromASecond forKey:@"stops"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if ([aDecoder containsValueForKey:@"stops"]) {
        return [self initWithStopsFromASecond:[aDecoder decodeObjectOfClass:[CBLExposureStops class] forKey:@"stops"]];
    } else {
        return nil;
    }
}

-(id)copyWithZone:(NSZone *)zone {
    return [[CBLShutterSpeedValue alloc] initWithStopsFromASecond:self.stopsFromASecond];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [super description], self.succinctDescription];
}

-(nonnull NSString *)succinctDescription {
    if (self.approximateTimeInterval < 0.3) {
        return self.fractionalRepresentation;
    } else {
        return [NSString stringWithFormat:@"%1.1f\"", self.approximateTimeInterval];
    }
}

-(NSString *)localizedDisplayValue {

    if (self.approximateTimeInterval < 0.3) {
        // Return 1/x representation.
        return [NSString stringWithFormat:@"%@%@",
                CBLStopKitLocalizedString(@"OneOver", @"UniversalShutterSpeeds"),
                @([CBLShutterSpeedValue significantFractionIntegerForStopsFromASecond:self.stopsFromASecond])];
    } else {
        // Return decimal representation.
        return [self.formatter stringFromNumber:@(self.approximateTimeInterval)];
    }
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]] || [object isKindOfClass:[CBLIndeterminateShutterSpeedValue class]]) {
        return NO;
    }

    return [self.stopsFromASecond isEqual:[object stopsFromASecond]];
}

-(BOOL)isDeterminate {
    return YES;
}

-(BOOL)isBulb {
    return NO;
}

-(NSComparisonResult)compare:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return CBLExposureComparisonInvalid;
    }

    return [self.stopsFromASecond compare:[(CBLShutterSpeedValue *)value stopsFromASecond]];
}

-(nullable CBLExposureStops *)stopsDifferenceFrom:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return nil;
    }

    return [self.stopsFromASecond differenceFrom:[(CBLShutterSpeedValue *)value stopsFromASecond]];
}

-(NSTimeInterval)approximateTimeInterval {

    CBLExposureStops *stops = self.stopsFromASecond;

    if (stops.wholeStopsFromZero < 2) {
        // These ranges have trouble as our fractions are integral. Special case these.
        if (stops.wholeStopsFromZero == 0) {
            if (stops.isNegative) {
                if (stops.fraction == CBLExposureStopFractionNone) {
                    return 1.0;
                } else if (stops.fraction == CBLExposureStopFractionOneThird) {
                    return 0.8;
                } else if (stops.fraction == CBLExposureStopFractionOneHalf) {
                    return 0.7;
                } else if (stops.fraction == CBLExposureStopFractionTwoThirds) {
                    return 0.6;
                }
            } else {
                if (stops.fraction == CBLExposureStopFractionNone) {
                    return 1.0;
                } else if (stops.fraction == CBLExposureStopFractionOneThird) {
                    return 1.3;
                } else if (stops.fraction == CBLExposureStopFractionOneHalf) {
                    return 1.5;
                } else if (stops.fraction == CBLExposureStopFractionTwoThirds) {
                    return 1.6;
                }
            }
        } else if (stops.wholeStopsFromZero == 1) {
            if (stops.isNegative) {
                if (stops.fraction == CBLExposureStopFractionNone) {
                    return 0.5;
                } else if (stops.fraction == CBLExposureStopFractionOneThird) {
                    return 0.4;
                } else if (stops.fraction == CBLExposureStopFractionOneHalf) {
                    return 0.3;
                } else if (stops.fraction == CBLExposureStopFractionTwoThirds) {
                    return 0.3;
                }
            } else {
                if (stops.fraction == CBLExposureStopFractionNone) {
                    return 2.0;
                } else if (stops.fraction == CBLExposureStopFractionOneThird) {
                    return 2.5;
                } else if (stops.fraction == CBLExposureStopFractionOneHalf) {
                    return 3.0;
                } else if (stops.fraction == CBLExposureStopFractionTwoThirds) {
                    return 3.2;
                }
            }
        }
    }

    NSUInteger upper = [self upperFractionalValue];
    NSUInteger lower = [self lowerFractionalValue];
    return (double)upper / (double)lower;
}

-(nonnull NSString *)fractionalRepresentation {
    return [NSString stringWithFormat:@"%@/%@", @([self upperFractionalValue]), @([self lowerFractionalValue])];
}

-(NSUInteger)lowerFractionalValue {
    if (!self.stopsFromASecond.isNegative) {
        return 1;
    } else {
        return [CBLShutterSpeedValue significantFractionIntegerForStopsFromASecond:self.stopsFromASecond];
    }
}

-(NSUInteger)upperFractionalValue {
    if (!self.stopsFromASecond.isNegative) {
        return [CBLShutterSpeedValue significantFractionIntegerForStopsFromASecond:self.stopsFromASecond];
    } else {
        return 1;
    }
}

-(nullable CBLShutterSpeedValue *)valueByAddingStops:(nonnull CBLExposureStops *)stops {
    return [[CBLShutterSpeedValue alloc] initWithStopsFromASecond:[self.stopsFromASecond stopsByAdding:stops]];
}

#define SHUTTER_SPEED_MATHEMATICALLY_CORRECT 0

+(NSUInteger)significantFractionIntegerForStopsFromASecond:(CBLExposureStops *)stops {

    if (SHUTTER_SPEED_MATHEMATICALLY_CORRECT) {
        return pow(2.0, stops.approximateDecimalValue);
    }

    // In reality, cameras don't use mathematically correct shutter speeds for the given
    // number of stops, because reasons. We'll use Canon rounding here.
    NSUInteger value = 1;
    for (NSUInteger i = 0; i < stops.wholeStopsFromZero; i++) {
        if (value == 8) {
            value = 15;
        } else if (value == 60) {
            value = 125;
        } else {
            value *= 2;
        }
    }

    CBLExposureStopFraction fraction = stops.fraction;

    if (fraction != CBLExposureStopFractionNone) {
        if (value == 4000) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 5000;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 6000;
            } else {
                value = 6400;
            }

        } else if (value == 2000) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 2500;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 3000;
            } else {
                value = 3200;
            }

        } else if (value == 1000) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 1250;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 1500;
            } else {
                value = 1600;
            }

        } else if (value == 500) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 640;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 750;
            } else {
                value = 800;
            }

        } else if (value == 250) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 320;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 350;
            } else {
                value = 400;
            }

        } else if (value == 125) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 160;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 180;
            } else {
                value = 200;
            }

        } else if (value == 60) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 80;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 90;
            } else {
                value = 100;
            }

        } else if (value == 30) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 40;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 45;
            } else {
                value = 50;
            }

        } else if (value == 15) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 20;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 20;
            } else {
                value = 25;
            }

        } else if (value == 8) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 10;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 10;
            } else {
                value = 13;
            }

        } else if (value == 4) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 5;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 6;
            } else {
                value = 6;
            }

        } else if (value == 2) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 3;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 3;
            } else {
                value = 3;
            }

        } else if (value == 1) {
            if (fraction == CBLExposureStopFractionOneThird) {
                value = 1;
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value = 1;
            } else {
                value = 1;
            }

        } else {
            // Previously unknown values.
            if (fraction == CBLExposureStopFractionOneThird) {
                value += (value * 0.333333);
            } else if (fraction == CBLExposureStopFractionOneHalf) {
                value += (value * 0.5);
            } else {
                value += (value * 0.666666);
            }
        }
    }

    // Manual correction for extended Sony values.
    if (value == 26666 && fraction == CBLExposureStopFractionTwoThirds) {
        value = 25600;
    } else if (value == 21333 && fraction == CBLExposureStopFractionOneThird) {
        value = 20000;
    } else if (value == 13333 && fraction == CBLExposureStopFractionTwoThirds) {
        value = 12800;
    } else if (value == 10666 && fraction == CBLExposureStopFractionOneThird) {
        value = 10000;
    }

    return value;
}

@end
