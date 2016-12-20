@interface UIColor (MTTints)

+ (instancetype)defaultColor;
+ (instancetype)hotColor;
+ (instancetype)warmerColor;
+ (instancetype)coolerColor;
+ (instancetype)coldColor;
- (instancetype)darkerColorByAmount:(CGFloat)amount;

@end
