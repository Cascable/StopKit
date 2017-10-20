#import "CBLAutoISOValue.h"
#import "StopKit+Internal.h"

@interface CBLAutoISOValue ()
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
// We disable designated initializer warnings here since CBLISOValue declares initWithStopsFromISO100: as
// its designated initializer.

@implementation CBLAutoISOValue

-(id)init {
    self = [super init];
    return self;
}

#pragma clang diagnostic pop

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", NSStringFromClass(self.class), self.succinctDescription];
}

-(NSString *)succinctDescription {
    return @"Automatic";
}

-(NSString *)localizedDisplayValue {
    return CBLStopKitLocalizedString(@"AutoValue", @"UniversalISOValues");
}

-(BOOL)isEqual:(id)object {
    return object == self;
}

-(NSComparisonResult)compare:(id <CBLUniversalExposurePropertyValue>)value {
    if (value != self) { return CBLExposureComparisonInvalid; }
    return NSOrderedSame;
}

-(CBLExposureStops *)stopsDifferenceFrom:(id <CBLUniversalExposurePropertyValue>)value {
    [self illegalOperationAttempted];
    return nil;
}

-(NSUInteger)numericISOValue {
    [self illegalOperationAttempted];
    return 0;
}

-(CBLISOValue *)valueByAddingStops:(CBLExposureStops *)stops {
    [self illegalOperationAttempted];
    return nil;
}

-(void)illegalOperationAttempted {
    [[NSException exceptionWithName:@"se.cascable.invalidoperation" reason:@"Can't do stop math on indeterminate values" userInfo:nil] raise];
}

@end
