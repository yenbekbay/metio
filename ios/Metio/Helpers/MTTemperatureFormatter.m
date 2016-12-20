//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTTemperatureFormatter.h"

@implementation MTTemperatureFormatter

- (NSString *)stringFromTemperature:(MTTemperature *)temperature {
    CGFloat temperatureValue = temperature.celsiusValue;
    return [NSString stringWithFormat:@"%.f°", temperatureValue];
}

@end
