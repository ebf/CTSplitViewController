//
//  CTSplitViewController.h
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@class CTSplitViewController;

@protocol CTSplitViewControllerDelegate <NSObject>

@optional
- (void)CTSplitViewController:(CTSplitViewController*)splitViewController 
     willHideViewController:(UIViewController *)viewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem;

- (void)CTSplitViewController:(CTSplitViewController *)splitViewController 
     willShowViewController:(UIViewController *)viewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem;
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
@interface CTSplitViewController : UIViewController <UIGestureRecognizerDelegate> {
@private
    id<CTSplitViewControllerDelegate> __unsafe_unretained _delegate;
    
    NSArray *_viewControllers;
    
    UIBarButtonItem *_barButtonItem;
    
    UISwipeGestureRecognizer *_leftSwipeGestureRecognizer;
    UISwipeGestureRecognizer *_rightSwipeGestureRecognizer;
    UITapGestureRecognizer *_tapGestureRecognizer;
    
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
@property (nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, assign) CTSplitViewControllerVisibleMasterViewOrientations supportedMasterViewOrientations;

- (void)morphMasterViewControllerInAnimated:(BOOL)animated;
- (void)morphMasterViewControllerOutAnimated:(BOOL)animated;

@end



@interface UIViewController (CTSplitViewController)

@property (nonatomic, readonly) CTSplitViewController *CTSplitViewController;

@end
