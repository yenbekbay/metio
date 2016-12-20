@protocol MTPromptViewDelegate <NSObject>

- (void)promptForReview;
- (void)promptForFeedback;
- (void)promptClose;

@end

@interface MTPromptView : UIView

#pragma mark Properties

@property (weak) id<MTPromptViewDelegate> delegate;

#pragma mark Methods

+ (NSNumber *)numberOfUsesForCurrentVersion;
+ (void)incrementUsesForCurrentVersion;

@end
