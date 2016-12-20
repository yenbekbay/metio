#import "MTStoriesViewCell.h"

#import "FSOpenInInstagram.h"
#import "MTStoriesManager.h"
#import "MTAppDelegate.h"
#import "UIFont+MTHelpers.h"
#import "UIImage+AYHelpers.h"
#import "UILabel+MTHelpers.h"
#import "UIView+AYUtils.h"

static UIEdgeInsets const kStoryCellLabelPadding = {10, 10, 10, 10};
static CGSize const kStoryCellToolbarButtonSize = {40, 40};
static CGSize const kStoryCellUserIconSize = {16, 16};
static CGFloat const kStoryCellUserIconRightMargin = 5;
static CGSize const kStoryCellShareIconSize = {30, 30};

@interface MTStoriesViewCell ()

@property (nonatomic) UIButton *downvoteButton;
@property (nonatomic) UIView *contentWrapper;
@property (nonatomic) UIButton *upvoteButton;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *userIconView;
@property (nonatomic) UILabel *label;
@property (nonatomic) UILabel *ratingLabel;
@property (nonatomic) UILabel *userLabel;
@property (nonatomic) UIView *overlayView;
@property (nonatomic) UIView *toolbar;
@property (nonatomic, getter=isUserCreated) BOOL userCreated;
@property (nonatomic) UIButton *shareButton;
@property (nonatomic) FSOpenInInstagram *instagrammer;

@end

