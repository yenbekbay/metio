#import "MTStoriesView.h"

#import "EBCardCollectionViewLayout.h"
#import "MTStoriesManager.h"
#import "MTStoriesViewCell.h"
#import "MTStory.h"
#import "UIFont+MTHelpers.h"
#import "UIView+AYUtils.h"
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>
#import <Parse/Parse.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

UIOffset const kStoriesViewOffset = {20, 0};

@interface MTStoriesView () <UICollectionViewDataSource>

@property (nonatomic) NSArray *stories;
@property (copy, nonatomic) NSString *city;
@property (nonatomic) UILabel *nothingFoundLabel;
@property (nonatomic) DGActivityIndicatorView *activityIndicatorView;

@end

@implementation MTStoriesView

#pragma mark Initialization

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame collectionViewLayout:[EBCardCollectionViewLayout new]];
    if (!self) return nil;
    
    self.dataSource = self;
    self.pagingEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = NO;
    [(EBCardCollectionViewLayout *)self.collectionViewLayout setOffset:kStoriesViewOffset];
    [(EBCardCollectionViewLayout *)self.collectionViewLayout setLayoutType:EBCardCollectionLayoutHorizontal];
    [self registerClass:[MTStoriesViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MTStoriesViewCell class])];
    [self showActivityIndicatorView];
    
    self.nothingFoundLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.nothingFoundLabel.font = [UIFont mt_lightFontOfSize:[UIFont largeFontSize]];
    self.nothingFoundLabel.textColor = [UIColor whiteColor];
    self.nothingFoundLabel.textAlignment = NSTextAlignmentCenter;
    self.nothingFoundLabel.text = NSLocalizedString(@"Историй в вашем городе на сегодня пока нет. Предложите свою! :)", nil);
    self.nothingFoundLabel.numberOfLines = 0;
    self.nothingFoundLabel.hidden = YES;
    [self addSubview:self.nothingFoundLabel];
    
    return self;
}

#pragma mark Public

- (void)updateStoriesWithCity:(NSString *)city {
    self.city = city;
    self.stories = @[];
    [self reloadData];
    self.nothingFoundLabel.hidden = YES;
    [self showActivityIndicatorView];
    [[self loadStories] subscribeNext:^(NSArray *objects) {
        DDLogVerbose(@"Got stories: %@", objects);
        NSMutableArray *userStories = [[objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(MTStory *story, NSDictionary *bindings) {
            return [story.uuid isEqualToString:[UIDevice currentDevice].identifierForVendor.UUIDString];
        }]] mutableCopy];
        NSMutableArray *otherStories = [objects mutableCopy];
        [otherStories removeObjectsInArray:userStories];
        self.stories = [userStories arrayByAddingObjectsFromArray:otherStories];
        [self.activityIndicatorView removeFromSuperview];
        if (self.stories.count > 0) {
            [self reloadData];
        } else {
            self.nothingFoundLabel.hidden = NO;
        }
    } error:^(NSError *error) {
        DDLogError(@"Error while loading stories: %@", error);
    }];
}

#pragma mark Private

- (void)showActivityIndicatorView {
    if (self.activityIndicatorView) {
        [self.activityIndicatorView removeFromSuperview];
    }
    self.activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce];
    self.activityIndicatorView.center = CGPointMake(self.width/2, self.height/2);
    [self.activityIndicatorView startAnimating];
    [self addSubview:self.activityIndicatorView];
}

- (RACSignal *)loadStories {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[MTStoriesManager sharedInstance] isModerated] subscribeNext:^(NSNumber *moderated) {
            PFQuery *query;
            PFQuery *userQuery = [MTStory query];
            [userQuery whereKey:@"uuid" equalTo:[UIDevice currentDevice].identifierForVendor.UUIDString];
            if ([moderated boolValue]) {
                PFQuery *approvedQuery = [MTStory query];
                [approvedQuery whereKey:@"approved" equalTo:@(1)];
                [approvedQuery whereKey:@"rating" greaterThanOrEqualTo:@(-3)];
                query = [PFQuery orQueryWithSubqueries:@[approvedQuery, userQuery]];
            } else {
                PFQuery *ratingQuery = [MTStory query];
                [ratingQuery whereKey:@"rating" greaterThanOrEqualTo:@(-3)];
                query = [PFQuery orQueryWithSubqueries:@[userQuery, ratingQuery]];
            }
            
            [query whereKey:@"city" equalTo:self.city];
            [query orderByDescending:@"rating"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    [subscriber sendError:error];
                } else {
                    [subscriber sendNext:objects];
                    [subscriber sendCompleted];
                }
            }];
        }];
        return nil;
    }];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (NSInteger)self.stories.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTStoriesViewCell *cell = (MTStoriesViewCell *)[self dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MTStoriesViewCell class]) forIndexPath:indexPath];
    cell.story = self.stories[(NSUInteger)indexPath.row];
    return cell;
}

@end
