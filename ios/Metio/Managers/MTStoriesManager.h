#import "MTStory.h"

@interface MTStoriesManager : NSObject

+ (instancetype)sharedInstance;
- (BOOL)hasVotedForStory:(MTStory *)story;
- (void)votedForStory:(MTStory *)story;
- (RACSignal *)createStoryWithText:(NSString *)text image:(UIImage *)image city:(NSString *)city;
- (RACSignal *)isModerated;

@end