@implementation MTStoriesViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.instagrammer = [FSOpenInInstagram new];
    
    self.contentWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
    [self.contentView addSubview:self.contentWrapper];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.contentWrapper.frame];
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentWrapper addSubview:self.imageView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.imageView.bounds];
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];
    [self.contentWrapper addSubview:self.overlayView];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(kStoryCellLabelPadding.left, 0, self.width - kStoryCellLabelPadding.left - kStoryCellLabelPadding.right, 0)];
    self.label.numberOfLines = 0;
    self.label.textColor = [UIColor whiteColor];
    [self.contentWrapper addSubview:self.label];
    
    self.userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kStoryCellLabelPadding.left, kStoryCellLabelPadding.top, kStoryCellUserIconSize.width, kStoryCellUserIconSize.height)];
    self.userIconView.tintColor = [UIColor colorWithWhite:1 alpha:0.75f];
    self.userIconView.image = [[UIImage imageNamed:@"StarIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.contentView addSubview:self.userIconView];
    
    self.userLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.userIconView.right + kStoryCellUserIconRightMargin, kStoryCellLabelPadding.top, 0, 0)];
    self.userLabel.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
    self.userLabel.font = [UIFont mt_lightFontOfSize:[UIFont mediumFontSize]];
    self.userLabel.text = NSLocalizedString(@"Ваша история", nil);
    [self.userLabel sizeToFit];
    self.userLabel.width = self.width - self.userIconView.right - kStoryCellUserIconRightMargin - kStoryCellLabelPadding.right;
    self.userLabel.centerY = self.userIconView.centerY;
    [self.contentView addSubview:self.userLabel];
    
    self.userCreated = NO;
    
    self.toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.imageView.bottom, self.width, self.height - self.width)];
    self.toolbar.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.toolbar];
    
    self.ratingLabel = [UILabel new];
    self.ratingLabel.font = [UIFont mt_lightFontOfSize:[UIFont mediumFontSize]];
    self.ratingLabel.textColor = [UIColor darkGrayColor];
    [self.toolbar addSubview:self.ratingLabel];
    
    self.upvoteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kStoryCellToolbarButtonSize.width, kStoryCellToolbarButtonSize.height)];
    self.upvoteButton.center = CGPointMake(self.toolbar.width / 4, self.toolbar.height / 2);
    [self.upvoteButton setImage:[[UIImage imageNamed:@"UpvoteIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    self.downvoteButton = [[UIButton alloc] initWithFrame:self.upvoteButton.frame];
    self.downvoteButton.centerX = self.toolbar.width * 3/4;
    [self.downvoteButton setImage:[[UIImage imageNamed:@"DownvoteIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    for (UIButton *button in @[self.upvoteButton,  self.downvoteButton]) {
        button.tintColor = [UIColor darkGrayColor];
        [self.toolbar addSubview:button];
    }
    
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kStoryCellShareIconSize.width - kStoryCellLabelPadding.right, kStoryCellLabelPadding.top, kStoryCellShareIconSize.width, kStoryCellShareIconSize.height)];
    self.shareButton.tintColor = [UIColor whiteColor];
    [self.shareButton setImage:[[UIImage imageNamed:@"ShareIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.shareButton];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(share:)];
    [self.contentWrapper addGestureRecognizer:longPressGestureRecognizer];
    
    return self;
}

- (void)share:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (longPressGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self share];
    }
}

- (void)share {
    UIImage *snapshot = [UIImage convertViewToImage:self.contentWrapper];
    if ([FSOpenInInstagram canSendInstagram]) {
        [self.instagrammer postImage:snapshot caption:@"#meteoapp @meteoapp" inView:self.superview];
    } else {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[snapshot] applicationActivities:nil];
        [[(MTAppDelegate *)[UIApplication sharedApplication].delegate navigationController].viewControllers[0] presentViewController:activityViewController animated:YES completion:nil];
    }
}

#pragma mark Lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.font = [UIFont mt_boldFontOfSize:[UIFont storyCeilFontSize]];
    [self.label adjustFontSize:8 fontFloor:[UIFont storyFloorFontSize]];
    self.label.bottom = self.width - kStoryCellLabelPadding.bottom;
    [self.ratingLabel sizeToFit];
    self.ratingLabel.center = CGPointMake(self.toolbar.width / 2, self.toolbar.height / 2);
}

- (void)prepareForReuse {
    _story = nil;
    self.imageView.image = nil;
    self.label.text = @"";
    self.userIconView.hidden = YES;
    self.userLabel.hidden = YES;
    [self enableButtons:YES];
    self.userCreated = NO;
}

#pragma mark Setters

- (void)setStory:(MTStory *)story {
    _story = story;
    
    [story.image getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (error) {
            DDLogError(@"Error while getting data for image: %@", error);
        } else {
            self.imageView.image = [UIImage imageWithData:imageData];
        }
    }];
    self.label.text = story.text;
    self.ratingLabel.text = [story.rating stringValue];
#ifdef SNAPSHOT
    self.userCreated = YES;
#else
    if ([story.uuid isEqualToString:[UIDevice currentDevice].identifierForVendor.UUIDString]) {
        self.userCreated = YES;
    }
#endif
    
    if ([[MTStoriesManager sharedInstance] hasVotedForStory:story] || self.isUserCreated) {
        [self enableButtons:NO];
    } else {
        self.upvoteButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            [self upvote];
            [self enableButtons:NO];
            [[story upvote] subscribeNext:^(NSNumber *newRating) {
                [self updateRating:newRating];
            } error:^(NSError *error) {
                [self downvote];
                [self enableButtons:YES];
                DDLogError(@"Error while upvoting story: %@", error);
            }];
            return [RACSignal empty];
        }];
        self.downvoteButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            [self downvote];
            [self enableButtons:NO];
            [[story downvote] subscribeNext:^(NSNumber *newRating) {
                [self updateRating:newRating];
            } error:^(NSError *error) {
                [self upvote];
                [self enableButtons:YES];
                DDLogError(@"Error while downvoting story: %@", error);
            }];
            return [RACSignal empty];
        }];
    }
    
    [self setNeedsLayout];
}

- (void)setUserCreated:(BOOL)userCreated {
    _userCreated = userCreated;
    self.userLabel.hidden = !userCreated;
    self.userIconView.hidden = !userCreated;
    if (userCreated) {
        [[[MTStoriesManager sharedInstance] isModerated] subscribeNext:^(NSNumber *moderated) {
            if ([moderated boolValue]) {
                self.userLabel.text = [NSString localizedStringWithFormat:@"Ваша история (%@)", (self.story.approved ? NSLocalizedString(@"Одобрено", nil) : NSLocalizedString(@"В модерации", nil))];
            }
        }];
    }
}

#pragma mark Private

- (void)enableButtons:(BOOL)enabled {
    for (UIButton *button in @[self.upvoteButton, self.downvoteButton]) {
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1 : 0.25f;
    }
}

- (void)upvote {
    self.ratingLabel.text = [@([self.story.rating integerValue] + 1) stringValue];
}

- (void)downvote {
    self.ratingLabel.text = [@([self.story.rating integerValue] - 1) stringValue];
}

- (void)updateRating:(NSNumber *)newRating {
    self.ratingLabel.text = [newRating stringValue];
    [[MTStoriesManager sharedInstance] votedForStory:self.story];
}

@end
