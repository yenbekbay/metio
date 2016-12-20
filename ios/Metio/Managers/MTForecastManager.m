//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTForecastManager.h"

#import "MTWeatherUpdate.h"
#import "NSDate+MTHelpers.h"
#import "Secrets.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const kForecastAPIExclusions = @"minutely,hourly,alerts,flags";

@interface MTForecastManager ()

@property (nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation MTForecastManager

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.manager = [AFHTTPRequestOperationManager manager];
    
    return self;
}

#pragma mark Public

- (RACSignal *)fetchWeatherUpdateForAddress:(LMAddress *)address {
    CLLocationCoordinate2D coordinate = address.coordinate;
    RACSignal *currentConditions = [self fetchConditionsFromURL:[self URLForCurrentConditionsAtLatitude:coordinate.latitude longitude:coordinate.longitude yesterday:NO]];
    RACSignal *yesterdaysConditions = [self fetchConditionsFromURL:[self URLForCurrentConditionsAtLatitude:coordinate.latitude longitude:coordinate.longitude yesterday:YES]];
    
    return [[RACSignal combineLatest:@[currentConditions, yesterdaysConditions] reduce:^id(id currentConditionsJSON, id yesterdaysConditionsJSON) {
        return [[MTWeatherUpdate alloc] initWithAddress:address currentConditionsJSON:currentConditionsJSON yesterdaysConditionsJSON:yesterdaysConditionsJSON];
    }] deliverOnMainThread];
}

#pragma mark Private

- (RACSignal *)fetchConditionsFromURL:(NSURL *)URL {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.manager GET:URL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogDebug(@"%@", responseObject);
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (NSURL *)URLForCurrentConditionsAtLatitude:(double)latitude longitude:(double)longitude yesterday:(BOOL)yesterday {
    NSURLComponents *components = [self.class baseURLComponents];
    NSDate *date = yesterday? [NSDate yesterday] : nil;
    components.path = [components.path stringByAppendingString:[self.class pathComponentForLatitude:latitude longitude:longitude date:date]];
    NSURLQueryItem *item = [NSURLQueryItem queryItemWithName:@"exclude" value:kForecastAPIExclusions];
    components.queryItems = @[item];
    
    return components.URL;
}

+ (NSString *)pathComponentForLatitude:(double)latitude longitude:(double)longitude date:(NSDate *)date {
    NSMutableString *path = [NSMutableString stringWithFormat:@"/%f,%f", latitude, longitude];
    if (date) {
        [path appendFormat:@",%.0f", date.timeIntervalSince1970];
    }
    return [path copy];
}

+ (NSURLComponents *)baseURLComponents {
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"https";
    components.host = @"api.forecast.io";
    components.path = [NSString stringWithFormat:@"/forecast/%@", kForecastAPIKey];
    return components;
}

@end
