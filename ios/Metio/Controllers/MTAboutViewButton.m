#import "MTAboutViewButton.h"

#import "UIFont+MTHelpers.h"
#import "UILabel+MTHelpers.h"
#import "UIView+AYUtils.h"

static CGSize const kImageButtonViewImageSize = {30, 30};
static CGFloat const kImageButtonViewLabelTopMargin = 10;

@implementation MTAboutViewButton

#pragma mark Initialization

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image buttonTitle:(NSString *)buttonTitle {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kImageButtonViewImageSize.width, kImageButtonViewImageSize.height)];
    imageView.tintColor = [UIColor darkGrayColor];
    imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.centerX = self.width/2;
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.bottom + kImageButtonViewLabelTopMargin, self.width, 0)];
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont mt_lightFontOfSize:[UIFont mediumFontSize]];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = buttonTitle;
    [label setFrameToFitWithHeightLimit:0];
    [self addSubview:label];
    
    self.height = label.bottom;
    
    return self;
}

#pragma mark Setters

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.alpha = 0.5f;
    } else {
        self.alpha = 1;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.alpha = 0.5f;
    } else {
        self.alpha = 1;
    }
}

@end
