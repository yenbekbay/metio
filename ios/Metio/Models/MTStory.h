#import <Parse/Parse.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MTStory : PFObject <PFSubclassing>

#pragma mark Properties

@property (nonatomic) PFFile *image;
@property (nonatomic) NSString *text;
@property (nonatomic) NSString *uuid;
@property (nonatomic) NSString *city;
@property (nonatomic) NSNumber *rating;
@property (nonatomic) BOOL approved;
@property (nonatomic) NSDate *expirationDate;

#pragma mark Methods

- (instancetype)initWithImage:(PFFile *)image text:(NSString *)text city:(NSString *)city;
- (RACSignal *)upvote;
- (RACSignal *)downvote;

@end
