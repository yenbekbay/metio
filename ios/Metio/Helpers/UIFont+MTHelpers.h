@interface UIFont (MTHelpers)

+ (instancetype)mt_regularFontOfSize:(CGFloat)size;
+ (instancetype)mt_lightFontOfSize:(CGFloat)size;
+ (instancetype)mt_boldFontOfSize:(CGFloat)size;

+ (CGFloat)conditionsFontSize;
+ (CGFloat)storyCeilFontSize;
+ (CGFloat)storyFloorFontSize;
+ (CGFloat)largeFontSize;
+ (CGFloat)mediumFontSize;
+ (CGFloat)smallFontSize;

@end
