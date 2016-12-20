//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "CLLocation+MTHelpers.h"

static NSTimeInterval const kRecentLocationMaximumElapsedTimeInterval = 5;

@implementation CLLocation (MTHelpers)

- (BOOL)isStale {
    return [self elapsedTimeInterval] > kRecentLocationMaximumElapsedTimeInterval;
}

- (NSTimeInterval)elapsedTimeInterval {
    return [[NSDate date] timeIntervalSinceDate:self.timestamp];
}

@end
