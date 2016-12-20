//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTDailyForecast.h"

@implementation MTDailyForecast

- (instancetype)initWithJSON:(NSDictionary *)JSON {
    self = [super init];
    if (!self) return nil;

    _date = [NSDate dateWithTimeIntervalSince1970:[JSON[@"time"] doubleValue]];
    _conditionsDescription = JSON[@"icon"];
    _highTemperature = [MTTemperature temperatureFromFahrenheit:JSON[@"temperatureMax"]];
    _lowTemperature = [MTTemperature temperatureFromFahrenheit:JSON[@"temperatureMin"]];

    return self;
}

@end
