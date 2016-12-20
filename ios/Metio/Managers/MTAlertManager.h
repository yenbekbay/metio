@interface MTAlertManager : NSObject

+ (instancetype)sharedInstance;
- (void)showNotificationWithText:(NSString *)text;
- (void)showNotificationWithText:(NSString *)text color:(UIColor *)color;

@end
