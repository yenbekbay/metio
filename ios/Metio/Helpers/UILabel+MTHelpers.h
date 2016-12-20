@interface UILabel (MTHelpers)

- (void)adjustFontSize:(NSUInteger)maxLines fontFloor:(CGFloat)fontFloor;
- (void)setFrameToFitWithHeightLimit:(CGFloat)heightLimit;
- (CGSize)sizeToFitWithHeightLimit:(CGFloat)heightLimit;

@end
