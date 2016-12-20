//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTDailyForecastViewModel.h"

#import "MTTemperatureFormatter.h"

@interface MTDailyForecastViewModel ()

@property (nonatomic) MTDailyForecast *dailyForecast;
@property (nonatomic) MTTemperatureFormatter *temperatureFormatter;

@end

@implementation MTDailyForecastViewModel

#pragma mark Initialization

- (instancetype)initWithDailyForecast:(MTDailyForecast *)dailyForecast {
    self = [super init];
    if (!self) return nil;
    
    self.dailyForecast = dailyForecast;
    
    return self;
}

#pragma mark Getters

- (NSString *)dayOfWeek {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"ccc";
    return [dateFormatter stringFromDate:self.dailyForecast.date];
}

- (UIImage *)conditionsImage {
    return [UIImage imageNamed:self.dailyForecast.conditionsDescription];
}

- (NSString *)highTemperature {
    return [[MTTemperatureFormatter new] stringFromTemperature:self.dailyForecast.highTemperature];
}

- (NSString *)lowTemperature {
    return [[MTTemperatureFormatter new] stringFromTemperature:self.dailyForecast.lowTemperature];
}

@end
