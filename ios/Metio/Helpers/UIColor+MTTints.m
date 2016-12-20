#import "UIColor+MTTints.h"

@implementation UIColor (MTTints)

+ (instancetype)defaultColor {
    return [UIColor colorWithRed:0.2f green:0.29f blue:0.37f alpha:1];
}

+ (instancetype)hotColor {
    return [UIColor colorWithRed:0.83f green:0.33f blue:0 alpha:1];
}

+ (instancetype)warmerColor {
    return [UIColor colorWithRed:1 green:0.66f blue:0 alpha:1];
}

+ (instancetype)coolerColor {
    return [UIColor colorWithRed:0.31f green:0.4f blue:0.63f alpha:1];
}

+ (instancetype)coldColor {
    return [UIColor colorWithRed:0.22f green:0.3f blue:0.51f alpha:1];
}

- (instancetype)darkerColorByAmount:(CGFloat)amount {
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    CGFloat newSaturation = saturation * (1 - amount);
    CGFloat newBrightness = brightness * (1 - amount);
    
    return [UIColor colorWithHue:hue saturation:newSaturation brightness:newBrightness alpha:alpha];
}

@end
