#import "MTApplicationManager.h"

@interface MTAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIWindow *window;
@property (nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) MTApplicationManager *applicationManager;

@end
