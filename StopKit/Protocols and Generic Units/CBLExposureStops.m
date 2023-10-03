#import "CBLExposureStops.h"

@interface CBLExposureStops ()
@property (nonatomic, readwrite) BOOL isNegative;
@property (nonatomic, readwrite) NSUInteger wholeStopsFromZero;
@property (nonatomic, readwrite) CBLExposureStopFraction fraction;
@end

@implementation CBLExposureStops

+(BOOL)supportsSecureCoding {
    return YES;
}

+(nonnull CBLExposureStops *)zeroStops {
    return [[self alloc] initWithWholeStops:0 fraction:CBLExposureStopFractionNone isNegative:NO];
}

+(nonnull CBLExposureStops *)stopsFromDecimalValue:(double)decimalValue {

    BOOL isNegative = (decimalValue < 0.0);

    if (isNegative) {
        decimalValue *= -1;
    }

    NSUInteger wholeStops = (NSUInteger)decimalValue;
    decimalValue -= wholeStops;

    CBLExposureStopFraction fraction = CBLExposureStopFractionNone;

    if (decimalValue > 0.2) {
        fraction = CBLExposureStopFractionOneThird;
    }

    if (decimalValue >= 0.4) {
        fraction = CBLExposureStopFractionOneHalf;
    }

    if (decimalValue >= 0.6) {
        fraction = CBLExposureStopFractionTwoThirds;
    }

    if (decimalValue >= 0.9) {
        fraction = CBLExposureStopFractionNone;
        wholeStops++;
    }

    return [[self alloc] initWithWholeStops:wholeStops fraction:fraction isNegative:isNegative];
}

+(nullable NSArray <CBLExposureStops *> *)stopsBetween:(nonnull CBLExposureStops *)from and:(nonnull CBLExposureStops *)to including:(CBLExposureStopFraction)fractions {

    if (from == nil || to == nil) {
        return nil;
    }

    if ([from isEqual:to]) {
        return @[from];
    }

    if ([from compare:to] != NSOrderedAscending) {
        id temp = to;
        to = from;
        from = temp;
    }

    CBLExposureStops *oneStop = [CBLExposureStops stopsFromDecimalValue:1.0];
    CBLExposureStops *thirdStop = [CBLExposureStops stopsFromDecimalValue:0.33];
    CBLExposureStops *halfStop = [CBLExposureStops stopsFromDecimalValue:0.5];
    CBLExposureStops *twoThirdStop = [CBLExposureStops stopsFromDecimalValue:0.66];

    NSMutableArray *values = [NSMutableArray new];
    [values addObject:from];
    CBLExposureStops *lastWholeValue = from;
    CBLExposureStops *lastActualValue = from;

    do {

        if (fractions > 0) {
            if ((fractions & CBLExposureStopFractionOneThird) == CBLExposureStopFractionOneThird) {
                lastActualValue = [lastWholeValue stopsByAdding:thirdStop];
                [values addObject:lastActualValue];
                if ([lastActualValue compare:to] != NSOrderedAscending) { break; }
            }

            if ((fractions & CBLExposureStopFractionOneHalf) == CBLExposureStopFractionOneHalf) {
                lastActualValue = [lastWholeValue stopsByAdding:halfStop];
                [values addObject:lastActualValue];
                if ([lastActualValue compare:to] != NSOrderedAscending) { break; }
            }

            if ((fractions & CBLExposureStopFractionTwoThirds) == CBLExposureStopFractionTwoThirds) {
                lastActualValue = [lastWholeValue stopsByAdding:twoThirdStop];
                [values addObject:lastActualValue];
                if ([lastActualValue compare:to] != NSOrderedAscending) { break; }
            }
        }

        lastWholeValue = [lastWholeValue stopsByAdding:oneStop];
        lastActualValue = lastWholeValue;
        [values addObject:lastWholeValue];
        if ([lastActualValue compare:to] != NSOrderedAscending) { break; }

    } while (YES);

    return values;
}

-(nonnull id)init {
    return [self initWithWholeStops:0 fraction:CBLExposureStopFractionNone isNegative:NO];
}

-(nonnull id)initWithWholeStops:(NSUInteger)wholeStops fraction:(CBLExposureStopFraction)fraction isNegative:(BOOL)negative {
    self = [super init];
    if (self) {
        self.wholeStopsFromZero = wholeStops;
        self.fraction = fraction;
        self.isNegative = negative;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeInteger:self.wholeStopsFromZero forKey:@"wholeStops"];
    [aCoder encodeInteger:self.fraction forKey:@"fraction"];
    [aCoder encodeBool:self.isNegative forKey:@"isNegative"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if ([aDecoder containsValueForKey:@"wholeStops"] &&
        [aDecoder containsValueForKey:@"fraction"] &&
        [aDecoder containsValueForKey:@"isNegative"]) {
        return [self initWithWholeStops:[aDecoder decodeIntegerForKey:@"wholeStops"]
                               fraction:[aDecoder decodeIntegerForKey:@"fraction"]
                             isNegative:[aDecoder decodeBoolForKey:@"isNegative"]];
    } else {
        return nil;
    }
}

-(id)copyWithZone:(NSZone *)zone {
    return [[CBLExposureStops alloc] initWithWholeStops:self.wholeStopsFromZero
                                               fraction:self.fraction
                                             isNegative:self.isNegative];
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    CBLExposureStops *otherStops = object;
    return otherStops.isNegative == self.isNegative &&
    otherStops.wholeStopsFromZero == self.wholeStopsFromZero &&
    otherStops.fraction == self.fraction;
}

-(NSComparisonResult)compare:(nonnull CBLExposureStops *)other {

    double otherDecimal = other.approximateDecimalValue;
    double thisDecimal = self.approximateDecimalValue;

    if (otherDecimal < thisDecimal) {
        return NSOrderedDescending;
    } else if (otherDecimal > thisDecimal) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

-(nonnull NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [super description], [self succinctDescription]];
}

-(nonnull NSString *)succinctDescription {

    NSString *fractionString = @"";
    if (self.fraction == CBLExposureStopFractionTwoThirds) {
        fractionString = @" 2/3";
    } else if (self.fraction == CBLExposureStopFractionOneHalf) {
        fractionString = @" 1/2";
    } else if (self.fraction == CBLExposureStopFractionOneThird) {
        fractionString = @" 1/3";
    }

    return [NSString stringWithFormat:@"%@%@%@ stops",
            self.isNegative ? @"-" : @"",
            @(self.wholeStopsFromZero),
            fractionString];
}

-(nonnull CBLExposureStops *)stopsByAdding:(nonnull CBLExposureStops *)stops {
    return [CBLExposureStops stopsFromDecimalValue:self.approximateDecimalValue + stops.approximateDecimalValue];
}

-(nonnull CBLExposureStops *)differenceFrom:(nonnull CBLExposureStops *)stops {
    return [CBLExposureStops stopsFromDecimalValue:self.approximateDecimalValue - stops.approximateDecimalValue];
}

-(double)approximateDecimalValue {

    double value = (double)self.wholeStopsFromZero;
    switch (self.fraction) {
        case CBLExposureStopFractionOneThird:
            value += (1.0 / 3.0);
            break;

        case CBLExposureStopFractionOneHalf:
            value += (1.0 / 2.0);
            break;

        case CBLExposureStopFractionTwoThirds:
            value += (2.0 / 3.0);
            break;

        default:
            break;
    }

    if (self.isNegative) {
        value *= -1;
    }

    return value;
}

@end
