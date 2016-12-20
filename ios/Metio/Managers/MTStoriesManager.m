#import "MTStoriesManager.h"

#import "NSDate+MTHelpers.h"
#import <Parse/Parse.h>

static NSString * const kVotesKey = @"votes";
static NSString * const kVotesExpirationDate = @"votesExpirationDate";

@interface MTStoriesManager ()

@property (nonatomic) NSMutableArray *votes;
@property (nonatomic) NSNumber *moderated;

@end

@implementation MTStoriesManager

#pragma mark Initialization

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    [self restoreVotes];
    
    return self;
}

+ (instancetype)sharedInstance {
    static MTStoriesManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [MTStoriesManager new];
    });
    return _sharedInstance;
}

#pragma mark Public

- (BOOL)hasVotedForStory:(MTStory *)story {
    return [self.votes containsObject:story.objectId];
}

- (void)votedForStory:(MTStory *)story {
    [self.votes addObject:story.objectId];
    [self saveVotes];
}

- (RACSignal *)createStoryWithText:(NSString *)text image:(UIImage *)image city:(NSString *)city {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7f);
    PFFile *imageFile = [PFFile fileWithName:@"story-image.jpg" data:imageData];
    MTStory *story = [[MTStory alloc] initWithImage:imageFile text:text city:city];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [story saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [subscriber sendError:error];
            } else {
                [subscriber sendNext:story];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)isModerated {
    if (self.moderated) {
        return [RACSignal return:self.moderated];
    } else {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
                if (error) {
                    DDLogError(@"Error while getting configuration: %@", error);
                    [subscriber sendNext:@(0)];
                } else {
                    NSNumber *moderated = config[@"moderation"];
                    self.moderated = moderated;
                    [subscriber sendNext:moderated];
                }
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }
}

#pragma mark Private

- (void)restoreVotes {
    NSDate *votesExpirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:kVotesExpirationDate];
    if (votesExpirationDate) {
        if ([[NSDate date] compare:votesExpirationDate] != NSOrderedAscending) {
            [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kVotesKey];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:@[] forKey:kVotesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateForHour:0] forKey:kVotesExpirationDate];
    self.votes = [[[NSUserDefaults standardUserDefaults] objectForKey:kVotesKey] mutableCopy] ?: [NSMutableArray new];
}

- (void)saveVotes {
    [[NSUserDefaults standardUserDefaults] setObject:self.votes forKey:kVotesKey];
}

@end
