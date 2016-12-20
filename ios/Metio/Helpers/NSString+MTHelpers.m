#import "NSString+MTHelpers.h"

@implementation NSString (MTHelpers)

- (CGSize)sizeWithFont:(UIFont *)font width:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    return ([self boundingRectWithSize:CGSizeMake(width, 0)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                 attributes:@{NSParagraphStyleAttributeName:paragraphStyle.copy,
                                              NSFontAttributeName:font}
                                    context:nil]).size;
}

@end
