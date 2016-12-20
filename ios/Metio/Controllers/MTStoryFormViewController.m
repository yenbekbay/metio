#import "MTStoryFormViewController.h"

#import "DAKeyboardControl.h"
#import "JTProgressHUD.h"
#import "MTAlertManager.h"
#import "NSString+MTHelpers.h"
#import "UIColor+MTTints.h"
#import "UIFont+MTHelpers.h"
#import "UIImage+AYHelpers.h"
#import "UIImagePickerController+MTBugFix.h"
#import "UIView+AYUtils.h"
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextView.h>
#import <Photos/Photos.h>

static UIEdgeInsets const kStoryFormMargin = {0, 10, 0, 10};
static UIEdgeInsets const kStoryFormItemPadding = {10, 10, 10, 10};
static NSUInteger const kStoryCharsLimit = 200;
static CGFloat const kStoryFormFloatingLabelSpacing = 15;
static CGFloat const kStoryFormButtonHeight = 100;
static UIOffset const kStoryFormImageViewPadding = {10, 10};

@interface MTStoryFormViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) JVFloatLabeledTextView *storyTextView;
@property (nonatomic) CALayer *storyTextViewBorder;
@property (nonatomic) UIColor *tintColor;
@property (nonatomic) UIButton *imageButton;
@property (nonatomic) UIImageView *imageView;

@end

@implementation MTStoryFormViewController

- (instancetype)initWithTintColor:(UIColor *)tintColor {
    self = [super init];
    if (!self) return nil;
    
    self.tintColor = tintColor;
    self.contentSizeInPopup = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - kStoryFormMargin.left - kStoryFormMargin.right, kStoryFormItemPadding.top*2 + [self maxStoryTextViewHeight] + kStoryFormButtonHeight + kStoryFormItemPadding.bottom);
    
    return self;
}

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.view.accessibilityIdentifier = @"Story Form View";
    [self setUpViews];
    [self.storyTextView becomeFirstResponder];
}

#pragma mark Private

