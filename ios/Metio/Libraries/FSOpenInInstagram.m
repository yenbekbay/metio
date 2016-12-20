//
//  Copyright (c) 2014 Felix Schulze.
//

#import "FSOpenInInstagram.h"

#define INSTAGRAM_URL_SCHEME @"instagram://app"

@implementation FSOpenInInstagram {
    UIDocumentInteractionController *documentInteractionController;
}

- (void)dealloc {
    documentInteractionController.delegate = nil;
}

+ (BOOL)canSendInstagram {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:INSTAGRAM_URL_SCHEME]];
}

- (void)postImage:(UIImage *)image caption:(NSString *)caption inView:(UIView *)view {
    [self postImage:image caption:caption inView:view delegate:nil];
}

- (void)postImage:(UIImage *)image caption:(NSString *)caption inView:(UIView *)view delegate:(id<UIDocumentInteractionControllerDelegate>)delegate {
    if (!image) {
        NSLog(@"ERROR: Image was nil");
        return;
    }

    NSString *filePath = [NSString stringWithFormat:@"%@/instagramshare.igo", NSTemporaryDirectory()];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    documentInteractionController.delegate = nil;
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    documentInteractionController.UTI = @"com.instagram.exclusivegram";
    documentInteractionController.delegate = delegate;
    if (caption) {
        documentInteractionController.annotation = [NSDictionary dictionaryWithObject:caption forKey:@"InstagramCaption"];
    }

    [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:view animated:YES];
}

@end
