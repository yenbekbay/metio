#import "UILabel+MTHelpers.h"

#import "UIView+AYUtils.h"

@implementation UILabel (MTHelpers)

- (void)adjustFontSize:(NSUInteger)maxLines fontFloor:(CGFloat)fontFloor {
    while ([self overflows]) {
        self.font = [self.font fontWithSize:self.font.pointSize - 1];
    }
    CGFloat maxFontSize = self.font.pointSize;
    NSUInteger lines = 1;
    while ([self sizeToFitWithHeightLimit:0].height > [self.text sizeWithAttributes:@{ NSFontAttributeName:self.font }].height * lines) {
        if (self.font.pointSize > (lines == 1 ? fontFloor + 10 : fontFloor)) {
            self.font = [self.font fontWithSize:self.font.pointSize - 1];
        } else if (lines < maxLines) {
            lines++;
            self.font = [self.font fontWithSize:maxFontSize];
        } else {
            break;
        }
    }
    self.numberOfLines = (NSInteger)lines;
    self.height = [self.text sizeWithAttributes:@{ NSFontAttributeName:self.font }].height * lines;
}

- (BOOL)overflows {
    NSArray *words = [self.text componentsSeparatedByString:@" "];
    BOOL overflows = NO;
    for (NSString *word in words) {
        CGFloat wordLength;
        if (![word isEqualToString:[words lastObject]]) {
            wordLength = [[word stringByAppendingString:@" "] sizeWithAttributes:@{ NSFontAttributeName:self.font }].width;
        } else {
            wordLength = [word sizeWithAttributes:@{ NSFontAttributeName:self.font }].width;
        }
        if (wordLength >= self.width) {
            overflows = YES;
        }
    }
    return overflows;
}

- (void)setFrameToFitWithHeightLimit:(CGFloat)heightLimit {
    self.height = [self sizeToFitWithHeightLimit:heightLimit].height;
}

- (CGSize)sizeToFitWithHeightLimit:(CGFloat)heightLimit {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    return ([self.text boundingRectWithSize:CGSizeMake(self.width, heightLimit)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{ NSParagraphStyleAttributeName:paragraphStyle.copy,
                                                NSFontAttributeName:self.font }
                                     context:nil]).size;
}

@end