- (void)setUpViews {
    self.storyTextView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kStoryFormItemPadding.left, kStoryFormItemPadding.top, self.view.width - kStoryFormItemPadding.left - kStoryFormItemPadding.right, [self maxStoryTextViewHeight])];
    self.storyTextView.tintColor = self.tintColor;
    self.storyTextView.placeholder = [self placeholderStringWithCharsLeft:kStoryCharsLimit];
    self.storyTextView.placeholderTextColor = [UIColor lightGrayColor];
    self.storyTextView.textColor = [UIColor blackColor];
    self.storyTextView.font = [UIFont mt_regularFontOfSize:[UIFont mediumFontSize]];
    self.storyTextView.floatingLabelFont = [UIFont mt_regularFontOfSize:[UIFont smallFontSize]];
    self.storyTextView.floatingLabelTextColor = self.tintColor;
    self.storyTextView.delegate = self;
    self.storyTextView.accessibilityIdentifier = @"Story Text View";
    self.contentSizeInPopup = CGSizeMake(self.contentSizeInPopup.width, self.storyTextView.bottom);
    
    self.storyTextViewBorder = [CALayer layer];
    self.storyTextViewBorder.frame = CGRectMake(0, self.storyTextView.height - 1/[UIScreen mainScreen].scale, self.storyTextView.width, 1/[UIScreen mainScreen].scale);
    self.storyTextViewBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.storyTextView.layer addSublayer:self.storyTextViewBorder];
    [self.view addSubview:self.storyTextView];
    
    self.view.keyboardTriggerOffset = 20;
    [self.view addKeyboardPanningWithActionHandler:nil];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(kStoryFormItemPadding.left, self.storyTextView.bottom + kStoryFormItemPadding.top, self.view.width - kStoryFormItemPadding.left - kStoryFormItemPadding.right, kStoryFormButtonHeight)];
    [self.imageButton setTitle:NSLocalizedString(@"Выбрать фотографию", nil) forState:UIControlStateNormal];
    [self.imageButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.imageButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.1f]] forState:UIControlStateHighlighted];
    self.imageButton.layer.cornerRadius = 4;
    self.imageButton.clipsToBounds = YES;
    self.imageButton.accessibilityIdentifier = @"Image Button";
    self.imageButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self hideKeyboard];
        
        UIAlertController *alertController = [UIAlertController new];
        alertController.title = NSLocalizedString(@"Выберите фотографию", nil);
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Отмена", nil) style:UIAlertActionStyleCancel handler:nil]];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Сфотографировать", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UIImagePickerController *picker = [UIImagePickerController new];
                picker.allowsEditing = YES;
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            }]];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Выбрать из библиотеки", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImagePickerController *picker = [UIImagePickerController new];
            picker.allowsEditing = YES;
            picker.delegate = self;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            [self presentViewController:picker animated:YES completion:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Выбрать последнюю фотографию", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.synchronous = YES;
            PHFetchOptions *fetchOptions = [PHFetchOptions new];
            fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            PHFetchResult *photos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
            if (photos) {
                [[PHImageManager defaultManager] requestImageForAsset:[photos objectAtIndex:photos.count - 1] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                    CGFloat size = MIN(result.size.width, result.size.height);
                    CGImageRef imageRef = CGImageCreateWithImageInRect(result.CGImage, CGRectMake(0, 0, size, size));
                    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    self.imageButton.hidden = YES;
                    self.imageView.image = croppedImage;
                    self.imageView.hidden = NO;
                }];
            }
        }]];
        [self presentViewController:alertController animated:YES completion:nil];

        return [RACSignal empty];
    }];
    [self.view addSubview:self.imageButton];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.imageButton.frame, kStoryFormImageViewPadding.horizontal, kStoryFormImageViewPadding.vertical)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    self.imageView.hidden = YES;
    [self.view addSubview:self.imageView];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)onDone {
    NSString *trimmedText = [self.storyTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!self.imageView.image && trimmedText.length == 0) {
        [[MTAlertManager sharedInstance] showNotificationWithText:NSLocalizedString(@"Пожалуйста, введите текст и выберите фотографию", nil)];
    } else if (trimmedText.length == 0) {
        [[MTAlertManager sharedInstance] showNotificationWithText:NSLocalizedString(@"Пожалуйста, введите текст", nil)];
        [self.storyTextView becomeFirstResponder];
    } else if (!self.imageView.image) {
        [[MTAlertManager sharedInstance] showNotificationWithText:NSLocalizedString(@"Пожалуйста, выберите фотографию", nil)];
    } else {
        DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce];
        [activityIndicatorView startAnimating];
        [JTProgressHUD showWithView:activityIndicatorView];
        
        [[self.delegate createStoryWithText:trimmedText image:self.imageView.image] subscribeError:^(NSError *error) {
            [JTProgressHUD hide];
            [[MTAlertManager sharedInstance] showNotificationWithText:NSLocalizedString(@"Произошла ошибка. Попробуйте еще раз", nil)];
        } completed:^{
            [JTProgressHUD hide];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

- (CGFloat)maxStoryTextViewHeight {
    return [[@"" stringByPaddingToLength:kStoryCharsLimit withString: @"dummy" startingAtIndex:0] sizeWithFont:[UIFont mt_regularFontOfSize:[UIFont mediumFontSize]] width:CGRectGetWidth([UIScreen mainScreen].bounds) - kStoryFormMargin.left - kStoryFormMargin.right].height + [[self placeholderStringWithCharsLeft:kStoryCharsLimit] sizeWithAttributes: @{ NSFontAttributeName: [UIFont mt_regularFontOfSize:[UIFont smallFontSize]] }].height + kStoryFormFloatingLabelSpacing + kStoryFormItemPadding.bottom;
}

- (NSString *)placeholderStringWithCharsLeft:(NSUInteger)charsLeft {
    return [NSString localizedStringWithFormat:@"Ваша история (%@ %@ %@)", [self getNumEnding:(NSInteger)charsLeft endings:@[@"остался", @"осталось", @"осталось"]], @(charsLeft), [self getNumEnding:(NSInteger)charsLeft endings:@[@"символ", @"символа", @"символов"]]];
}

#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView != self.storyTextView) return YES;
    if ([text isEqualToString:@"\n"]) return NO;;
    if ([textView.text stringByAppendingString:text].length > kStoryCharsLimit) return NO;
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView != self.storyTextView) return;
    self.storyTextView.placeholder = [self placeholderStringWithCharsLeft:kStoryCharsLimit - textView.text.length];
}

#pragma mark Helpers

- (NSString *)getNumEnding:(NSInteger)number endings:(NSArray *)endings {
    NSString *ending;
    number = number % 100;
    if (number >= 11 && number <= 19) {
        ending = endings[2];
    } else {
        int i = number % 10;
        switch (i) {
            case 1:
                ending = endings[0];
                break;
            case 2:
                ending = endings[1];
                break;
            case 3:
                ending = endings[1];
                break;
            case 4:
                ending = endings[1];
                break;
            default:
                ending = endings[2];
                break;
        }
    }
    return ending;
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    if (chosenImage) {
        DDLogVerbose(@"User selected an image");
        self.imageButton.hidden = YES;
        self.imageView.image = chosenImage;
        self.imageView.hidden = NO;
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
