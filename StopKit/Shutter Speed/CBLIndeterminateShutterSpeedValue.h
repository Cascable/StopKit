#import <Foundation/Foundation.h>
#import "CBLShutterSpeedValue.h"

@interface CBLIndeterminateShutterSpeedValue : CBLShutterSpeedValue

-(id)initWithName:(NSString *)name;

@property (nonatomic, readonly, copy) NSString *name;

@end
