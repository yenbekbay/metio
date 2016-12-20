//
//  Copyright (c) 2015 Sth4Me.
//

#import "STPopupController.h"

#import "STPopupLeftBarItem.h"
#import "STPopupNavigationBar.h"
#import "UIViewController+STPopup.h"
#import "UIResponder+STPopup.h"
#import "UIView+AYUtils.h"

static NSMutableSet *_retainedPopupControllers;

@interface STPopupContainerViewController : UIViewController

@end

@implementation STPopupContainerViewController

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.childViewControllers.lastObject;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.childViewControllers.lastObject;
}

@end

@interface STPopupController () <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, STPopupNavigationTouchEventDelegate>

@property (nonatomic) STPopupContainerViewController *containerViewController;
@property (nonatomic) NSMutableArray *viewControllers; // <UIViewController>
@property (nonatomic) UIView *bgView;
@property (nonatomic) UIView *containerView;
@property (nonatomic) UIView *contentView;
@property (nonatomic) UILabel *defaultTitleLabel;
@property (nonatomic) STPopupLeftBarItem *defaultLeftBarItem;
@property (nonatomic) NSDictionary *keyboardInfo;
@property (nonatomic, getter=isObserving) BOOL observing;

@end

@implementation STPopupController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _retainedPopupControllers = [NSMutableSet new];
    });
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    [self setup];
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [self init];
    if (!self) return nil;
    
    [self pushViewController:rootViewController animated:NO];
    
    return self;
}

- (void)dealloc {
    [self destroyObservers];
    for (UIViewController *viewController in self.viewControllers) { // Avoid crash when try to access unsafe unretained property
        [viewController setValue:nil forKey:@"popupController"];
    }
}

- (BOOL)presented {
    return self.containerViewController.presentingViewController != nil;
}

#pragma mark - Observers

- (void)setupObservers {
    if (self.isObserving) {
        return;
    }
    self.observing = YES;
    
    // Observe navigation bar
    [self.navigationBar addObserver:self forKeyPath:NSStringFromSelector(@selector(tintColor)) options:NSKeyValueObservingOptionNew context:nil];
    [self.navigationBar addObserver:self forKeyPath:NSStringFromSelector(@selector(titleTextAttributes)) options:NSKeyValueObservingOptionNew context:nil];
    
    // Observe orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    // Observe keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // Observe responder change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponderDidChange) name:STPopupFirstResponderDidChangeNotification object:nil];
}

- (void)destroyObservers {
    if (!self.observing) {
        return;
    }
    self.observing = NO;
    
    [self.navigationBar removeObserver:self forKeyPath:NSStringFromSelector(@selector(tintColor))];
    [self.navigationBar removeObserver:self forKeyPath:NSStringFromSelector(@selector(titleTextAttributes))];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.navigationBar) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(tintColor))]) {
            self.defaultLeftBarItem.tintColor = change[@"new"];
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(titleTextAttributes))]) {
            self.defaultTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.defaultTitleLabel.text ? : @""
                                                                                attributes:change[@"new"]];
        }
    }
}

#pragma mark - STPopupController present & dismiss & push & pop

- (void)presentInViewController:(UIViewController *)viewController {
    [self presentInViewController:viewController completion:nil];
}

- (void)presentInViewController:(UIViewController *)viewController completion:(void (^)(void))completion {
    if (self.presented) {
        return;
    }
    
    [self setupObservers];
    
    [_retainedPopupControllers addObject:self];
    [viewController presentViewController:self.containerViewController animated:YES completion:completion];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    if (!self.presented) {
        return;
    }
    
    [self destroyObservers];
    
    [self.containerViewController dismissViewControllerAnimated:YES completion:^{
        [_retainedPopupControllers removeObject:self];
        if (completion) {
            completion();
        }
    }];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!self.viewControllers) {
        self.viewControllers = [NSMutableArray new];
    }
    
    UIViewController *topViewController = [self topViewController];
    [viewController setValue:self forKey:@"popupController"];
    [self.viewControllers addObject:viewController];
    
    if (self.presented) {
        [self transitFromViewController:topViewController toViewController:viewController animated:animated];
    }
}

- (void)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count <= 1) {
        [self dismiss];
        return;
    }
    
    UIViewController *topViewController = [self topViewController];
    [topViewController setValue:nil forKey:@"popupController"];
    [self.viewControllers removeObject:topViewController];
    
    if (self.presented) {
        [self transitFromViewController:topViewController toViewController:[self topViewController] animated:animated];
    }
}

