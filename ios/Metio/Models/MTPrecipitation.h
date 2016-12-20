//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

@interface MTPrecipitation : NSObject

typedef NS_ENUM(NSUInteger, MTPrecipitationChance) {
    MTPrecipitationChanceGood,
    MTPrecipitationChanceSlight,
    MTPrecipitationChanceNone
};

#pragma mark Properties

@property (nonatomic) CGFloat probability;
@property (nonatomic) NSString *type;
@property (nonatomic) MTPrecipitationChance chance;

#pragma mark Methods

+ (instancetype)precipitationWithProbability:(CGFloat)probability type:(NSString *)type;

@end
