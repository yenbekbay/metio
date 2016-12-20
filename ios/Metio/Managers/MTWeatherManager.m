//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTWeatherManager.h"

#import "LMAddress.h"
#import "MTForecastManager.h"
#import "MTLocationManager.h"
#import "MTWeatherUpdateCache.h"
#import "MTWeatherViewModel.h"
#import <Analytics/Analytics.h>

@interface MTWeatherManager ()

@property (nonatomic) MTForecastManager *forecastManager;
@property (nonatomic) MTLocationManager *locationManager;
@property (nonatomic) MTWeatherViewModel *viewModel;
@property (nonatomic) NSError *weatherUpdateError;
@property (nonatomic, readwrite) RACCommand *updateWeatherCommand;

@end

@implementation MTWeatherManager

#pragma mark - Initializers

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.locationManager = [MTLocationManager new];
    self.forecastManager = [MTForecastManager new];
    
    @weakify(self)
    self.updateWeatherCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [[[[self.locationManager requestWhenInUseAuthorization] then:^RACSignal *{
            return [self.locationManager updateCurrentLocation];
        }] flattenMap:^RACStream *(CLLocation *location) {
            DDLogVerbose(@"Got the location: %@", location);
            return [self.locationManager reverseGeocodeLocation:location];
        }] flattenMap:^RACStream *(LMAddress *address) {
            return [self.forecastManager fetchWeatherUpdateForAddress:address];
        }];
    }];
    
    RAC(self, viewModel) = [[self latestWeatherUpdates] map:^id(MTWeatherUpdate *update) {
        return [[MTWeatherViewModel alloc] initWithWeatherUpdate:update];
    }];
    
    RAC(self, weatherUpdateError) = [self.updateWeatherCommand.errors doNext:^(NSError *error) {
        DDLogError(@"Error while updating weather: %@", error);
    }];
    
    [[self latestWeatherUpdates] subscribeNext:^(MTWeatherUpdate *update) {
        DDLogVerbose(@"Got weather update: %@", update);
        [[SEGAnalytics sharedAnalytics] track:@"Weather Update" properties:update.eventProperties];
        [[MTWeatherUpdateCache new] archiveWeatherUpdate:update];
    }];
    
    return self;
}

- (RACSignal *)latestWeatherUpdates {
    MTWeatherUpdate *cachedUpdate = [[MTWeatherUpdateCache new] latestWeatherUpdate];
    RACSignal *weatherUpdates = [self.updateWeatherCommand.executionSignals startWith:[RACSignal return:cachedUpdate]];
    
    return [[weatherUpdates switchToLatest] filter:^BOOL(MTWeatherUpdate *update) {
        return update != nil;
    }];
}

#pragma mark Public

- (RACSignal *)status {
    RACSignal *initialValue = [RACSignal return:nil];
    RACSignal *success = [RACObserve(self, viewModel.updatedDateString) ignore:nil];
    RACSignal *error = [[RACObserve(self, weatherUpdateError) ignore:nil] mapReplace:nil];
    
    return [RACSignal merge:@[initialValue, success, error]];
}

- (RACSignal *)locationName {
    RACSignal *startedLocating = [[self.updateWeatherCommand.executing ignore:@NO] mapReplace:NSLocalizedString(@"CheckingWeather", nil)];
    RACSignal *updatedLocation = RACObserve(self, viewModel.locationName);
    RACSignal *error = [[RACObserve(self, weatherUpdateError) ignore:nil] map:^id(id value) {
        return NSLocalizedString(@"UpdateFailed", nil);
    }];
    
    return [[RACSignal merge:@[startedLocating, updatedLocation, error]] startWith:nil];
}

- (RACSignal *)conditionsImage {
    return RACObserve(self, viewModel.conditionsImage);
}

- (RACSignal *)conditionsDescription {
    return RACObserve(self, viewModel.conditionsDescription);
}

- (RACSignal *)windDescription {
    return RACObserve(self, viewModel.windDescription);
}

- (RACSignal *)precipitationDescription {
    return RACObserve(self, viewModel.precipitationDescription);
}

- (RACSignal *)temperatureDescription {
    return RACObserve(self, viewModel.temperatureDescription);
}

- (RACSignal *)backgroundColor {
    return RACObserve(self, viewModel.backgroundColor);
}

- (RACSignal *)dailyForecastViewModels {
    return RACObserve(self, viewModel.dailyForecasts);
}

@end
