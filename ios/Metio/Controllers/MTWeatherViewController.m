#import "MTWeatherViewController.h"

#import "AYAppStore.h"
#import "AYFeedback.h"
#import "AYMacros.h"
#import "MTAboutViewController.h"
#import "MTAlertManager.h"
#import "MTDailyForecastViewModel.h"
#import "MTIconButton.h"
#import "MTPromptView.h"
#import "MTStoriesManager.h"
#import "MTStoriesView.h"
#import "MTStoryFormViewController.h"
#import "MTWeatherManager.h"
#import "MTWeatherView.h"
#import "UIColor+MTTints.h"
#import "UIFont+MTHelpers.h"
#import "UIImage+AYHelpers.h"
#import "UIView+AYUtils.h"
#import <MessageUI/MessageUI.h>

static UIEdgeInsets const kWeatherViewPadding = {40, 0, 80, 0};
static CGFloat const kShortcutButtonHeight = 44;
static CGFloat const kStoriesToolbarHeight = 50;
static CGFloat const kSubmitStoryButtonTopMargin = 20;
static CGFloat const kSubmitStoryButtonHeight = 44;
static CGFloat const kSubmitStoryButtonCornerRadius = 4;

@interface MTWeatherViewController () <UIScrollViewDelegate, MTStoryFormViewControllerDelegate, MFMailComposeViewControllerDelegate, MTPromptViewDelegate>

@property (nonatomic) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic) MTIconButton *storiesButton;
@property (nonatomic) MTIconButton *submitStoryButton;
@property (nonatomic) MTIconButton *weatherButton;
@property (nonatomic) MTStoriesView *storiesView;
@property (nonatomic) MTWeatherManager *manager;
@property (nonatomic) MTWeatherView *weatherView;
@property (nonatomic) UILabel *cityLabel;
@property (nonatomic) UILabel *lastUpdatedLabel;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) MTPromptView *promptView;

@end

@implementation MTWeatherViewController

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.manager = [MTWeatherManager new];
    
    return self;
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor defaultColor];
    self.navigationController.navigationBar.barTintColor = [UIColor defaultColor];
    [STPopupNavigationBar appearance].barTintColor = [UIColor defaultColor];
    [self.manager.backgroundColor subscribeNext:^(UIColor *color) {
        if (color) {
            self.view.backgroundColor = color;
            self.navigationController.navigationBar.barTintColor = color;
            [STPopupNavigationBar appearance].barTintColor = color;
        }        
    }];
    
    [self setUpNavigationBar];
    [self setUpScrollView];
    [self setUpWeatherView];
    [self setUpStoriesView];
    [self setUpShortcutButtons];
    
    [MTPromptView incrementUsesForCurrentVersion];
    [self setUpPromptView];
    
//    NSArray *forecastViews = @[self.oneDayForecastView, self.twoDayForecastView, self.threeDayForecastView];
//    [self.manager.dailyForecastViewModels subscribeNext:^(NSArray *viewModels) {
//        [forecastViews enumerateObjectsUsingBlock:^(MTDailyForecastView *view, NSUInteger index, BOOL *stop) {
//            view.viewModel = viewModels[index];
//        }];
//    }];
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] subscribeNext:^(id x) {
        @strongify(self)
        [self.manager.updateWeatherCommand execute:self];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] subscribeNext:^(id x) {
        @strongify(self)
        [MTPromptView incrementUsesForCurrentVersion];
        DDLogVerbose(@"Checking for prompt view");
        [self setUpPromptView];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    aboutButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        MTAboutViewController *aboutViewController = [MTAboutViewController new];
        STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:aboutViewController];
        popupController.cornerRadius = 4;
        popupController.transitionStyle = STPopupTransitionStyleSlideVertical;
        [popupController presentInViewController:self];
        return [RACSignal empty];
    }];
    aboutButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *aboutBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
    self.navigationItem.leftBarButtonItem = aboutBarButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.manager.updateWeatherCommand execute:self];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, self.scrollView.height*2);
}

#pragma mark Private

- (void)setUpNavigationBar {
    UIView *navigationBarTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 200, self.navigationController.navigationBar.height - 10)];
    self.navigationItem.titleView = navigationBarTitleView;
    
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navigationBarTitleView.width, navigationBarTitleView.height * 3/5)];
    self.cityLabel.font = [UIFont mt_lightFontOfSize:17];
    [navigationBarTitleView addSubview:self.cityLabel];
    
    self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, navigationBarTitleView.height * 3/5, navigationBarTitleView.width, navigationBarTitleView.height * 2/5)];
    self.lastUpdatedLabel.font = [UIFont mt_lightFontOfSize:13];
    [navigationBarTitleView addSubview:self.lastUpdatedLabel];
    
    for (UILabel *label in @[self.cityLabel, self.lastUpdatedLabel]) {
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithWhite:1 alpha:0.75f];
    }
    
    RAC(self.cityLabel, text) = self.manager.locationName;
    RAC(self.lastUpdatedLabel, text) = self.manager.status;
}

