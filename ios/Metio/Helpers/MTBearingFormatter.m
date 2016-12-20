//
//  Copyright © 2014 thoughtbot, inc., 2015 Ayan Yenbekbay.
//

#import "MTBearingFormatter.h"

typedef NS_ENUM(NSUInteger, MTCardinalDirection) {
    MTCardinalDirectionNorth,
    MTCardinalDirectionNorthEast,
    MTCardinalDirectionEast,
    MTCardinalDirectionSouthEast,
    MTCardinalDirectionSouth,
    MTCardinalDirectionSouthWest,
    MTCardinalDirectionWest,
    MTCardinalDirectionNorthWest
};

@implementation MTBearingFormatter

#pragma mark Public

+ (NSString *)cardinalDirectionStringFromBearing:(CGFloat)bearing {
    MTCardinalDirection direction = [self cardinalDirectionFromBearing:bearing];
    
    switch (direction) {
        case MTCardinalDirectionNorth:
            return NSLocalizedString(@"North", nil);
        case MTCardinalDirectionNorthEast:
            return NSLocalizedString(@"Northeast", nil);
        case MTCardinalDirectionEast:
            return NSLocalizedString(@"East", nil);
        case MTCardinalDirectionSouthEast:
            return NSLocalizedString(@"Southeast", nil);
        case MTCardinalDirectionSouth:
            return NSLocalizedString(@"South", nil);
        case MTCardinalDirectionSouthWest:
            return NSLocalizedString(@"Southwest", nil);
        case MTCardinalDirectionWest:
            return NSLocalizedString(@"West", nil);
        case MTCardinalDirectionNorthWest:
            return NSLocalizedString(@"Northwest", nil);
    }
}

+ (NSString *)abbreviatedCardinalDirectionStringFromBearing:(CGFloat)bearing {
    MTCardinalDirection direction = [self cardinalDirectionFromBearing:bearing];
    
    switch (direction) {
        case MTCardinalDirectionNorth:
            return NSLocalizedString(@"N", nil);
        case MTCardinalDirectionNorthEast:
            return NSLocalizedString(@"NE", nil);
        case MTCardinalDirectionEast:
            return NSLocalizedString(@"E", nil);
        case MTCardinalDirectionSouthEast:
            return NSLocalizedString(@"SE", nil);
        case MTCardinalDirectionSouth:
            return NSLocalizedString(@"S", nil);
        case MTCardinalDirectionSouthWest:
            return NSLocalizedString(@"SW", nil);
        case MTCardinalDirectionWest:
            return NSLocalizedString(@"W", nil);
        case MTCardinalDirectionNorthWest:
            return NSLocalizedString(@"NW", nil);
    }
}

#pragma mark Private

+ (MTCardinalDirection)cardinalDirectionFromBearing:(CGFloat)bearing {
    if (bearing < 22.5) {
        return MTCardinalDirectionNorth;
    } else if (bearing < 67.5) {
        return MTCardinalDirectionNorthEast;
    } else if (bearing < 112.5) {
        return MTCardinalDirectionEast;
    } else if (bearing < 157.5) {
        return MTCardinalDirectionSouthEast;
    } else if (bearing < 202.5) {
        return MTCardinalDirectionSouth;
    } else if (bearing < 247.5) {
        return MTCardinalDirectionSouthWest;
    } else if (bearing < 292.5) {
        return MTCardinalDirectionWest;
    } else if (bearing < 337.5) {
        return MTCardinalDirectionNorthWest;
    } else {
        return MTCardinalDirectionNorth;
    }
}

@end
