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
    id<CTSplitViewControllerDelegate> __weak _delegate;
}

@property (nonatomic, weak) id<CTSplitViewControllerDelegate> delegate;

@end