- (void)transitFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController animated:(BOOL)animated {
    [fromViewController willMoveToParentViewController:nil];
    [self.containerViewController addChildViewController:toViewController];
    
    if (animated) {
        // Capture view in "fromViewController" to avoid "viewWillAppear" and "viewDidAppear" being called.
        UIGraphicsBeginImageContextWithOptions(fromViewController.view.bounds.size, NO, [UIScreen mainScreen].scale);
        [fromViewController.view drawViewHierarchyInRect:fromViewController.view.bounds afterScreenUpdates:NO];

        UIImageView *capturedView = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
        
        UIGraphicsEndImageContext();
        
        capturedView.frame = CGRectMake(self.contentView.left, self.contentView.top, fromViewController.view.width, fromViewController.view.height);
        [self.containerView insertSubview:capturedView atIndex:0];
        
        [fromViewController.view removeFromSuperview];
        
        self.containerView.userInteractionEnabled = NO;
        toViewController.view.alpha = 0;
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self layoutContainerView];
            [self.contentView addSubview:toViewController.view];
            capturedView.alpha = 0;
            toViewController.view.alpha = 1;
            [self.containerViewController setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [capturedView removeFromSuperview];
            [fromViewController removeFromParentViewController];
            
            self.containerView.userInteractionEnabled = YES;
            [toViewController didMoveToParentViewController:self.containerViewController];
        }];
        [self updateNavigationBarAnimated:animated];
    } else {
        [self layoutContainerView];
        [self.contentView addSubview:toViewController.view];
        [self.containerViewController setNeedsStatusBarAppearanceUpdate];
        [self updateNavigationBarAnimated:animated];
        
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        
        [toViewController didMoveToParentViewController:self.containerViewController];
    }
}

- (void)updateNavigationBarAnimated:(BOOL)animated {
    UIViewController *topViewController = [self topViewController];
    UIView *lastTitleView = self.navigationBar.topItem.titleView;
    self.navigationBar.items = @[ [UINavigationItem new] ];
    self.navigationBar.topItem.leftBarButtonItems = topViewController.navigationItem.leftBarButtonItems ? : @[ self.defaultLeftBarItem ];
    self.navigationBar.topItem.rightBarButtonItems = topViewController.navigationItem.rightBarButtonItems;
    
    if (animated) {
        UIView *fromTitleView, *toTitleView;
        if (lastTitleView == self.defaultTitleLabel)    {
            UILabel *tempLabel = [[UILabel alloc] initWithFrame:self.defaultTitleLabel.frame];
            tempLabel.textColor = self.defaultTitleLabel.textColor;
            tempLabel.font = self.defaultTitleLabel.font;
            tempLabel.attributedText = [[NSAttributedString alloc] initWithString:self.defaultTitleLabel.text ? : @""
                                                                       attributes:self.navigationBar.titleTextAttributes];
            fromTitleView = tempLabel;
        } else {
            fromTitleView = lastTitleView;
        }
        
        if (topViewController.navigationItem.titleView) {
            toTitleView = topViewController.navigationItem.titleView;
        } else {
            self.defaultTitleLabel = [UILabel new];
            self.defaultTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:topViewController.title ? : @""
                                                                                attributes:self.navigationBar.titleTextAttributes];
            [self.defaultTitleLabel sizeToFit];
            toTitleView = self.defaultTitleLabel;
        }
        
        [self.navigationBar addSubview:fromTitleView];
        self.navigationBar.topItem.titleView = toTitleView;
        toTitleView.alpha = 0;
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromTitleView.alpha = 0;
            toTitleView.alpha = 1;
        } completion:^(BOOL finished) {
            [fromTitleView removeFromSuperview];
        }];
    } else {
        if (topViewController.navigationItem.titleView) {
            self.navigationBar.topItem.titleView = topViewController.navigationItem.titleView;
        } else {
            self.defaultTitleLabel = [UILabel new];
            self.defaultTitleLabel.attributedText = [[NSAttributedString alloc] initWithString:topViewController.title ? : @""
                                                                                attributes:self.navigationBar.titleTextAttributes];
            [self.defaultTitleLabel sizeToFit];
            self.navigationBar.topItem.titleView = self.defaultTitleLabel;
        }
    }
    self.defaultLeftBarItem.tintColor = self.navigationBar.tintColor;
    [self.defaultLeftBarItem setType:self.viewControllers.count > 1 ? STPopupLeftBarItemArrow : STPopupLeftBarItemCross animated:animated];
}

- (UIViewController *)topViewController {
    return self.viewControllers.lastObject;
}

#pragma mark - UI layout

