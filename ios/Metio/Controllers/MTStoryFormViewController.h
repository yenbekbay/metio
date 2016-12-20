#import "STPopup.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol MTStoryFormViewControllerDelegate <NSObject>

@required
- (RACSignal *)createStoryWithText:(NSString *)text image:(UIImage *)image;

@end

@interface MTStoryFormViewController : UIViewController

#pragma mark Properties

@property (weak, nonatomic) id<MTStoryFormViewControllerDelegate> delegate;

#pragma mark Methods

- (instancetype)initWithTintColor:(UIColor *)tintColor;

@end
