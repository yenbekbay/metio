#import "MTAlertManager.h"

#import "UIFont+MTHelpers.h"
#import <CRToast/CRToast.h>

@implementation MTAlertManager

#pragma mark Initialization

+ (instancetype)sharedInstance {
    static MTAlertManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [MTAlertManager new];
    });
    return _sharedInstance;
}

#pragma mark Public

- (void)showNotificationWithText:(NSString *)text {
    [self showNotificationWithText:text color:[UIColor colorWithRed:0.91f green:0.3f blue:0.24f alpha:1]];
}

- (void)showNotificationWithText:(NSString *)text color:(UIColor *)color {
    NSDictionary *options = @{ kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                               kCRToastTextKey : text,
                               kCRToastFontKey : [UIFont mt_lightFontOfSize:[UIFont mediumFontSize]],
                               kCRToastBackgroundColorKey : color,
                               kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
                               kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeSpring),
                               kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                               kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionBottom) };
    [CRToastManager showNotificationWithOptions:options completionBlock:nil];
}

@end
