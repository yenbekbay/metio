//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTWindSpeedFormatter.h"

#import "MTBearingFormatter.h"

@implementation MTWindSpeedFormatter

static inline CGFloat MTKilometersPerHourFromMilesPerHour(CGFloat milesPerHour) {
    return milesPerHour * 1.60934f;
}

static inline CGFloat MTMetersPerSecondFromMilesPerHour(CGFloat milesPerHour) {
    return milesPerHour * 0.44704f;
}

+ (NSString *)localizedStringForWindSpeed:(CGFloat)speed bearing:(CGFloat)bearing {
    NSString *abbreviatedSpeedUnit;
    NSString *currentCountryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    
    if ([currentCountryCode isEqualToString:@"CA"]) {
        abbreviatedSpeedUnit = NSLocalizedString(@"km/h", nil);
        speed = MTKilometersPerHourFromMilesPerHour(speed);
    } else {
        abbreviatedSpeedUnit = NSLocalizedString(@"m/s", nil);
        speed = MTMetersPerSecondFromMilesPerHour(speed);
    }
    
    NSString *bearingAbbreviation = [MTBearingFormatter abbreviatedCardinalDirectionStringFromBearing:bearing];
    
    return [NSString stringWithFormat:@"%.0f %@ %@", speed, abbreviatedSpeedUnit, bearingAbbreviation];
}

@end
