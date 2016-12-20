//
//  Copyright (c) 2015 Sth4Me.
//

#import <UIKit/UIKit.h>

@class STPopupController;

@interface UIViewController (STPopup)

@property (nonatomic, assign) CGSize contentSizeInPopup;
@property (nonatomic, assign) CGSize landscapeContentSizeInPopup;
@property (nonatomic, weak, readonly) STPopupController *popupController;

@end
