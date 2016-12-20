#import "MTAppDelegate.h"

#import "Secrets.h"
#import "STPopup.h"
#import "UIColor+MTTints.h"
#import "UIFont+MTHelpers.h"
#import <Analytics/Analytics.h>
#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import <Parse/Parse.h>
#import <SimulatorStatusMagic/SDStatusBarManager.h>

@implementation MTAppDelegate

#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [Fabric with:@[[Crashlytics class]]];
    [SEGAnalytics setupWithConfiguration:[SEGAnalyticsConfiguration configurationWithWriteKey:kSegmentWriteKey]];
    [Parse setApplicationId:kParseApplicationId
                  clientKey:kParseClientKey];
    
    self.applicationManager = [MTApplicationManager new];
    [self.applicationManager setMinimumBackgroundFetchIntervalForApplication:application];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

#ifdef SNAPSHOT
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    [SDStatusBarManager sharedInstance].timeString = [formatter stringFromDate:[NSDate date]];
    [[SDStatusBarManager sharedInstance] enableOverrides];
#endif
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.applicationManager.rootViewController];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    [self setUpAppearances];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    RACSignal *signal = [self.applicationManager performBackgroundFetch];
    [signal subscribeNext:^(id x) {
        completionHandler(UIBackgroundFetchResultNewData);
    } error:^(NSError *error) {
        completionHandler(UIBackgroundFetchResultFailed);
    }];
}

#pragma mark Private

- (void)setUpAppearances {
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [[STPopupNavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [STPopupNavigationBar appearance].shadowImage = [UIImage new];
    [STPopupNavigationBar appearance].translucent = NO;
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont mt_regularFontOfSize:17], NSForegroundColorAttributeName: [UIColor whiteColor] } forState:UIControlStateNormal];
}

@end
