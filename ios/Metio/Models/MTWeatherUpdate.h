//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "LMAddress.h"
#import "MTTemperature.h"

@interface MTWeatherUpdate : NSObject <NSCoding>

#pragma mark Properties

@property (nonatomic, copy, readonly) NSArray *dailyForecasts;
@property (nonatomic, copy, readonly) NSString *city;
@property (nonatomic, copy, readonly) NSString *conditionsDescription;
@property (nonatomic, copy, readonly) NSString *precipitationType;
@property (nonatomic, copy, readonly) NSString *state;
@property (nonatomic, readonly) CGFloat precipitationPercentage;
@property (nonatomic, readonly) CGFloat windBearing;
@property (nonatomic, readonly) CGFloat windSpeed;
@property (nonatomic, readonly) MTTemperature *currentHigh;
@property (nonatomic, readonly) MTTemperature *currentLow;
@property (nonatomic, readonly) MTTemperature *currentTemperature;
@property (nonatomic, readonly) MTTemperature *yesterdaysTemperature;
@property (nonatomic, readonly) NSDate *date;

#pragma mark Methods

- (instancetype)initWithAddress:(LMAddress *)address currentConditionsJSON:(NSDictionary *)currentConditionsJSON yesterdaysConditionsJSON:(NSDictionary *)yesterdaysConditionsJSON;
- (instancetype)initWithAddress:(LMAddress *)address currentConditionsJSON:(NSDictionary *)currentConditionsJSON yesterdaysConditionsJSON:(NSDictionary *)yesterdaysConditionsJSON date:(NSDate *)date;
- (NSDictionary *)eventProperties;

@end
