//
//  CTAppDelegate.h
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTSplitViewController.h"

@interface CTAppDelegate : UIResponder <UIApplicationDelegate, CTSplitViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
