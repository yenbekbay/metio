//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTLocationManager.h"

#import "CLLocation+MTHelpers.h"
#import "LMGeocoder.h"

@interface MTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation MTLocationManager

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    return self;
}

#pragma mark Public

- (RACSignal *)requestWhenInUseAuthorization {
    if (TARGET_IPHONE_SIMULATOR) {
        return [RACSignal return:@YES];
    }
    if ([self needsAuthorization]) {
        [self.locationManager requestWhenInUseAuthorization];
        return [self didAuthorize];
    } else {
        return [self authorized];
    }
}

- (RACSignal *)updateCurrentLocation {
    if (TARGET_IPHONE_SIMULATOR) {
        return [RACSignal return:[[CLLocation alloc] initWithLatitude:43.2775f longitude:76.8958f]];
    }
    
    RACSignal *currentLocationUpdated = [[[self didUpdateLocations] map:^id(NSArray *locations) {
        return locations.lastObject;
    }] filter:^BOOL(CLLocation *location) {
        return !location.isStale;
    }];
    
    RACSignal *locationUpdateFailed = [[[self didFailWithError] map:^id(NSError *error) {
        return [RACSignal error:error];
    }] switchToLatest];
    
    return [[[[RACSignal merge:@[currentLocationUpdated, locationUpdateFailed]] take:1] initially:^{
        [self.locationManager startUpdatingLocation];
    }] finally:^{
        [self.locationManager stopUpdatingLocation];
    }];
}

- (RACSignal *)reverseGeocodeLocation:(CLLocation *)location {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[LMGeocoder sharedInstance] reverseGeocodeCoordinate:location.coordinate service:kLMGeocoderGoogleService
            completionHandler:^(LMAddress *address, NSError *error) {
                DDLogVerbose(@"Got the address: %@", address);
                if (address && !error) {
                    [subscriber sendNext:address];
                    [subscriber sendCompleted];
                } else {
                    [subscriber sendError:error];
                }
            }];
        return nil;
    }];
}

- (BOOL)authorizationStatusEqualTo:(CLAuthorizationStatus)status {
    return [CLLocationManager authorizationStatus] == status;
}

#pragma mark Private

- (BOOL)needsAuthorization {
    return [self authorizationStatusEqualTo:kCLAuthorizationStatusNotDetermined];
}

- (RACSignal *)didAuthorize {
    return [[[[self didChangeAuthorizationStatus] ignore:@(kCLAuthorizationStatusNotDetermined)] map:^id(NSNumber *status) {
        return @(status.integerValue == kCLAuthorizationStatusAuthorizedWhenInUse);
    }] take:1];
}

- (RACSignal *)authorized {
    BOOL authorized = [self authorizationStatusEqualTo:kCLAuthorizationStatusAuthorizedWhenInUse] || [self authorizationStatusEqualTo:kCLAuthorizationStatusAuthorizedAlways];
    return [RACSignal return:@(authorized)];
}

#pragma mark CLLocationManagerDelegate

- (RACSignal *)didUpdateLocations {
    return [[self rac_signalForSelector:@selector(locationManager:didUpdateLocations:) fromProtocol:@protocol(CLLocationManagerDelegate)] reduceEach:^id(CLLocationManager *manager, NSArray *locations) {
        return locations;
    }];
}

- (RACSignal *)didFailWithError {
    return [[self rac_signalForSelector:@selector(locationManager:didFailWithError:) fromProtocol:@protocol(CLLocationManagerDelegate)] reduceEach:^id(CLLocationManager *manager, NSError *error) {
        return error;
    }];
}

- (RACSignal *)didChangeAuthorizationStatus {
    return [[self rac_signalForSelector:@selector(locationManager:didChangeAuthorizationStatus:) fromProtocol:@protocol(CLLocationManagerDelegate)] reduceEach:^id(CLLocationManager *manager, NSNumber *status) {
        return status;
    }];
}

@end
