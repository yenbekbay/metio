//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTWeatherUpdate.h"

@interface MTWeatherUpdateCache : NSObject

- (MTWeatherUpdate *)latestWeatherUpdate;
- (BOOL)archiveWeatherUpdate:(MTWeatherUpdate *)update;

@end
