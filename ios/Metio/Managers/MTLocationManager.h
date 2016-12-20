//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MTLocationManager : NSObject

- (RACSignal *)requestWhenInUseAuthorization;
- (RACSignal *)updateCurrentLocation;
- (RACSignal *)reverseGeocodeLocation:(CLLocation *)location;
- (BOOL)authorizationStatusEqualTo:(CLAuthorizationStatus)status;

@end
