#import "CBLApertureValue.h"
#import "CBLExposureStops.h"
#import "CBLAutoApertureValue.h"
#import "StopKit+Internal.h"

@interface CBLApertureValue ()
@property (nonatomic, readwrite) CBLExposureStops *stopsFromF8;
@property (nonatomic, readwrite) NSNumberFormatter *formatter;
@end

@implementation CBLApertureValue

+(nonnull CBLApertureValue *)automaticAperture {
    static dispatch_once_t autoOnceToken;
    static CBLApertureValue *automatic = nil;
    dispatch_once(&autoOnceToken, ^{
        automatic = [CBLAutoApertureValue new];
    });
    return automatic;
}

+(nonnull CBLApertureValue *)f2Point8 {
    return [self apertureValueWithStopsFromF8:[CBLExposureStops stopsFromDecimalValue:3.0]];
}

+(nonnull CBLApertureValue *)f4 {
    return [self apertureValueWithStopsFromF8:[CBLExposureStops stopsFromDecimalValue:2.0]];
}

+(nonnull CBLApertureValue *)f5Point6 {
    return [self apertureValueWithStopsFromF8:[CBLExposureStops stopsFromDecimalValue:1.0]];
}

+(nonnull CBLApertureValue *)f8 {
    return [self apertureValueWithStopsFromF8:[CBLExposureStops zeroStops]];
}

+(nonnull CBLApertureValue *)f11 {
    return [self apertureValueWithStopsFromF8:[CBLExposureStops stopsFromDecimalValue:-1.0]];
}

+(nonnull CBLApertureValue *)f16 {
    return [self apertureValueWithStopsFromF8:[CBLExposureStops stopsFromDecimalValue:-2.0]];
}

+(nonnull CBLApertureValue *)f22 {
    return [self apertureValueWithStopsFromF8:[CBLExposureStops stopsFromDecimalValue:-3.0]];
}

+(nonnull CBLApertureValue *)apertureValueWithStopsFromF8:(CBLExposureStops *)stops {
    return [[CBLApertureValue alloc] initWithStopsFromF8:stops];
}

-(nonnull id)init {
    return [self initWithStopsFromF8:[CBLExposureStops zeroStops]];
}

-(nonnull instancetype)initWithStopsFromF8:(CBLExposureStops *)stops {
    self = [super init];
    if (self) {
        self.stopsFromF8 = stops;
        self.formatter = [[NSNumberFormatter alloc] init];
        self.formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.formatter.usesGroupingSeparator = NO;
    }
    return self;
}

-(nullable instancetype)initWithApproximateDecimalValue:(double)aperture {

    if (aperture <= 0.0) {
        return nil;
    }

    double stops = log(aperture / 8.0)/log(sqrt(2.0));
    return [self initWithStopsFromF8:[CBLExposureStops stopsFromDecimalValue:stops * -1.0]];
}

-(id)copyWithZone:(NSZone *)zone {
    return [CBLApertureValue apertureValueWithStopsFromF8:self.stopsFromF8];
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.stopsFromF8 isEqual:[object stopsFromF8]];
}

-(BOOL)isDeterminate {
    return YES;
}

-(NSComparisonResult)compare:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return CBLExposureComparisonInvalid;
    }

    return [self.stopsFromF8 compare:[(CBLApertureValue *)value stopsFromF8]];
}

-(nullable id <CBLUniversalExposurePropertyValue>)valueByAddingStops:(nonnull CBLExposureStops *)stops {
    return [CBLApertureValue apertureValueWithStopsFromF8:[self.stopsFromF8 stopsByAdding:stops]];
}

-(nullable CBLExposureStops *)stopsDifferenceFrom:(nonnull id<CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return nil;
    }

    return [self.stopsFromF8 differenceFrom:[(CBLApertureValue *)value stopsFromF8]];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [super description], self.succinctDescription];
}

-(nonnull NSString *)succinctDescription {
    return [NSString stringWithFormat:@"f/%1.1f", self.approximateDecimalValue];
}

-(NSString *)localizedDisplayValue {
    return [self.formatter stringFromNumber:@(self.approximateDecimalValue)];
}

-(double)approximateDecimalValue {
    
    double value = 8.0;

    double fractionalValue = 0.0;
    if (self.stopsFromF8.fraction == CBLExposureStopFractionOneThird) {
        fractionalValue = 1.0/3.0;
    } else if (self.stopsFromF8.fraction == CBLExposureStopFractionOneHalf) {
        fractionalValue = 1.0/2.0;
    } else if (self.stopsFromF8.fraction == CBLExposureStopFractionTwoThirds) {
        fractionalValue = 2.0/3.0;
    }

    if (self.stopsFromF8.isNegative) {
        value *= (pow(sqrt(2.0), self.stopsFromF8.wholeStopsFromZero + fractionalValue));
    } else {
        value /= (pow(sqrt(2.0), self.stopsFromF8.wholeStopsFromZero + fractionalValue));
    }

    // Manual tweaks, based on Canon's numbers.
    if (value >= 10.0) {
        value = round(value);
    } else {
        value = 0.1 * round(value * 10.0);
    }

    if (CBLFloatAlmostEqual(value, 23.0, STANDARD_FLOAT_WIGGLE_ROOM)) {
        value = 22.0;
    } else if (CBLFloatAlmostEqual(value, 1.3, STANDARD_FLOAT_WIGGLE_ROOM)) {
        value = 1.2;
    } else if (CBLFloatAlmostEqual(value, 1.7, STANDARD_FLOAT_WIGGLE_ROOM)) {
        value = 1.8;
    } else if (CBLFloatAlmostEqual(value, 2.4, STANDARD_FLOAT_WIGGLE_ROOM)) {
        value = 2.5;
    } else if (CBLFloatAlmostEqual(value, 3.4, STANDARD_FLOAT_WIGGLE_ROOM) ||
               CBLFloatAlmostEqual(value, 3.6, STANDARD_FLOAT_WIGGLE_ROOM)) {
        value = 3.5;
    } else if (CBLFloatAlmostEqual(value, 4.8, STANDARD_FLOAT_WIGGLE_ROOM)) {
        value = 4.5;
    } else if (CBLFloatAlmostEqual(value, 5.7, STANDARD_FLOAT_WIGGLE_ROOM)) {
        value = 5.6;
    }

    return value;
}

@end
