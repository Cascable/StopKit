#import "CBLExposureCompensationValue.h"
#import "StopKit+Internal.h"

@interface CBLExposureCompensationValue ()
@property (nonatomic, readwrite) CBLExposureStops *stopsFromZeroEV;
@property (nonatomic, readwrite) NSNumberFormatter *formatter;
@end

@implementation CBLExposureCompensationValue

+(nonnull CBLExposureCompensationValue *)zeroEV {
    return [self valueWithStopsFromZeroEV:[CBLExposureStops zeroStops]];
}

+(nonnull CBLExposureCompensationValue *)valueWithStopsFromZeroEV:(CBLExposureStops *)stops {
    return [[self alloc] initWithStopsFromZeroEV:stops];
}

-(nonnull id)init {
    return [self initWithStopsFromZeroEV:[CBLExposureStops zeroStops]];
}

-(nonnull id)initWithStopsFromZeroEV:(CBLExposureStops *)stops {
    self = [super init];
    if (self) {
        self.stopsFromZeroEV = stops;
        self.formatter = [[NSNumberFormatter alloc] init];
        self.formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.formatter.usesGroupingSeparator = NO;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.stopsFromZeroEV forKey:@"stops"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if ([aDecoder containsValueForKey:@"stops"]) {
        return [self initWithStopsFromZeroEV:[aDecoder decodeObjectOfClass:[CBLExposureStops class] forKey:@"stops"]];
    } else {
        return nil;
    }
}

-(id)copyWithZone:(NSZone *)zone {
    return [[CBLExposureCompensationValue alloc] initWithStopsFromZeroEV:self.stopsFromZeroEV];
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    CBLExposureCompensationValue *otherEV = object;
    return [otherEV.stopsFromZeroEV isEqual:self.stopsFromZeroEV];
}

-(BOOL)isDeterminate {
    return YES;
}

-(NSComparisonResult)compare:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return CBLExposureComparisonInvalid;
    }

    return [self.stopsFromZeroEV compare:[(CBLExposureCompensationValue *)value stopsFromZeroEV]];
}

-(nullable CBLExposureStops *)stopsDifferenceFrom:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return nil;
    }

    return [self.stopsFromZeroEV differenceFrom:[(CBLExposureCompensationValue *)value stopsFromZeroEV]];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [super description], [self succinctDescription]];
}

-(nonnull NSString *)succinctDescription {

    NSString *fractionString = @"";
    if (self.stopsFromZeroEV.fraction == CBLExposureStopFractionTwoThirds) {
        fractionString = @" 2/3";
    } else if (self.stopsFromZeroEV.fraction == CBLExposureStopFractionOneHalf) {
        fractionString = @" 1/2";
    } else if (self.stopsFromZeroEV.fraction == CBLExposureStopFractionOneThird) {
        fractionString = @" 1/3";
    }

    return [NSString stringWithFormat:@"%@%@%@ EV",
            self.stopsFromZeroEV.isNegative ? @"-" : @"",
            @(self.stopsFromZeroEV.wholeStopsFromZero),
            fractionString];
}

-(NSString *)localizedDisplayValue {

    NSString *fractionString = @"";
    if (self.stopsFromZeroEV.fraction == CBLExposureStopFractionTwoThirds) {
        fractionString = CBLStopKitLocalizedString(@"TwoThirdsFraction", @"UniversalExposureCompensations");
    } else if (self.stopsFromZeroEV.fraction == CBLExposureStopFractionOneHalf) {
        fractionString = CBLStopKitLocalizedString(@"OneHalfFraction", @"UniversalExposureCompensations");
    } else if (self.stopsFromZeroEV.fraction == CBLExposureStopFractionOneThird) {
        fractionString = CBLStopKitLocalizedString(@"OneThirdFraction", @"UniversalExposureCompensations");
    }

    NSString *numberString = @"";
    if (self.stopsFromZeroEV.wholeStopsFromZero != 0 ||
        (self.stopsFromZeroEV.wholeStopsFromZero == 0 && self.stopsFromZeroEV.fraction == CBLExposureStopFractionNone)) {
        numberString = [self.formatter stringFromNumber:@(self.stopsFromZeroEV.wholeStopsFromZero)];
    }

    NSString *signString = self.stopsFromZeroEV.isNegative ? @"-" : @"+";
    if (self.stopsFromZeroEV.wholeStopsFromZero == 0 && self.stopsFromZeroEV.fraction == CBLExposureStopFractionNone) {
        signString = @"";
    }
    
    return [NSString stringWithFormat:@"%@%@%@", signString, numberString, fractionString];
}

-(nullable id <CBLUniversalExposurePropertyValue>)valueByAddingStops:(nonnull CBLExposureStops *)stops {
    return [[CBLExposureCompensationValue alloc] initWithStopsFromZeroEV:[self.stopsFromZeroEV stopsByAdding:stops]];
}

@end
