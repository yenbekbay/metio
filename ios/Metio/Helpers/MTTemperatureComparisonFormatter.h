//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTTemperature.h"

@interface MTTemperatureComparisonFormatter : NSObject

+ (NSString *)localizedStringFromComparison:(MTTemperatureComparison)comparison adjective:(NSString *__autoreleasing *)adjective precipitation:(NSString *)precipitation date:(NSDate *)date;

@end
