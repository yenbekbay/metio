//
//  Copyright (c) 2014 Ezequiel A Becerra.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EBCardCollectionLayoutType) {
    EBCardCollectionLayoutHorizontal,
    EBCardCollectionLayoutVertical
};

@interface EBCardCollectionViewLayout : UICollectionViewLayout

@property (readonly) NSUInteger currentPage;
@property (nonatomic, assign) UIOffset offset;
@property (nonatomic) NSDictionary *layoutInfo;
@property (assign) EBCardCollectionLayoutType layoutType;

@end
