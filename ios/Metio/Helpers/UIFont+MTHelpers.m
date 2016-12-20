#import "UIFont+MTHelpers.h"

#import "AYMacros.h"

@implementation UIFont (MTHelpers)

+ (instancetype)mt_regularFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Lato-Regular" size:size];
}

+ (instancetype)mt_lightFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"Lato-Light" size:size];
}

+ (instancetype)mt_boldFontOfSize:(CGFloat)size {
    return [UIFont fontWithName:@"BebasNeueBold" size:size];
}

+ (CGFloat)conditionsFontSize {
    if (IS_IPHONE_4_OR_LESS) {
        return 20;
    } else {
        return 24;
    }
}

+ (CGFloat)storyCeilFontSize {
    if (IS_IPHONE_4_OR_LESS) {
        return 40;
    } else {
        return 50;
    }
}

+ (CGFloat)storyFloorFontSize {
    if (IS_IPHONE_4_OR_LESS) {
        return 16;
    } else {
        return 20;
    }
}

+ (CGFloat)largeFontSize {
    if (IS_IPHONE_6P) {
        return 22;
    } else {
       return 20;
    }
}

+ (CGFloat)mediumFontSize {
    if (IS_IPHONE_6P) {
        return 18;
    } else {
        return 16;
    }
}

+ (CGFloat)smallFontSize {
    if (IS_IPHONE_6P) {
        return 16;
    } else {
        return 14;
    }
}

@end
