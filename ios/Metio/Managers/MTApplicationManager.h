//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTWeatherViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MTApplicationManager : NSObject

@property (nonatomic) MTWeatherViewController *rootViewController;

- (RACSignal *)performBackgroundFetch;
- (void)setMinimumBackgroundFetchIntervalForApplication:(UIApplication *)application;

@end
