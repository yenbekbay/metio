//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTWeatherUpdateCache.h"

static NSString *const kLatestWeatherUpdateFileName = @"latestWeatherUpdateFile";

@interface MTWeatherUpdateCache ()

@property (nonatomic) NSURL *latestWeatherUpdateURL;

@end

@implementation MTWeatherUpdateCache

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    NSURL *documentsPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    self.latestWeatherUpdateURL = [documentsPath URLByAppendingPathComponent:kLatestWeatherUpdateFileName];
    
    return self;
}

- (MTWeatherUpdate *)latestWeatherUpdate {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self latestWeatherUpdateFilePath]];
}

- (BOOL)archiveWeatherUpdate:(MTWeatherUpdate *)update {
    return [NSKeyedArchiver archiveRootObject:update toFile:[self latestWeatherUpdateFilePath]];
}

- (NSString *)latestWeatherUpdateFilePath {
    return [self.latestWeatherUpdateURL path];
}

@end
