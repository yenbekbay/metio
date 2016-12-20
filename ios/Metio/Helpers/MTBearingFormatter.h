//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

@interface MTBearingFormatter : NSObject

+ (NSString *)cardinalDirectionStringFromBearing:(CGFloat)bearing;
+ (NSString *)abbreviatedCardinalDirectionStringFromBearing:(CGFloat)bearing;

@end
