//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTTemperatureComparisonFormatter.h"

typedef NS_ENUM(NSUInteger, MTTimeOfDay) {
    MTTimeOfDayMorning,
    MTTimeOfDayDay,
    MTTimeOfDayAfternoon,
    MTTimeOfDayNight
};

@implementation MTTemperatureComparisonFormatter

#pragma mark Public

+ (NSString *)localizedStringFromComparison:(MTTemperatureComparison)comparison adjective:(NSString *__autoreleasing *)adjective precipitation:(NSString *)precipitation date:(NSDate *)date {
    NSString *formatString = (comparison == MTTemperatureComparisonSame) ? NSLocalizedString(@"SameTemperatureFormat", nil) : NSLocalizedString(@"DifferentTemperatureFormat", nil);
    *adjective = [self localizedAdjectiveForTemperatureComparison:comparison];
    
    return [NSString stringWithFormat:formatString, [self localizedCurrentTimeOfDayForDate:date], *adjective, [self localizedPreviousTimeOfDayForDate:date], precipitation];
}

#pragma mark Private

+ (NSString *)localizedAdjectiveForTemperatureComparison:(MTTemperatureComparison)comparison {
    switch (comparison) {
        case MTTemperatureComparisonHotter:
            return NSLocalizedString(@"Hotter", nil);
        case MTTemperatureComparisonWarmer:
            return NSLocalizedString(@"Warmer", nil);
        case MTTemperatureComparisonCooler:
            return NSLocalizedString(@"Cooler", nil);
        case MTTemperatureComparisonColder:
            return NSLocalizedString(@"Colder", nil);
        case MTTemperatureComparisonSame:
            return NSLocalizedString(@"Same", nil);
    }
}

+ (NSString *)localizedCurrentTimeOfDayForDate:(NSDate *)date {
    switch ([self timeOfDayForDate:date]) {
        case MTTimeOfDayNight:
            return NSLocalizedString(@"Tonight", nil);
        case MTTimeOfDayMorning:
            return NSLocalizedString(@"ThisMorning", nil);
        case MTTimeOfDayDay:
            return NSLocalizedString(@"Today", nil);
        case MTTimeOfDayAfternoon:
            return NSLocalizedString(@"ThisAfternoon", nil);
        default:
            break;
    }
}

+ (NSString *)localizedPreviousTimeOfDayForDate:(NSDate *)date {
    switch ([self timeOfDayForDate:date]) {
        case MTTimeOfDayNight:
            return NSLocalizedString(@"LastNight", nil);
        case MTTimeOfDayMorning:
            return NSLocalizedString(@"YesterdayMorning", nil);
        case MTTimeOfDayDay:
            return NSLocalizedString(@"Yesterday", nil);
        case MTTimeOfDayAfternoon:
            return NSLocalizedString(@"YesterdayAfternoon", nil);
        default:
            break;
    }
}

+ (MTTimeOfDay)timeOfDayForDate:(NSDate *)date {
    NSDateComponents *dateComponents = [[self calendar] components:NSCalendarUnitHour fromDate:date];
    
    if (dateComponents.hour < 4) {
        return MTTimeOfDayNight;
    } else if (dateComponents.hour < 9) {
        return MTTimeOfDayMorning;
    } else if (dateComponents.hour < 14) {
        return MTTimeOfDayDay;
    } else if (dateComponents.hour < 17) {
        return MTTimeOfDayAfternoon;
    } else {
        return MTTimeOfDayNight;
    }
}

+ (NSCalendar *)calendar {
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [NSCalendar currentCalendar];
    });
    return calendar;
}

@end
