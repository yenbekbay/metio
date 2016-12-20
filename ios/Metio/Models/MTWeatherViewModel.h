//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTWeatherUpdate.h"

@interface MTWeatherViewModel : NSObject

#pragma mark Properties

@property (nonatomic, readonly) NSArray *dailyForecasts;
@property (nonatomic, readonly) NSAttributedString *conditionsDescription;
@property (nonatomic, readonly) NSAttributedString *temperatureDescription;
@property (nonatomic, readonly) NSString *locationName;
@property (nonatomic, readonly) NSString *updatedDateString;
@property (nonatomic, readonly) NSString *windDescription;
@property (nonatomic, readonly) NSString *precipitationDescription;
@property (nonatomic, readonly) UIImage *conditionsImage;
@property (nonatomic, readonly) UIColor *backgroundColor;

#pragma mark Methods

- (instancetype)initWithWeatherUpdate:(MTWeatherUpdate *)weatherUpdate;

@end
