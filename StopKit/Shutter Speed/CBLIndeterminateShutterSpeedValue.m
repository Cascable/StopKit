#import "CBLIndeterminateShutterSpeedValue.h"
#import "StopKit+Internal.h"

@interface CBLIndeterminateShutterSpeedValue ()
@property (nonatomic, readwrite, copy) NSString *name;
@end

@implementation CBLIndeterminateShutterSpeedValue

-(id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", NSStringFromClass(self.class), self.name];
}

-(NSString *)succinctDescription {
    return self.name;
}

-(NSString *)localizedDisplayValue {
    return CBLStopKitLocalizedString(self.name, @"UniversalShutterSpeeds");
}

-(BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }

    CBLIndeterminateShutterSpeedValue *other = object;
    return [self.name isEqualToString:other.name];
}

-(BOOL)isDeterminate {
    return NO;
}

-(BOOL)isBulb {
    return [self.name rangeOfString:@"bulb" options:NSCaseInsensitiveSearch].location != NSNotFound ||
    [self.name rangeOfString:@"livetime" options:NSCaseInsensitiveSearch].location != NSNotFound;
}

-(NSComparisonResult)compare:(id <CBLUniversalExposurePropertyValue>)value {
    if (value != self) { return CBLExposureComparisonInvalid; }
    return NSOrderedSame;
}

-(CBLExposureStops *)stopsDifferenceFrom:(id <CBLUniversalExposurePropertyValue>)value {
    return nil;
}

-(NSTimeInterval)approximateTimeInterval {
    [self illegalOperationAttempted];
    return 0.0;
}

-(NSString *)fractionalRepresentation {
    [self illegalOperationAttempted];
    return nil;
}

-(NSUInteger)lowerFractionalValue {
    [self illegalOperationAttempted];
    return 0;
}

-(NSUInteger)upperFractionalValue {
    [self illegalOperationAttempted];
    return 0;
}

-(CBLShutterSpeedValue *)valueByAddingStops:(CBLExposureStops *)stops {
    return nil;
}

-(void)illegalOperationAttempted {
    [[NSException exceptionWithName:@"se.cascable.invalidoperation" reason:@"Can't do stop math on indeterminate values" userInfo:nil] raise];
}

@end
