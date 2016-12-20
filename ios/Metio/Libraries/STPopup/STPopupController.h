//
//  Copyright (c) 2015 Sth4Me.
//

#import "STPopupNavigationBar.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, STPopupTransitionStyle) {
    STPopupTransitionStyleSlideVertical,
    STPopupTransitionStyleFade
};

@interface STPopupController : NSObject

#pragma mark Properties

@property (nonatomic, assign) STPopupTransitionStyle transitionStyle;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, strong, readonly) STPopupNavigationBar *navigationBar;
@property (nonatomic, assign, readonly) BOOL presented;

#pragma mark Methods

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

- (void)presentInViewController:(UIViewController *)viewController;
- (void)presentInViewController:(UIViewController *)viewController completion:(void (^)(void))completion;
- (void)dismiss;
- (void)dismissWithCompletion:(void (^)(void))completion;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllerAnimated:(BOOL)animated;

@end
