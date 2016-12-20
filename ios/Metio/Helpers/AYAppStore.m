#import "AYAppStore.h"

NSString * const kAppId = @"1055506207";

@implementation AYAppStore

+ (void)openAppStoreReview {
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.1" options:NSNumericSearch] != NSOrderedAscending) {
        // Since 7.1 we can throw to the review tab
        NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8", kAppId];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    } else {
        [self openAppStore];
    }
}

+ (void)openAppStore {
    NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/kz/app/app/id%@?mt=8", kAppId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
