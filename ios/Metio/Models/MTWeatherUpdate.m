//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

@import CoreLocation;
#import "MTWeatherUpdate.h"
#import "MTTemperature.h"
#import "MTDailyForecast.h"

@interface MTWeatherUpdate ()

@property (nonatomic) LMAddress *address;
@property (nonatomic) NSDictionary *currentConditions;
@property (nonatomic) NSDictionary *yesterdaysConditions;

@end

@implementation MTWeatherUpdate

#pragma mark Initialization

- (instancetype)initWithAddress:(LMAddress *)address currentConditionsJSON:(NSDictionary *)currentConditionsJSON yesterdaysConditionsJSON:(NSDictionary *)yesterdaysConditionsJSON date:(NSDate *)date {
    self = [super init];
    if (!self) return nil;
    
    self.address = address;
    self.currentConditions = currentConditionsJSON;
    self.yesterdaysConditions = yesterdaysConditionsJSON;
    _city = address.locality;
    _state = address.administrativeArea;
    
    NSDictionary *currentCondiitions = currentConditionsJSON[@"currently"];
    NSDictionary *yesterdaysConditions = yesterdaysConditionsJSON[@"currently"];
    NSDictionary *todaysForecast = [currentConditionsJSON[@"daily"][@"data"] firstObject];
    
    _precipitationPercentage = [todaysForecast[@"precipProbability"] floatValue];
    _precipitationType = todaysForecast[@"precipType"] ? todaysForecast[@"precipType"] : @"rain";
    _conditionsDescription = currentCondiitions[@"icon"];
    [self updateCurrentTemperaturesWithConditions:currentCondiitions withForecast:todaysForecast];
    _yesterdaysTemperature = [MTTemperature temperatureFromFahrenheit:yesterdaysConditions[@"temperature"]];
    _windBearing = [currentCondiitions[@"windBearing"] floatValue];
    _windSpeed = [currentCondiitions[@"windSpeed"] floatValue];
    _date = date;
    
    NSMutableArray *dailyForecasts = [NSMutableArray array];
    
    for (NSUInteger index = 1; index < 4; index++) {
        MTDailyForecast *dailyForecast = [[MTDailyForecast alloc] initWithJSON:currentConditionsJSON[@"daily"][@"data"][index]];
        [dailyForecasts addObject:dailyForecast];
    }
    
    _dailyForecasts = [dailyForecasts copy];
    
    return self;
}

- (instancetype)initWithAddress:(LMAddress *)address currentConditionsJSON:(id)currentConditionsJSON yesterdaysConditionsJSON:(id)yesterdaysConditionsJSON {
    self = [self initWithAddress:address currentConditionsJSON:currentConditionsJSON yesterdaysConditionsJSON:yesterdaysConditionsJSON date:[NSDate date]];
    if (!self) return nil;
    
    return self;
}

- (void)updateCurrentTemperaturesWithConditions:(NSDictionary *)conditions withForecast:(NSDictionary *)forecast {
    _currentTemperature = [MTTemperature temperatureFromFahrenheit:conditions[@"temperature"]];
    _currentLow = [MTTemperature temperatureFromFahrenheit:forecast[@"temperatureMin"]];
    _currentHigh = [MTTemperature temperatureFromFahrenheit:forecast[@"temperatureMax"]];
    if (self.currentTemperature.fahrenheitValue < self.currentLow.fahrenheitValue) {
        _currentLow = self.currentTemperature;
    } else if (self.currentTemperature.fahrenheitValue > self.currentHigh.fahrenheitValue) {
        _currentHigh = self.currentTemperature;
    }
}

#pragma mark - NSCoding

static NSString * const kCurrentConditionsKey = @"currentConditions";
static NSString * const kYesterdaysConditionsKey = @"yesterdaysConditionsConditions";
static NSString * const kAddressKey = @"address";
static NSString * const kDateKey = @"date";

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.currentConditions forKey:kCurrentConditionsKey];
    [coder encodeObject:self.yesterdaysConditions forKey:kYesterdaysConditionsKey];
    [coder encodeObject:self.address forKey:kAddressKey];
    [coder encodeObject:self.date forKey:kDateKey];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    LMAddress *address = [coder decodeObjectForKey:kAddressKey];
    NSDictionary *currentConditions = [coder decodeObjectForKey:kCurrentConditionsKey];
    NSDictionary *yesterdaysConditions = [coder decodeObjectForKey:kYesterdaysConditionsKey];
    NSDate *date = [coder decodeObjectForKey:kDateKey];
    
    return [self initWithAddress:address currentConditionsJSON:currentConditions yesterdaysConditionsJSON:yesterdaysConditions date:date];
}

- (NSDictionary *)eventProperties {
    return @{
        @"Latitude": [self analyticsLatitude] ?: @"",
        @"Longitude": [self analyticsLongitude] ?: @"",
        @"City": self.city ?: @"",
        @"State": self.state ?: @"",
        @"Temperature": @(self.currentTemperature.celsiusValue) ?: @"",
        @"Low Temperature": @(self.currentLow.celsiusValue) ?: @"",
        @"High Temperature": @(self.currentHigh.celsiusValue) ?: @"",
        @"Wind Speed": @(self.windSpeed) ?: @"",
        @"Wind Bearing": @(self.windBearing) ?: @"",
        @"Update Date": self.date
    };
}

#pragma mark Analytics Formatters

- (NSNumber *)analyticsLatitude {
    return [self anonymizeLocationDegrees:self.address.coordinate.latitude];
}

- (NSNumber *)analyticsLongitude {
    return [self anonymizeLocationDegrees:self.address.coordinate.longitude];
}

- (NSNumber *)anonymizeLocationDegrees:(double)degrees {
    return @(round(degrees * 100) / 100);
}

@end
