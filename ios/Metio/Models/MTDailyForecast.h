//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTTemperature.h"

@interface MTDailyForecast : NSObject

#pragma mark Properties

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSString *conditionsDescription;
@property (nonatomic, readonly) MTTemperature *highTemperature;
@property (nonatomic, readonly) MTTemperature *lowTemperature;

#pragma mark Methods

- (instancetype)initWithJSON:(NSDictionary *)JSON;

@end
