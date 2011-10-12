//
//  CTSplitViewController.h
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTSplitViewController;

@protocol CTSplitViewControllerDelegate <NSObject>
@end





typedef enum {
    CTSplitViewControllerVisibleMasterViewOrientationUnkown                         = 0,
    CTSplitViewControllerVisibleMasterViewOrientationPortrait                       = 2 << 0,
    CTSplitViewControllerVisibleMasterViewOrientationPortraitUpsideDown             = 2 << 1,
    CTSplitViewControllerVisibleMasterViewOrientationLandscapeLeft                  = 2 << 2,
    CTSplitViewControllerVisibleMasterViewOrientationLandscapeRight                 = 2 << 3
} CTSplitViewControllerVisibleMasterViewOrientation;
typedef NSInteger CTSplitViewControllerVisibleMasterViewOrientations;





/**
 @class         CTSplitViewController
 @abstract      parent view controller that mimics the behaviour of a UISplitViewController but with additional features.
 */
@interface CTSplitViewController : UIViewController {
@private
    id<CTSplitViewControllerDelegate> __unsafe_unretained _delegate;
    
    NSArray *_viewControllers;
    
    UISwipeGestureRecognizer *_leftSwipeGestureRecognizer;
    UISwipeGestureRecognizer *_rightSwipeGestureRecognizer;
    
    CTSplitViewControllerVisibleMasterViewOrientations _supportedMasterViewOrientations;
}

@property (nonatomic, unsafe_unretained) id<CTSplitViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, readonly) UIViewController *masterViewController;
@property (nonatomic, readonly) UIViewController *detailsViewController;

@property (nonatomic, assign, getter=isMasterViewControllerHidden) BOOL masterViewControllerHidden;
- (void)setMasterViewControllerHidden:(BOOL)masterViewControllerHidden animated:(BOOL)animated;

@property (nonatomic, assign) CGFloat masterViewControllerWidth;
- (void)setMasterViewControllerWidth:(CGFloat)masterViewControllerWidth animated:(BOOL)animated;

@property (nonatomic, readonly) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, readonly) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

@property (nonatomic, assign) CTSplitViewControllerVisibleMasterViewOrientations supportedMasterViewOrientations;

@end



@interface UIViewController (CTSplitViewController)

@property (nonatomic, readonly) CTSplitViewController *CTSplitViewController;

@end
