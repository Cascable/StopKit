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

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:@"Auto" forKey:@"placeholder"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if ([aDecoder containsValueForKey:@"placeholder"]) {
        return [self init];
    } else {
        return nil;
    }
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

-(BOOL)isDeterminate {
    return NO;
}

-(NSComparisonResult)compare:(nonnull id <CBLUniversalExposurePropertyValue>)value {
    if (value != self) { return CBLExposureComparisonInvalid; }
    return NSOrderedSame;
}

-(nullable id <CBLUniversalExposurePropertyValue>)valueByAddingStops:(nonnull CBLExposureStops *)stops {
    return nil;
}

-(nullable CBLExposureStops *)stopsDifferenceFrom:(nonnull id<CBLUniversalExposurePropertyValue>)value {
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
