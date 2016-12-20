extern UIOffset const kStoriesViewOffset;

@interface MTStoriesView : UICollectionView

- (instancetype)initWithFrame:(CGRect)frame;
- (void)updateStoriesWithCity:(NSString *)city;

@end
