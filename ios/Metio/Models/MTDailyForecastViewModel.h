//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTDailyForecast.h"

@interface MTDailyForecastViewModel : NSObject

#pragma mark Properties

@property (nonatomic, readonly) NSString *dayOfWeek;
@property (nonatomic, readonly) NSString *highTemperature;
@property (nonatomic, readonly) NSString *lowTemperature;
@property (nonatomic, readonly) UIImage *conditionsImage;

#pragma mark Methods

- (instancetype)initWithDailyForecast:(MTDailyForecast *)dailyForecast;

@end
