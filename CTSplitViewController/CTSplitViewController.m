//
//  CTSplitViewController.m
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CTSplitViewController.h"

@interface CTSplitViewController () {
    UIView *_masterView;
    UIView *_detailsView;
}

- (void)_reloadView;
- (void)_removeViewControllers;
- (void)_addViewControllers;

@end



@implementation CTSplitViewController
@synthesize delegate=_delegate, viewControllers=_viewControllers;

#pragma mark - setters and getters

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (viewControllers != _viewControllers) {
        NSAssert(viewControllers.count == 2, @"%@ can only accept exactly 2 viewControllers", self);
        [self _removeViewControllers];
        _viewControllers = viewControllers;
        [self _addViewControllers];
    }
}

- (UIViewController *)masterViewController
{
    return [_viewControllers objectAtIndex:0];
}

- (UIViewController *)detailsViewController
{
    return [_viewControllers objectAtIndex:1];
}

#pragma mark - Initialization

- (id)init 
{
    if ((self = [super init])) {
        
    }
    return self;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
    CGFloat masterWidth = 200.0f;
    
    _masterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, masterWidth, CGRectGetHeight(self.view.bounds))];
    _masterView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_masterView];
    
    _detailsView = [[UIView alloc] initWithFrame:CGRectMake(masterWidth, 0.0f, CGRectGetWidth(self.view.bounds) - masterWidth, CGRectGetHeight(self.view.bounds))];
    _detailsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_detailsView];
    
    [self _reloadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    _masterView = nil;
    _detailsView = nil;
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UIContainerViewControllerCallbacks

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

#pragma mark - private implementation ()

- (void)_removeViewControllers
{
    for (UIViewController *viewController in _viewControllers) {
        [viewController willMoveToParentViewController:nil];
        if (viewController.isViewLoaded) {
            [viewController viewWillDisappear:NO];
            [viewController.view removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
}

- (void)_addViewControllers
{
    [self.masterViewController willMoveToParentViewController:self];
    [self.detailsViewController willMoveToParentViewController:self];
    
    [self addChildViewController:self.masterViewController];
    [self addChildViewController:self.detailsViewController];
    
    if (self.isViewLoaded) {
        [self _reloadView];
    }
}

- (void)_reloadView
{
    [_masterView insertSubview:self.masterViewController.view atIndex:0];
    self.masterViewController.view.frame = _masterView.bounds;
    self.masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [_detailsView insertSubview:self.detailsViewController.view atIndex:0];
    self.detailsViewController.view.frame = _detailsView.bounds;
    self.detailsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

@end



@implementation UIViewController (CTSplitViewController)

- (CTSplitViewController *)CTSplitViewController
{
    UIViewController *parentViewController = self.parentViewController;
    
    while (![parentViewController isKindOfClass:[CTSplitViewController class]]) {
        parentViewController = parentViewController.parentViewController;
    }
    
    return (CTSplitViewController *)parentViewController;
}

@end