- (void)setUpScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    RAC(self, scrollView.scrollEnabled) = [self.manager.updateWeatherCommand.executing not];
    [self.view addSubview:self.scrollView];
    
    self.refreshControl = [UIRefreshControl new];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [[[[self.refreshControl rac_signalForControlEvents:UIControlEventValueChanged]
        map:^id(UIRefreshControl *control) {
            return [[[self.manager.updateWeatherCommand execute:control]
                       catchTo:[RACSignal empty]]
                       then:^RACSignal *{
                           return [RACSignal return:control];
                       }];
        }] concat]
        subscribeNext:^(UIRefreshControl *control) {
            [control endRefreshing];
        }];
    [self.scrollView addSubview:self.refreshControl];
}

- (void)setUpWeatherView {
    self.weatherView = [[MTWeatherView alloc] initWithFrame:CGRectMake(0, IS_IPHONE_4_OR_LESS ? 0 : kWeatherViewPadding.top, self.view.width, IS_IPHONE_4_OR_LESS ? (self.view.height - kShortcutButtonHeight) : (self.view.height - kWeatherViewPadding.top - kWeatherViewPadding.bottom))];
    self.weatherView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.weatherView bindWeatherManager:self.manager];
    [self.scrollView addSubview:self.weatherView];
}

- (void)setUpStoriesView {
    self.storiesView = [[MTStoriesView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, IS_IPHONE_4_OR_LESS ? (self.view.width * 4/5) : (self.view.width - kStoriesViewOffset.horizontal*2 + kStoriesToolbarHeight))];
    self.storiesView.centerY = self.scrollView.height * 1.5f - kSubmitStoryButtonHeight - kSubmitStoryButtonTopMargin + kShortcutButtonHeight/2;
    self.storiesView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.scrollView addSubview:self.storiesView];
    
    [self.manager.locationName subscribeNext:^(NSString *city) {
        if ([self isCityValid:city]) {
            [self.storiesView updateStoriesWithCity:city];
        }
    }];
    
    self.submitStoryButton = [[MTIconButton alloc] initWithFrame:CGRectMake(kStoriesViewOffset.horizontal, self.storiesView.bottom + kSubmitStoryButtonTopMargin, self.view.width - kStoriesViewOffset.horizontal*2, kSubmitStoryButtonHeight)];
    self.submitStoryButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.submitStoryButton setTitle:NSLocalizedString(@"Предложить историю", nil) forState:UIControlStateNormal];
    [self.submitStoryButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.submitStoryButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.75f]] forState:UIControlStateNormal];
    [self.submitStoryButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
    self.submitStoryButton.layer.cornerRadius = kSubmitStoryButtonCornerRadius;
    self.submitStoryButton.clipsToBounds = YES;
    self.submitStoryButton.accessibilityLabel = @"Submit Story Button";
    self.submitStoryButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        if ([self isCityValid:self.cityLabel.text]) {
            MTStoryFormViewController *storyFormViewController = [[MTStoryFormViewController alloc] initWithTintColor:self.view.backgroundColor];
            storyFormViewController.delegate = self;
            STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:storyFormViewController];
            popupController.navigationBar.accessibilityIdentifier = @"Story Form Navigation Bar";
            popupController.cornerRadius = 4;
            popupController.transitionStyle = STPopupTransitionStyleSlideVertical;
            [popupController presentInViewController:self];
        } else {
            [[MTAlertManager sharedInstance] showNotificationWithText:@"Проверьте свое подключение к интернету"];
        }
        return [RACSignal empty];
    }];
    [self.scrollView addSubview:self.submitStoryButton];
}

