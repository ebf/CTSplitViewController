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



@interface CTSplitViewController : UIViewController {
@private
    id<CTSplitViewControllerDelegate> __unsafe_unretained _delegate;
    
    NSArray *_viewControllers;
}

@property (nonatomic, unsafe_unretained) id<CTSplitViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, readonly) UIViewController *masterViewController;
@property (nonatomic, readonly) UIViewController *detailsViewController;

@end



@interface UIViewController (CTSplitViewController)

@property (nonatomic, readonly) CTSplitViewController *CTSplitViewController;

@end
