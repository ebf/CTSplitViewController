//
//  CTAppDelegate.m
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright (c) 2011 Home. All rights reserved.
//

#import "CTAppDelegate.h"
#import "CTSplitViewController.h"
#import "DetailsViewController.h"

@implementation CTAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    CTSplitViewController *splitViewController = [[CTSplitViewController alloc] init];
    splitViewController = [[CTSplitViewController alloc] init];
    
    DetailsViewController *m = [[DetailsViewController alloc] init];
    m.view.backgroundColor = [UIColor clearColor];
    
    DetailsViewController *d = [[DetailsViewController alloc] init];
    d.view.backgroundColor = [UIColor lightGrayColor];
    
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:d];
    
    splitViewController.viewControllers = [NSArray arrayWithObjects:m, n, nil];
    
    self.window.rootViewController = splitViewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
