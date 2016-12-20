#import "MTWeatherView.h"

#import "UIColor+MTTints.h"
#import "UIFont+MTHelpers.h"
#import "UILabel+MTHelpers.h"
#import "UIView+AYUtils.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

static UIEdgeInsets const kWeatherViewPadding = {20, 20, 20, 20};
static CGSize const kWeatherViewSummaryIconSize = {40, 40};
static CGFloat const kWeatherViewSummaryIconBottomMargin = 10;
static CGSize const kWeatherViewDetailsIconSize = {20, 20};
static CGFloat const kWeatherViewDetailsIconRightMargin = 10;
static CGFloat const kWeatherViewDetailsSpacing = 10;

@interface MTWeatherView ()

@property (nonatomic) UIImageView *conditionsImageView;
@property (nonatomic) UILabel *conditionsDescriptionLabel;

@property (nonatomic) UIImageView *temperatureImageView;
@property (nonatomic) UIImageView *windSpeedImageView;
@property (nonatomic) UIImageView *precipitationImageView;
@property (nonatomic) UILabel *temperatureLabel;
@property (nonatomic) UILabel *windSpeedLabel;
@property (nonatomic) UILabel *precipitationLabel;

@end

@implementation MTWeatherView

#pragma mark Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setUpSummary];
    [self setUpDetails];
    
    return self;
}

#pragma mark Public

- (void)bindWeatherManager:(MTWeatherManager *)weatherManager {
    RAC(self.conditionsImageView, image) = weatherManager.conditionsImage;
    RAC(self.conditionsDescriptionLabel, attributedText) = weatherManager.conditionsDescription;
    RAC(self.temperatureLabel, attributedText) = weatherManager.temperatureDescription;
    RAC(self.temperatureImageView, hidden) = [weatherManager.temperatureDescription map:^id(id value) {
        return @(value == nil);
    }];
    RAC(self.windSpeedLabel, text) = weatherManager.windDescription;
    RAC(self.windSpeedImageView, hidden) = [weatherManager.windDescription map:^id(id value) {
        return @(value == nil);
    }];
    RAC(self.precipitationLabel, text) = weatherManager.precipitationDescription;
    RAC(self.precipitationImageView, hidden) = [weatherManager.precipitationDescription map:^id(id value) {
        return @(value == nil);
    }];
}

#pragma mark Private

- (void)setUpSummary {
    self.conditionsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kWeatherViewPadding.left, kWeatherViewPadding.top, kWeatherViewSummaryIconSize.width, kWeatherViewSummaryIconSize.height)];
    self.conditionsImageView.tintColor = [UIColor whiteColor];
    [self addSubview:self.conditionsImageView];
    
    self.conditionsDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kWeatherViewPadding.left, self.conditionsImageView.bottom + kWeatherViewSummaryIconBottomMargin, self.width - kWeatherViewPadding.left - kWeatherViewPadding.right, 0)];
    self.conditionsDescriptionLabel.textColor = [UIColor whiteColor];
    self.conditionsDescriptionLabel.numberOfLines = 0;
    [RACObserve(self.conditionsDescriptionLabel, attributedText) subscribeNext:^(NSAttributedString *attributedText) {
        [self.conditionsDescriptionLabel setFrameToFitWithHeightLimit:0];
    }];
    [self addSubview:self.conditionsDescriptionLabel];
}

- (void)setUpDetails {
    self.precipitationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kWeatherViewPadding.left, self.height - kWeatherViewDetailsIconSize.height - kWeatherViewPadding.bottom, kWeatherViewDetailsIconSize.width, kWeatherViewDetailsIconSize.height)];
    self.precipitationImageView.image = [[UIImage imageNamed:@"RaindropsIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self addSubview:self.precipitationImageView];
    self.precipitationLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.precipitationImageView.right + kWeatherViewDetailsIconRightMargin, 0, self.width - self.precipitationImageView.right - kWeatherViewDetailsIconRightMargin - kWeatherViewPadding.right, self.precipitationImageView.height)];
    self.precipitationLabel.centerY = self.precipitationImageView.centerY;
    [self addSubview:self.precipitationLabel];
    
    self.windSpeedImageView = [[UIImageView alloc] initWithFrame:self.precipitationImageView.frame];
    self.windSpeedImageView.bottom = self.precipitationImageView.top - kWeatherViewDetailsSpacing;
    self.windSpeedImageView.image = [[UIImage imageNamed:@"WindIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self addSubview:self.windSpeedImageView];
    self.windSpeedLabel = [[UILabel alloc] initWithFrame:self.precipitationLabel.frame];
    self.windSpeedLabel.centerY = self.windSpeedImageView.centerY;
    [self addSubview:self.windSpeedLabel];
    
    self.temperatureImageView = [[UIImageView alloc] initWithFrame:self.windSpeedImageView.frame];
    self.temperatureImageView.bottom = self.windSpeedImageView.top - kWeatherViewDetailsSpacing;
    self.temperatureImageView.image = [[UIImage imageNamed:@"ThermometerIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self addSubview:self.temperatureImageView];
    self.temperatureLabel = [[UILabel alloc] initWithFrame:self.windSpeedLabel.frame];
    self.temperatureLabel.centerY = self.temperatureImageView.centerY;
    [self addSubview:self.temperatureLabel];
    
    for (UIImageView *imageView in @[self.temperatureImageView, self.windSpeedImageView, self.precipitationImageView]) {
        imageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        imageView.tintColor = [UIColor whiteColor];
    }
    
    for (UILabel *label in @[self.temperatureLabel, self.windSpeedLabel, self.precipitationLabel]) {
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        label.font = [UIFont mt_lightFontOfSize:[UIFont mediumFontSize]];
        label.textColor = [UIColor whiteColor];
    }
}

@end