- (void)setUpShortcutButtons {
    self.storiesButton = [[MTIconButton alloc] initWithFrame:CGRectMake(0, self.view.height - kShortcutButtonHeight, self.view.width, kShortcutButtonHeight)];
    [self.storiesButton setTitle:NSLocalizedString(@"Истории", nil) forState:UIControlStateNormal];
    [self.storiesButton setImage:[[UIImage imageNamed:@"DownArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.storiesButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self.scrollView scrollRectToVisible:CGRectOffset(self.view.bounds, 0, self.view.height) animated:YES];
        return [RACSignal empty];
    }];
    self.storiesButton.accessibilityLabel = @"Stories Button";
    [self.scrollView addSubview:self.storiesButton];
    
    self.weatherButton = [[MTIconButton alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, kShortcutButtonHeight)];
    [self.weatherButton setTitle:NSLocalizedString(@"Прогноз", nil) forState:UIControlStateNormal];
    [self.weatherButton setImage:[[UIImage imageNamed:@"UpArrowIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.weatherButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self.scrollView scrollRectToVisible:self.view.bounds animated:YES];
        return [RACSignal empty];
    }];
    self.weatherButton.alpha = 0;
    self.weatherButton.accessibilityLabel = @"Weather Button";
    [self.scrollView addSubview:self.weatherButton];
    
    for (MTIconButton *button in @[self.storiesButton, self.weatherButton]) {
        button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        button.adjustsImageWhenHighlighted = NO;
        [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.05f]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.15f]] forState:UIControlStateHighlighted];
        button.titleLabel.font = [UIFont mt_lightFontOfSize:[UIFont largeFontSize]];
        button.imageView.tintColor = [UIColor colorWithWhite:1 alpha:0.5f];
    }
}

- (void)setUpPromptView {
#ifdef SNAPSHOT
    return;
#endif
    if (!self.promptView) {
        if ([[MTPromptView numberOfUsesForCurrentVersion] integerValue] == 5) {
            self.promptView = [[MTPromptView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
            self.promptView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            self.promptView.delegate = self;
            self.promptView.backgroundColor = [UIColor whiteColor];
            self.promptView.top = self.view.height;
            [self.view addSubview:self.promptView];
            [self performSelector:@selector(slideInFromBottom:) withObject:self.promptView afterDelay:1];
        }
    }
}

- (BOOL)isCityValid:(NSString *)city {
    return city && city.length > 0 && ![city isEqualToString:NSLocalizedString(@"CheckingWeather", nil)] && ![city isEqualToString:NSLocalizedString(@"UpdateFailed", nil)];
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        self.weatherButton.alpha = scrollView.contentOffset.y / self.scrollView.height;
        self.storiesButton.alpha = 1 - self.weatherButton.alpha;
    }
}

#pragma MTStoryFormViewControllerDelegate

- (RACSignal *)createStoryWithText:(NSString *)text image:(UIImage *)image {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[MTStoriesManager sharedInstance] createStoryWithText:text image:image city:self.cityLabel.text] subscribeNext:^(MTStory *story) {
            [subscriber sendNext:story];
            [subscriber sendCompleted];
            [self.storiesView updateStoriesWithCity:self.cityLabel.text];
        } error:^(NSError *error) {
            DDLogError(@"Error while creating story: %@", error);
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

#pragma mark MTPromptViewDelegate

- (void)promptForReview {
    [self slideOutToBottom:self.promptView completion:^(BOOL completed) {
        [self.promptView removeFromSuperview];
        [AYAppStore openAppStoreReview];
    }];
}

- (void)promptForFeedback {
    [self slideOutToBottom:self.promptView completion:^(BOOL completed) {
        [self.promptView removeFromSuperview];
        if ([MFMailComposeViewController canSendMail]) {
            AYFeedback *feedback = [AYFeedback new];
            self.mailComposeViewController = [MFMailComposeViewController new];
            self.mailComposeViewController.mailComposeDelegate = self;
            self.mailComposeViewController.toRecipients = @[@"ayan.yenb@gmail.com"];
            self.mailComposeViewController.subject = feedback.subject;
            [self.mailComposeViewController setMessageBody:feedback.messageWithMetaData isHTML:NO];
            [self presentViewController:self.mailComposeViewController animated:YES completion:nil];
        } else {
            [[MTAlertManager sharedInstance] showNotificationWithText:NSLocalizedString(@"Настройте ваш почтовый сервис", nil)];
        }
    }];
}

- (void)promptClose {
    [self slideOutToBottom:self.promptView completion:^(BOOL completed) {
        [self.promptView removeFromSuperview];
    }];
}

- (void)slideInFromBottom:(UIView *)view {
    [UIView animateWithDuration:0.3f animations:^{
        view.top -= view.height;
    } completion:nil];
}

- (void)slideOutToBottom:(UIView *)view completion:(void(^)(BOOL completed))completion {
    [UIView animateWithDuration:0.3f animations:^{
        view.top += view.height;
    } completion:completion];
}

@end
