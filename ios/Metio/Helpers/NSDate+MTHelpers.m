#import "NSDate+MTHelpers.h"

@implementation NSDate (MTHelpers)

+ (NSDate *)yesterday {
    static NSCalendar *calendar = nil;
    if (!calendar) {
        calendar = [NSCalendar currentCalendar];
    }
    
    NSCalendarUnit units = NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];
    components.day--;
    return [calendar dateFromComponents:components];
}

+ (instancetype)dateForHour:(NSInteger)hour {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSCalendarUnit preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *components = [calendar components:preservedComponents fromDate:date];
    NSDate *dateForHour = [[calendar dateFromComponents:components] dateByAddingTimeInterval:60*60*hour];
    NSInteger currentHour = [[calendar components:NSCalendarUnitHour fromDate:date] hour];
    if (currentHour >= hour) {
        dateForHour = [dateForHour dateByAddingTimeInterval:60*60*24];
    }
    return dateForHour;
}

@end
