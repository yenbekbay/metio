//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "LMAddress.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MTForecastManager : NSObject

- (RACSignal *)fetchWeatherUpdateForAddress:(LMAddress *)address;

@end