- (void)layoutContainerView {
    self.bgView.frame = self.containerViewController.view.bounds;
 
    CGFloat navigationBarHeight = [self navigationBarHeight];
    CGSize contentSizeOfTopView = [self contentSizeOfTopView];
    CGSize containerViewSize = CGSizeMake(contentSizeOfTopView.width, contentSizeOfTopView.height + navigationBarHeight);
    
    self.containerView.frame = CGRectMake((self.containerViewController.view.width - containerViewSize.width) / 2,
                                      (self.containerViewController.view.height - containerViewSize.height) / 2,
                                      containerViewSize.width, containerViewSize.height);
    self.navigationBar.frame = CGRectMake(0, 0, containerViewSize.width, navigationBarHeight);
    self.contentView.frame = CGRectMake(0, navigationBarHeight, contentSizeOfTopView.width, contentSizeOfTopView.height);
    
    UIViewController *topViewController = [self topViewController];
    topViewController.view.frame = self.contentView.bounds;
}

- (CGSize)contentSizeOfTopView {
    UIViewController *topViewController = [self topViewController];
    CGSize contentSize = CGSizeZero;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            contentSize = topViewController.landscapeContentSizeInPopup;
            if (CGSizeEqualToSize(contentSize, CGSizeZero)) {
                contentSize = topViewController.contentSizeInPopup;
            }
        }
            break;
        default: {
            contentSize = topViewController.contentSizeInPopup;
        }
            break;
    }
    
    NSAssert(!CGSizeEqualToSize(contentSize, CGSizeZero), @"contentSizeInPopup should not be size zero.");
    
    return contentSize;
}

- (CGFloat)navigationBarHeight {
    // The preferred height of navigation bar is different between iPhone (4, 5, 6) and 6 Plus.
    // Create a navigation controller to get the preferred height of navigation bar.
    UINavigationController *navigationController = [UINavigationController new];
    return navigationController.navigationBar.height;
}

#pragma mark - UI setup

- (void)setup {
    self.containerViewController = [STPopupContainerViewController new];
    self.containerViewController.view.backgroundColor = [UIColor clearColor];
    self.containerViewController.modalPresentationStyle = UIModalPresentationCustom;
    self.containerViewController.transitioningDelegate = self;
    [self setupBackgroundView];
    [self setupContainerView];
    [self setupNavigationBar];
}

- (void)setupBackgroundView {
    self.bgView = [UIView new];
    self.bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgViewDidTap)]];
    [self.containerViewController.view addSubview:self.bgView];
}

- (void)setupContainerView {
    self.containerView = [UIView new];
    self.containerView.backgroundColor = [UIColor whiteColor];
    self.containerView.clipsToBounds = YES;
    [self.containerViewController.view addSubview:self.containerView];
    
    self.contentView = [UIView new];
    [self.containerView addSubview:self.contentView];
}

- (void)setupNavigationBar {
    _navigationBar = [STPopupNavigationBar new];
    _navigationBar.touchEventDelegate = self;
    [self.containerView addSubview:_navigationBar];
    
    self.defaultTitleLabel = [UILabel new];
    self.defaultLeftBarItem = [[STPopupLeftBarItem alloc] initWithTarget:self action:@selector(leftBarItemDidTap)];
}

- (void)leftBarItemDidTap {
    switch (self.defaultLeftBarItem.type) {
        case STPopupLeftBarItemCross:
            [self dismiss];
            break;
        case STPopupLeftBarItemArrow:
            [self popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

- (void)bgViewDidTap {
    [self.containerView endEditing:YES];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.containerView.layer.cornerRadius = self.cornerRadius;
}

#pragma mark - UIApplicationDidChangeStatusBarOrientationNotification

- (void)orientationDidChange {
    [self.containerView endEditing:YES];
    [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.alpha = 0;
    } completion:^(BOOL finished) {
        [self layoutContainerView];
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.containerView.alpha = 1;
        } completion:nil];
    }];
}

#pragma mark - UIKeyboardWillShowNotification & UIKeyboardWillHideNotification

- (void)keyboardWillShow:(NSNotification *)notification {
    UIView<UIKeyInput> *currentTextInput = [self getCurrentTextInputInView:self.containerView];
    if (!currentTextInput) {
        return;
    }
    
    self.keyboardInfo = notification.userInfo;
    [self adjustContainerViewOrigin];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.keyboardInfo = nil;
    
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    
    self.containerView.transform = CGAffineTransformIdentity;
    
    [UIView commitAnimations];
}

