#import "CBLISOValue.h"
#import "CBLAutoISOValue.h"
#import "CBLExposureCompensationValue.h"

@interface CBLISOValue ()
@property (nonatomic, readwrite) CBLExposureStops *stopsFrom100;
@property (nonatomic, readwrite) NSNumberFormatter *formatter;
@end

@implementation CBLISOValue

+(nonnull CBLISOValue *)ISO100 {
    return [[self alloc] initWithStopsFromISO100:[CBLExposureStops zeroStops]];
}

+(nonnull CBLISOValue *)ISO200 {
    return [[self alloc] initWithStopsFromISO100:[CBLExposureStops stopsFromDecimalValue:1.0]];
}

+(nonnull CBLISOValue *)ISO400 {
    return [[self alloc] initWithStopsFromISO100:[CBLExposureStops stopsFromDecimalValue:2.0]];
}

+(nonnull CBLISOValue *)ISO800 {
    return [[self alloc] initWithStopsFromISO100:[CBLExposureStops stopsFromDecimalValue:3.0]];
}

+(nonnull CBLISOValue *)ISO1600 {
    return [[self alloc] initWithStopsFromISO100:[CBLExposureStops stopsFromDecimalValue:4.0]];
}

+(nonnull CBLISOValue *)automaticISO {
    static dispatch_once_t autoOnceToken;
    static CBLISOValue *automatic = nil;
    dispatch_once(&autoOnceToken, ^{
        automatic = [CBLAutoISOValue new];
    });
    return automatic;
}

+(nonnull CBLISOValue *)ISOValueWithStopsFrom100:(CBLExposureStops *)stops {
    return [[self ISO100] valueByAddingStops:stops];
}

-(nonnull id)init {
    return [self initWithStopsFromISO100:[CBLExposureStops zeroStops]];
}

-(nonnull id)initWithStopsFromISO100:(CBLExposureStops *)stops {
    self = [super init];
    if (self) {
        self.stopsFrom100 = stops;
        self.formatter = [[NSNumberFormatter alloc] init];
        self.formatter.numberStyle = NSNumberFormatterDecimalStyle;
        self.formatter.usesGroupingSeparator = NO;
    }
    return self;
}

-(nullable instancetype)initWithNumericISOValue:(NSUInteger)iso {

    if (iso == 0) {
        return nil;
    }

    double value = (double)iso / 100.0;
    value = log(value)/log(2.0);

    return [self initWithStopsFromISO100:[CBLExposureStops stopsFromDecimalValue:value]];
}

-(id)copyWithZone:(NSZone *)zone {
    return [[CBLISOValue alloc] initWithStopsFromISO100:self.stopsFrom100];
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]] ||
        [object isKindOfClass:[CBLAutoISOValue class]]) {
        return NO;
    }

    CBLISOValue *otherISO = object;
    return [otherISO.stopsFrom100 isEqual:self.stopsFrom100];
}

-(NSComparisonResult)compare:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return CBLExposureComparisonInvalid;
    }

    BOOL otherIsAuto = [value isEqual:[CBLISOValue automaticISO]];
    BOOL selfIsAuto = [self isEqual:[CBLISOValue automaticISO]];

    if (otherIsAuto || selfIsAuto) {
        if (selfIsAuto && otherIsAuto) {
            return NSOrderedSame;
        } else if (selfIsAuto) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    }

    return [self.stopsFrom100 compare:[(CBLISOValue *)value stopsFrom100]];
}

-(nullable CBLExposureStops *)stopsDifferenceFrom:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (![value isKindOfClass:[self class]]) {
        return nil;
    }

    return [self.stopsFrom100 differenceFrom:[(CBLISOValue *)value stopsFrom100]];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: ISO %@",
            [super description], @(self.numericISOValue)];
}

-(nonnull NSString *)succinctDescription {
    return [NSString stringWithFormat:@"ISO %@", @(self.numericISOValue)];
}

-(nullable NSString *)localizedDisplayValue {
    return [self.formatter stringFromNumber:@(self.numericISOValue)];
}

-(NSUInteger)numericISOValue {

    NSUInteger value = 100;
    if (self.stopsFrom100.isNegative) {
        value /= (pow(2, self.stopsFrom100.wholeStopsFromZero));
    } else {
        value *= (pow(2, self.stopsFrom100.wholeStopsFromZero));
    }

    double fractionalValue = 0.0;
    if (self.stopsFrom100.fraction == CBLExposureStopFractionOneThird) {
        fractionalValue = 1.0/3.0;
    } else if (self.stopsFrom100.fraction == CBLExposureStopFractionOneHalf) {
        fractionalValue = 1.0/2.0;
    } else if (self.stopsFrom100.fraction == CBLExposureStopFractionTwoThirds) {
        fractionalValue = 2.0/3.0;
    }

    if (self.stopsFrom100.isNegative) {
        value -= (value * fractionalValue);
    } else {
        value += (value * fractionalValue);
    }

    // Adjustments based on industry standards.
    NSMutableDictionary *adjustments = [NSMutableDictionary new];

    adjustments[@(66)] = @(80);
    adjustments[@(133)] = @(125);
    adjustments[@(150)] = @(140);
    adjustments[@(166)] = @(160);
    adjustments[@(266)] = @(250);
    adjustments[@(300)] = @(280);
    adjustments[@(333)] = @(320);
    adjustments[@(533)] = @(500);
    adjustments[@(600)] = @(560);
    adjustments[@(666)] = @(640);
    adjustments[@(1066)] = @(1000);
    adjustments[@(1200)] = @(1100);
    adjustments[@(1333)] = @(1250);
    adjustments[@(2133)] = @(2000);
    adjustments[@(2400)] = @(2200);
    adjustments[@(2666)] = @(2500);
    adjustments[@(4266)] = @(4000);
    adjustments[@(4800)] = @(4500);
    adjustments[@(5333)] = @(5000);
    adjustments[@(8533)] = @(8000);
    adjustments[@(9600)] = @(9000);
    adjustments[@(10666)] = @(10000);
    adjustments[@(17066)] = @(16000);
    adjustments[@(19200)] = @(18000);
    adjustments[@(21333)] = @(20000);
    adjustments[@(34133)] = @(32000);
    adjustments[@(42666)] = @(40000);

    if (adjustments[@(value)] != nil) {
        return [adjustments[@(value)] unsignedIntegerValue];
    } else {
        return value;
    }
}


-(id <CBLUniversalExposurePropertyValue>)valueByAddingStops:(CBLExposureStops *)stops {
    return [[CBLISOValue alloc] initWithStopsFromISO100:[self.stopsFrom100 stopsByAdding:stops]];
}

@end
