#import "MTPromptView.h"

#import "UIFont+MTHelpers.h"
#import "UILabel+MTHelpers.h"
#import "UIView+AYUtils.h"

static UIEdgeInsets const kPromptViewPadding = {10, 10, 10, 10};
static CGFloat const kPromptViewLabelBottomMargin = 10;
static CGFloat const kPromptViewButtonHeight = 30;
static CGFloat const kPromptViewButtonSpacing = 10;
static NSString * const kInteractionKey = @"promptViewInteraction";

@interface MTPromptView ()

@property (nonatomic) UIView *container;
@property (nonatomic) UILabel *label;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UIButton *leftButton;
@property (nonatomic) UIButton *rightButton;

@property (nonatomic, assign) BOOL step2;
@property (nonatomic, assign) BOOL liked;

@end

@implementation MTPromptView

#pragma mark Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self setUpView];
    
    return self;
}

#pragma mark Lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = CGRectMake(kPromptViewPadding.left, kPromptViewPadding.top, self.width - kPromptViewPadding.left - kPromptViewPadding.right, 0);
    [self.label setFrameToFitWithHeightLimit:0];
    self.leftButton.frame = CGRectMake(kPromptViewPadding.left, self.label.bottom + kPromptViewLabelBottomMargin, (self.width - kPromptViewPadding.left - kPromptViewButtonSpacing - kPromptViewPadding.right)/2, kPromptViewButtonHeight);
    self.rightButton.frame = CGRectMake(self.leftButton.right + kPromptViewButtonSpacing, self.leftButton.top, self.leftButton.width, kPromptViewButtonHeight);
    self.height = self.rightButton.bottom + kPromptViewPadding.bottom;
}

#pragma mark Private

- (void)setUpView {
    self.label = [UILabel new];
    self.label.textColor = [UIColor darkGrayColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.numberOfLines = 0;
    self.label.font = [UIFont mt_lightFontOfSize:17];
    self.label.text = NSLocalizedString(@"Что вы думаете о Metio?", nil);
    [self addSubview:self.label];
    
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.backgroundColor = [UIColor darkGrayColor];
    self.leftButton.layer.cornerRadius = 4;
    self.leftButton.layer.masksToBounds = YES;
    [self.leftButton setTitle:NSLocalizedString(@"Мне нравится!", nil) forState:UIControlStateNormal];
    [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = [UIFont mt_lightFontOfSize:15];
    [self.leftButton addTarget:self action:@selector(onLove) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.backgroundColor = [UIColor darkGrayColor];
    self.rightButton.layer.cornerRadius = 4;
    self.rightButton.layer.masksToBounds = YES;
    [self.rightButton setTitle:NSLocalizedString(@"Так себе", nil) forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont mt_lightFontOfSize:15];
    [self.rightButton addTarget:self action:@selector(onImprove) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightButton];
    
    [self setNeedsLayout];
}

- (void)onLove {
    if (self.step2) {
        if (self.liked && self.delegate && [self.delegate respondsToSelector:@selector(promptForReview)]) {
            [self.delegate promptForReview];
        } else if (!self.liked && self.delegate && [self.delegate respondsToSelector:@selector(promptForFeedback)]) {
            [self.delegate promptForFeedback];
        }
    } else {
        self.liked = YES;
        self.step2 = YES;
        [UIView animateWithDuration:0.3f animations:^{
               self.label.text = NSLocalizedString(@"Отлично! Может быть тогда оставите нам отзыв? :)", nil);
               [self.leftButton setTitle:NSLocalizedString(@"Оставить отзыв", nil) forState:UIControlStateNormal];
               [self.rightButton setTitle:NSLocalizedString(@"Нет, спасибо", nil) forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                [self layoutSubviews];
                self.bottom = self.superview.height;
            }];
        }];
    }
}

- (void)onImprove {
    if (self.step2) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(promptClose)]) {
            [self.delegate promptClose];
        }
    } else {
        self.liked = NO;
        self.step2 = YES;
        [UIView animateWithDuration:0.3f animations:^{
               self.label.text = NSLocalizedString(@"Может быть скажете, как нам стать лучше?", nil);
               [self.leftButton setTitle:NSLocalizedString(@"Отправить отзыв", nil) forState:UIControlStateNormal];
               [self.rightButton setTitle:NSLocalizedString(@"Нет, спасибо", nil) forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3f animations:^{
                [self layoutSubviews];
                self.bottom = self.superview.height;
            }];
        }];
    }
}

+ (NSString *)keyForCurrentVersion {
    NSString *version = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"] ?: NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    return [kInteractionKey stringByAppendingString:version];
}

+ (NSNumber *)numberOfUsesForCurrentVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self keyForCurrentVersion]];
}

+ (void)incrementUsesForCurrentVersion {
    [MTPromptView numberOfUsesForCurrentVersion];
    [[NSUserDefaults standardUserDefaults] setObject:@([[MTPromptView numberOfUsesForCurrentVersion] ?: @(0) integerValue] + 1) forKey:[self keyForCurrentVersion]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
