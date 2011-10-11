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
}

@property (nonatomic, unsafe_unretained) id<CTSplitViewControllerDelegate> delegate;

@end



@interface UIViewController (CTSplitViewController)

@property (nonatomic, readonly) CTSplitViewController *CTSplitViewController;

@end
