//
//  Copyright (c) 2015 Sth4Me.
//

#import "STPopupLeftBarItem.h"

#import "UIView+AYUtils.h"

@interface STPopupLeftBarItem ()

@property (nonatomic) UIView *bar1;
@property (nonatomic) UIView *bar2;

@end

@implementation STPopupLeftBarItem

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super initWithCustomView:[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 18, 44)]];
    if (!self) return nil;
    
    [(UIControl *)self.customView addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    self.bar1 = [UIView new];
    self.bar1.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1];
    self.bar1.userInteractionEnabled = NO;
    self.bar1.layer.allowsEdgeAntialiasing = YES;
    [self.customView addSubview:self.bar1];
    self.bar2 = [UIView new];
    self.bar2.backgroundColor = [UIColor colorWithWhite:0.4f alpha:1];
    self.bar2.userInteractionEnabled = NO;
    self.bar2.layer.allowsEdgeAntialiasing = YES;
    [self.customView addSubview:self.bar2];
    
    return self;
}

- (void)setType:(STPopupLeftBarItemType)type {
    [self setType:type animated:NO];
}

- (void)setType:(STPopupLeftBarItemType)type animated:(BOOL)animated {
    _type = type;
    if (animated) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self updateLayout];
        } completion:nil];
    } else {
        [self updateLayout];
    }
}

- (void)updateLayout {
    CGFloat barWidth, barHeight = 1.5f, barX, bar1Y, bar2Y;
    switch (self.type) {
        case STPopupLeftBarItemCross: {
            barWidth = self.customView.height * 2 / 5;
            barX = (self.customView.width - barWidth) / 2;
            bar1Y = (self.customView.height - barHeight) / 2;
            bar2Y = bar1Y;
        }
            break;
        case STPopupLeftBarItemArrow: {
            barWidth = self.customView.height / 4;
            barX = (self.customView.width - barWidth) / 2 - barWidth / 2;
            bar1Y = (self.customView.height - barHeight) / 2 + (CGFloat)(barWidth / 2 * sin(M_PI_4));
            bar2Y = (self.customView.height - barHeight) / 2 - (CGFloat)(barWidth / 2 * sin(M_PI_4));
        }
            break;
        default:
            break;
    }
    self.bar1.transform = CGAffineTransformIdentity;
    self.bar2.transform = CGAffineTransformIdentity;
    self.bar1.frame = CGRectMake(barX, bar1Y, barWidth, barHeight);
    self.bar2.frame = CGRectMake(barX, bar2Y, barWidth, barHeight);
    
    self.bar1.transform = CGAffineTransformMakeRotation((CGFloat)M_PI_4);
    self.bar2.transform = CGAffineTransformMakeRotation((CGFloat)-M_PI_4);
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.bar1.backgroundColor = tintColor;
    self.bar2.backgroundColor = tintColor;
}

@end
