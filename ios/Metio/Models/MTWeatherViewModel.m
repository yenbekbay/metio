//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTWeatherViewModel.h"

#import "MTDailyForecastViewModel.h"
#import "MTDateFormatter.h"
#import "MTPrecipitation.h"
#import "MTPrecipitationChanceFormatter.h"
#import "MTTemperatureComparisonFormatter.h"
#import "MTTemperatureFormatter.h"
#import "MTWindSpeedFormatter.h"
#import "UIColor+MTTints.h"
#import "UIFont+MTHelpers.h"

#define SHOW_STATE 0

@interface MTWeatherViewModel ()

@property (nonatomic) MTWeatherUpdate *weatherUpdate;
@property (nonatomic) MTDateFormatter *dateFormatter;

@end

@implementation MTWeatherViewModel

#pragma mark Initialization

- (instancetype)initWithWeatherUpdate:(MTWeatherUpdate *)weatherUpdate {
    self = [super init];
    if (!self) return nil;
    
    self.weatherUpdate = weatherUpdate;
    self.dateFormatter = [MTDateFormatter new];
    
    return self;
}

#pragma mark Getters

- (NSString *)locationName {
#if SHOW_STATE
    return self.weatherUpdate.state ? [NSString stringWithFormat:@"%@, %@", self.weatherUpdate.city, self.weatherUpdate.state] : self.weatherUpdate.city;
#else
    return self.weatherUpdate.city;
#endif
}

- (NSString *)updatedDateString {
    return [self.dateFormatter stringFromDate:self.weatherUpdate.date];
}

- (UIImage *)conditionsImage {
    return [[UIImage imageNamed:self.weatherUpdate.conditionsDescription] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (NSAttributedString *)conditionsDescription {
    MTTemperatureComparison comparison = [self.weatherUpdate.currentTemperature comparedTo:self.weatherUpdate.yesterdaysTemperature];
    
    NSString *adjective;
    MTPrecipitation *precipitation = [MTPrecipitation precipitationWithProbability:self.weatherUpdate.precipitationPercentage type:self.weatherUpdate.precipitationType];
    NSString *precipitationString = [MTPrecipitationChanceFormatter precipitationChanceStringFromPrecipitation:precipitation];
    NSString *comparisonString = [MTTemperatureComparisonFormatter localizedStringFromComparison:comparison adjective:&adjective precipitation:precipitationString date:self.weatherUpdate.date];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:comparisonString attributes:@{
        NSFontAttributeName: [UIFont mt_lightFontOfSize:[UIFont conditionsFontSize]]
    }];
    [attributedString setAttributes:@{
        NSFontAttributeName: [UIFont mt_regularFontOfSize:[UIFont conditionsFontSize]]
    } range:[attributedString.string rangeOfString:adjective]];
    
    return attributedString;
}

- (NSString *)windDescription {
    return [MTWindSpeedFormatter localizedStringForWindSpeed:self.weatherUpdate.windSpeed bearing:self.weatherUpdate.windBearing];
}

- (NSString *)precipitationDescription {
    return [NSString stringWithFormat:@"%.0f%%", self.weatherUpdate.precipitationPercentage * 100];
}

- (NSAttributedString *)temperatureDescription {
    MTTemperatureFormatter *formatter = [MTTemperatureFormatter new];
    NSString *high = [formatter stringFromTemperature:self.weatherUpdate.currentHigh];
    NSString *current = [formatter stringFromTemperature:self.weatherUpdate.currentTemperature];
    NSString *low = [formatter stringFromTemperature:self.weatherUpdate.currentLow];
    NSString *temperatureString = [NSString stringWithFormat:@"%@ / %@ / %@", high, current, low];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:temperatureString];
    
    NSRange rangeOfFirstSlash = [temperatureString rangeOfString:@"/"];
    NSRange rangeOfLastSlash = [temperatureString rangeOfString:@"/" options:NSBackwardsSearch];
    NSRange range = NSMakeRange(rangeOfFirstSlash.location + 1, rangeOfLastSlash.location - (rangeOfFirstSlash.location + 1));
    
    [attributedString setAttributes:@{
        NSFontAttributeName: [UIFont mt_regularFontOfSize:[UIFont mediumFontSize]]
    } range:range];
    
    return attributedString;
}

- (NSArray *)dailyForecasts {
    NSMutableArray *forecasts = [[NSMutableArray alloc] initWithCapacity:self.weatherUpdate.dailyForecasts.count];
    
    for (MTDailyForecast *forecast in self.weatherUpdate.dailyForecasts) {
        MTDailyForecastViewModel *viewModel = [[MTDailyForecastViewModel alloc] initWithDailyForecast:forecast];
        [forecasts addObject:viewModel];
    }
    
    return [forecasts copy];
}

- (UIColor *)backgroundColor {
    MTTemperatureComparison comparison = [self.weatherUpdate.currentTemperature comparedTo:self.weatherUpdate.yesterdaysTemperature];
    MTTemperature *difference = [self.weatherUpdate.currentTemperature temperatureDifferenceFromTemperature:self.weatherUpdate.yesterdaysTemperature];
    return [self colorForTemperatureComparison:comparison difference:difference.fahrenheitValue];
}

#pragma mark Private

- (UIColor *)colorForTemperatureComparison:(MTTemperatureComparison)comparison difference:(NSInteger)difference {
    UIColor *color;
    
    switch (comparison) {
        case MTTemperatureComparisonSame:
            color = [UIColor defaultColor];
            break;
        case MTTemperatureComparisonColder:
            color = [UIColor coldColor];
            break;
        case MTTemperatureComparisonCooler:
            color = [UIColor coolerColor];
            break;
        case MTTemperatureComparisonHotter:
            color = [UIColor hotColor];
            break;
        case MTTemperatureComparisonWarmer:
            color = [UIColor warmerColor];
            break;
    }
    
    if (comparison == MTTemperatureComparisonCooler || comparison == MTTemperatureComparisonWarmer) {
        CGFloat amount = MIN(ABS(difference), 10) / 20.f;
        CGFloat darkerAmount = MIN(0.5f, amount);
        color = [color darkerColorByAmount:darkerAmount];
    }
    
    return color;
}

@end
