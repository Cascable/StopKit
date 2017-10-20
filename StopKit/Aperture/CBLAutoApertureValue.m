#import "CBLAutoApertureValue.h"
#import "StopKit+Internal.h"

@implementation CBLAutoApertureValue

-(nonnull id)init {
    self = [super init];
    return self;
}

-(nullable instancetype)initWithApproximateDecimalValue:(double)aperture {
    self = [super init];
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [[self succinctDescription] isEqual:[object succinctDescription]];
}

-(NSComparisonResult)compare:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (value != self) { return CBLExposureComparisonInvalid; }
    return NSOrderedSame;
}

-(nullable id <CBLUniversalExposurePropertyValue>)valueByAddingStops:(nonnull CBLExposureStops *)stops {
    [self illegalOperationAttempted];
    return nil;
}

-(nullable CBLExposureStops *)stopsDifferenceFrom:(nonnull id<CBLUniversalExposurePropertyValue>)value {
    [self illegalOperationAttempted];
    return nil;
}

-(nonnull NSString *)succinctDescription {
    return @"Automatic";
}

-(NSString *)localizedDisplayValue {
    return CBLStopKitLocalizedString(@"AutoValue", @"UniversalShutterSpeeds");
}

-(double)approximateDecimalValue {
    [self illegalOperationAttempted];
    return 0.0;
}

-(void)illegalOperationAttempted {
    [[NSException exceptionWithName:@"se.cascable.invalidoperation" reason:@"Can't do stop math on indeterminate values" userInfo:nil] raise];
}

@end
