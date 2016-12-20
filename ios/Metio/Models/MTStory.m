#import "MTStory.h"

#import "NSDate+MTHelpers.h"

@implementation MTStory

@dynamic image;
@dynamic text;
@dynamic uuid;
@dynamic city;
@dynamic rating;
@dynamic approved;
@dynamic expirationDate;

#pragma mark Initialization

- (instancetype)initWithImage:(PFFile *)image text:(NSString *)text city:(NSString *)city {
    self = [super init];
    if (!self) return nil;
    
    self.image = image;
    self.text = text;
    self.city = city;
    self.uuid = [UIDevice currentDevice].identifierForVendor.UUIDString;
    self.rating = @(0);
    self.approved = NO;
    self.expirationDate = [NSDate dateForHour:0];
    
    return self;
}

#pragma mark Public

- (RACSignal *)upvote {
    return [self vote:1];
}

- (RACSignal *)downvote {
    return [self vote:-1];
}

#pragma mark Private

- (RACSignal *)vote:(NSInteger)vote {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self fetchInBackgroundWithBlock:^(PFObject *updatedStory, NSError *fetchError) {
            if (fetchError) {
                [subscriber sendError:fetchError];
            } else {
                [(MTStory *)updatedStory setRating:@([[(MTStory *)updatedStory rating] integerValue] + vote)];
                [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *saveError) {
                    if (saveError) {
                        [subscriber sendError:saveError];
                    } else {
                        [subscriber sendNext:[(MTStory *)updatedStory rating]];
                        [subscriber sendCompleted];
                    }
                }];
            }
        }];
        return nil;
    }];
}

#pragma mark PFSubclassing

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"Story";
}

@end