- (void)adjustContainerViewOrigin {
    if (!self.keyboardInfo) {
        return;
    }
    
    UIView<UIKeyInput> *currentTextInput = [self getCurrentTextInputInView:self.containerView];
    if (!currentTextInput) {
        return;
    }
    
    CGAffineTransform lastTransform = self.containerView.transform;
    self.containerView.transform = CGAffineTransformIdentity; // Set transform to identity for calculating a correct "minOffsetY"
    
    CGFloat textFieldBottomY = [currentTextInput convertPoint:CGPointZero toView:self.containerViewController.view].y + currentTextInput.height;
    CGFloat keyboardHeight = [self.keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    // For iOS 7
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 &&
        (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)) {
        keyboardHeight = [self.keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    }
    
    CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    
    CGFloat offsetY = self.containerView.centerY - (self.containerViewController.view.height + statusBarHeight - keyboardHeight)/2;
    if (offsetY == 0) {
        return;
    }
    
    if (self.containerView.top - offsetY < statusBarHeight) { // self.containerView will be covered by status bar if it is repositioned with "offsetY"
        offsetY = self.containerView.top - statusBarHeight;
        // currentTextField can not be totally shown if self.containerView is going to repositioned with "offsetY"
        if (textFieldBottomY - offsetY > self.containerViewController.view.height - keyboardHeight) {
            offsetY = textFieldBottomY - (self.containerViewController.view.height - keyboardHeight);
        }
    }
    
    NSTimeInterval duration = [self.keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [self.keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    self.containerView.transform = lastTransform; // Restore transform
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    
    self.containerView.transform = CGAffineTransformMakeTranslation(0, -offsetY);
    
    [UIView commitAnimations];
}

- (UIView<UIKeyInput> *)getCurrentTextInputInView:(UIView *)view {
    if ([view conformsToProtocol:@protocol(UIKeyInput)] && view.isFirstResponder) {
        return (UIView<UIKeyInput> *)view;
    }
    
    for (UIView *subview in view.subviews) {
        UIView<UIKeyInput> *currentTextInput = [self getCurrentTextInputInView:subview];
        if (currentTextInput) {
            return currentTextInput;
        }
    }
    return nil;
}

#pragma mark - STPopupFirstResponderDidChangeNotification

- (void)firstResponderDidChange {
    // "keyboardWillShow" won't be called if height of keyboard is not changed
    // Manually adjust container view origin according to last keyboard info
    [self adjustContainerViewOrigin];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (toViewController == self.containerViewController) {
        return 0.5;
    }
    else {
        return self.transitionStyle == STPopupTransitionStyleFade ? 0.4 : 0.7;
    }
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    toViewController.view.frame = fromViewController.view.frame;
    
    if (toViewController == self.containerViewController) {
        [[transitionContext containerView] addSubview:toViewController.view];
        
        dispatch_async(dispatch_get_main_queue(), ^{ // To avoid calling viewDidAppear before the animation is started
            [self transitFromViewController:nil toViewController:[self topViewController] animated:NO];
            
            switch (self.transitionStyle) {
                case STPopupTransitionStyleFade: {
                    self.containerView.alpha = 0;
                    self.containerView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                }
                    break;
                case STPopupTransitionStyleSlideVertical:
                default: {
                    self.containerView.alpha = 1;
                    self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerViewController.view.height + self.containerView.height);
                }
                    break;
            }
            self.bgView.alpha = 0;
            
            self.containerView.userInteractionEnabled = NO;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.bgView.alpha = 1;
                self.containerView.alpha = 1;
                self.containerView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.containerView.userInteractionEnabled = YES;
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        });
    } else {
        self.containerView.userInteractionEnabled = NO;
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.bgView.alpha = 0;
            switch (self.transitionStyle) {
                case STPopupTransitionStyleFade: {
                    self.containerView.alpha = 0;
                    self.containerView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
                }
                    break;
                case STPopupTransitionStyleSlideVertical:
                default: {
                    self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerViewController.view.height + self.containerView.height);
                }
                    break;
            }
        } completion:^(BOOL finished) {
            self.containerView.userInteractionEnabled = YES;
            self.containerView.transform = CGAffineTransformIdentity;
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

#pragma mark - STPopupNavigationTouchEventDelegate

- (void)popupNavigationBar:(STPopupNavigationBar *)navigationBar touchDidMoveWithOffset:(CGFloat)offset {
    [self.containerView endEditing:YES];
    self.containerView.transform = CGAffineTransformMakeTranslation(0, offset);
}

- (void)popupNavigationBar:(STPopupNavigationBar *)navigationBar touchDidEndWithOffset:(CGFloat)offset {
    if (offset > 150) {
        STPopupTransitionStyle transitionStyle = self.transitionStyle;
        self.transitionStyle = STPopupTransitionStyleSlideVertical;
        [self dismissWithCompletion:^{
            self.transitionStyle = transitionStyle;
        }];
    } else {
        [self.containerView endEditing:YES];
        [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.containerView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

@end
