#import "MTAboutViewController.h"

#import "AYAppStore.h"
#import "AYFeedback.h"
#import "MTAboutViewButton.h"
#import "MTAlertManager.h"
#import "UIFont+MTHelpers.h"
#import "UILabel+MTHelpers.h"
#import "UIView+AYUtils.h"
#import <MessageUI/MessageUI.h>

static UIEdgeInsets const kAboutViewMargin = {0, 10, 0, 10};
static UIEdgeInsets const kAboutViewPadding = {20, 20, 20, 20};
static CGFloat const kAboutViewButtonsSpacing = 20;
static CGFloat const kAboutViewHeight = 350;

@interface MTAboutViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic) MTAboutViewButton *shareButton;
@property (nonatomic) MTAboutViewButton *rateButton;
@property (nonatomic) MTAboutViewButton *mailButton;
@property (nonatomic) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic) UILabel *creditLabel;

@end

@implementation MTAboutViewController

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.contentSizeInPopup = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - kAboutViewMargin.left - kAboutViewMargin.right, kAboutViewHeight);
    
    return self;
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUpCreditLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self setUpButtons];
}

#pragma mark Private

- (void)setUpButtons {
    self.shareButton = [[MTAboutViewButton alloc] initWithFrame:CGRectMake(kAboutViewPadding.left, self.navigationController.navigationBar.bottom + kAboutViewPadding.top, self.view.width - kAboutViewPadding.left - kAboutViewPadding.right, 0) image:[UIImage imageNamed:@"ShareIcon"] buttonTitle:NSLocalizedString(@"Поделиться с друзьями", nil)];
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareButton];
    
    self.rateButton = [[MTAboutViewButton alloc] initWithFrame:CGRectMake(kAboutViewPadding.left, self.shareButton.bottom + kAboutViewButtonsSpacing, self.view.width - kAboutViewPadding.left - kAboutViewPadding.right, 0) image:[UIImage imageNamed:@"RateIcon"] buttonTitle:NSLocalizedString(@"Оставить рецензию в App Store", nil)];
    [self.rateButton addTarget:self action:@selector(rate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.rateButton];
    
    self.mailButton = [[MTAboutViewButton alloc] initWithFrame:CGRectMake(kAboutViewPadding.left, self.rateButton.bottom + kAboutViewButtonsSpacing, self.view.width - kAboutViewPadding.left - kAboutViewPadding.right, 0) image:[UIImage imageNamed:@"MailIcon"] buttonTitle:NSLocalizedString(@"Написать нам", nil)];
    [self.mailButton addTarget:self action:@selector(sendFeedback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mailButton];
}

- (void)setUpCreditLabel {
    self.creditLabel = [[UILabel alloc] initWithFrame:CGRectMake(kAboutViewPadding.left, 0, self.view.width - kAboutViewPadding.left - kAboutViewPadding.right, 0)];
    self.creditLabel.textColor = [UIColor lightGrayColor];
    self.creditLabel.font = [UIFont mt_lightFontOfSize:[UIFont smallFontSize]];
    self.creditLabel.numberOfLines = 0;
    self.creditLabel.textAlignment = NSTextAlignmentCenter;
    self.creditLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Metio %@\r© Аян Енбекбай", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    [self.creditLabel setFrameToFitWithHeightLimit:0];
    self.creditLabel.bottom = self.view.bottom - kAboutViewPadding.bottom;
    [self.view addSubview:self.creditLabel];
}

- (void)dismiss {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)share {
    NSString *itunesLink = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", kAppId];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"Взгляни на Metio, самый интуитивный способ узнать прогноз погоды: %@", itunesLink]] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)rate {
    [AYAppStore openAppStoreReview];
}

- (void)sendFeedback {
    if ([MFMailComposeViewController canSendMail]) {
        AYFeedback *feedback = [AYFeedback new];
        self.mailComposeViewController = [MFMailComposeViewController new];
        self.mailComposeViewController.mailComposeDelegate = self;
        self.mailComposeViewController.toRecipients = @[@"ayan.yenb@gmail.com"];
        self.mailComposeViewController.subject = feedback.subject;
        [self.mailComposeViewController setMessageBody:feedback.messageWithMetaData isHTML:NO];
        [self presentViewController:self.mailComposeViewController animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Настройте ваш почтовый сервис", nil) message:NSLocalizedString(@"Чтобы отправить нам письмо, вам необходим настроенный почтовый аккаунт.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ОК", nil) otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MFMailComposeResultSent) {
            [[MTAlertManager sharedInstance] showNotificationWithText:NSLocalizedString(@"Спасибо! Ваш отзыв был получен, и мы скоро с вами свяжемся.", nil) color:[UIColor colorWithRed:0.91f green:0.3f blue:0.24f alpha:1]];
        }
    }];
}

@end
