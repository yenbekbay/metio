//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTPrecipitation.h"

@implementation MTPrecipitation

#pragma mark Initialization

+ (instancetype)precipitationWithProbability:(CGFloat)probability type:(NSString *)type {
    return [[self alloc] initWithProbability:probability type:type];
}

- (instancetype)initWithProbability:(CGFloat)probability type:(NSString *)type {
    self = [super init];
    if (!self) return nil;
    
    _probability = probability;
    _type = type;
    
    return self;
}

#pragma mark Getters

- (MTPrecipitationChance)chance {
    if (self.probability > 0.3f) {
        return MTPrecipitationChanceGood;
    } else if (self.probability > 0) {
        return MTPrecipitationChanceSlight;
    } else {
        return MTPrecipitationChanceNone;
    }
}

@end
