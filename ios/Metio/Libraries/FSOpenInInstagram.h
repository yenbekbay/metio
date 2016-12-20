//
//  Copyright (c) 2014 Felix Schulze.
//

#import <Foundation/Foundation.h>

@interface FSOpenInInstagram : NSObject

+ (BOOL)canSendInstagram;
- (void)postImage:(UIImage *)image caption:(NSString *)caption inView:(UIView *)view;
- (void)postImage:(UIImage *)image caption:(NSString *)caption inView:(UIView *)view delegate:(id <UIDocumentInteractionControllerDelegate>)delegate;

@end
