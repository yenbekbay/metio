//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTTemperature.h"

NSInteger MTConvertFahrenheitToCelsius(NSInteger fahrenheit) {
    return (NSInteger)round((fahrenheit - 32) * 5 / 9);
}

static NSInteger const MTTemperatureHotterLimit = 32;
static NSInteger const MTTemperatureColderLimit = 75;

@implementation MTTemperature

#pragma mark Initialization

+ (instancetype)temperatureFromFahrenheit:(NSNumber *)number {
    return [[self alloc] initWithFahrenheit:number];
}

- (instancetype)initWithFahrenheit:(NSNumber *)number {
    self = [super init];
    if (!self) return nil;

    _fahrenheitValue = [number integerValue];

    return self;
}

#pragma mark Getters

- (NSInteger)celsiusValue {
    return MTConvertFahrenheitToCelsius(self.fahrenheitValue);
}

#pragma mark Public

- (MTTemperatureComparison)comparedTo:(MTTemperature *)comparedTemperature {
    CGFloat temperatureDifference = [self fahrenheitDifferenceFromTemperature:comparedTemperature];

    if (temperatureDifference >= 10 && self.fahrenheitValue > MTTemperatureHotterLimit) {
        return MTTemperatureComparisonHotter;
    } else if (temperatureDifference > 0) {
        return MTTemperatureComparisonWarmer;
    } else if (temperatureDifference == 0) {
        return MTTemperatureComparisonSame;
    } else if (temperatureDifference > -10 || self.fahrenheitValue > MTTemperatureColderLimit) {
        return MTTemperatureComparisonCooler;
    } else {
        return MTTemperatureComparisonColder;
    }
}

- (instancetype)temperatureDifferenceFromTemperature:(MTTemperature *)temperature {
    NSInteger difference = [self fahrenheitDifferenceFromTemperature:temperature];
    return [MTTemperature temperatureFromFahrenheit:@(difference)];
}

- (NSInteger)fahrenheitDifferenceFromTemperature:(MTTemperature *)comparedTemperature {
    return self.fahrenheitValue - comparedTemperature.fahrenheitValue;
}

#pragma mark NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"Fahrenheit: %ld°\nCelsius: %ld°", (long)self.fahrenheitValue, (long)self.celsiusValue];
}

@end
