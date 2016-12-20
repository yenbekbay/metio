//
//  Copyright (c) 2015 Sth4Me.
//

#import "STPopupNavigationBar.h"

@interface STPopupNavigationBar ()

@property (nonatomic, getter=isMoving) BOOL moving;
@property (nonatomic) CGFloat movingStartY;

@end

@implementation STPopupNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    self.draggable = YES;
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.draggable) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ((touch.view == self || touch.view.superview == self) && !self.isMoving) {
        self.moving = YES;
        self.movingStartY = [touch locationInView:self.window].y;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.draggable) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    
    if (self.isMoving) {
        UITouch *touch = [touches anyObject];
        CGFloat offset = [touch locationInView:self.window].y - self.movingStartY;
        if ([self.touchEventDelegate respondsToSelector:@selector(popupNavigationBar:touchDidMoveWithOffset:)]) {
            [self.touchEventDelegate popupNavigationBar:self touchDidMoveWithOffset:offset];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.draggable) {
        [super touchesCancelled:touches withEvent:event];
        return;
    }
    
    if (self.isMoving) {
        UITouch *touch = [touches anyObject];
        CGFloat offset = [touch locationInView:self.window].y - self.movingStartY;
        [self movingDidEndWithOffset:offset];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.draggable) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    if (self.isMoving) {
        UITouch *touch = [touches anyObject];
        CGFloat offset = [touch locationInView:self.window].y - self.movingStartY;
        [self movingDidEndWithOffset:offset];
    }
}

- (void)movingDidEndWithOffset:(CGFloat)offset {
    self.moving = NO;
    if ([self.touchEventDelegate respondsToSelector:@selector(popupNavigationBar:touchDidEndWithOffset:)]) {
        [self.touchEventDelegate popupNavigationBar:self touchDidEndWithOffset:offset];
    }
}

@end
