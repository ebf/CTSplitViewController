//
//  CTSplitViewController.m
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CTSplitViewController.h"
#import <objc/runtime.h>
#import "CTSplitViewControllerMasterView.h"

@interface CTSplitViewController () {
    CTSplitViewControllerMasterView *_masterView;
    UIView *_detailsView;
    
    struct {
        BOOL masterViewControllerHidden;
        CGFloat masterViewControllerWidth;
    } _splitViewControllerFlags;
}

- (void)_reloadView;
- (void)_removeViewControllers;
- (void)_addViewControllers;

- (void)_loadMasterView;
- (void)_unloadMasterView;
@property (nonatomic, readonly) BOOL isMasterViewLoaded;
@property (nonatomic, readonly) BOOL isMasterViewVisible;

- (void)_loadDetailsView;
- (void)_unloadDetailsView;

- (void)_hideMasterViewControllerAnimated:(BOOL)animated;
- (void)_showMasterViewControllerAnimated:(BOOL)animated;

- (void)_rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer;
- (void)_leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer;

@end



@implementation CTSplitViewController
@synthesize delegate=_delegate, viewControllers=_viewControllers, leftSwipeGestureRecognizer=_leftSwipeGestureRecognizer, rightSwipeGestureRecognizer=_rightSwipeGestureRecognizer;

#pragma mark - setters and getters

- (BOOL)isMasterViewLoaded
{
    return _masterView != nil;
}

- (BOOL)isMasterViewVisible
{
    return _masterView.superview != nil;
}

- (CGFloat)masterViewControllerWidth
{
    return _splitViewControllerFlags.masterViewControllerWidth;
}

- (void)setMasterViewControllerWidth:(CGFloat)masterViewControllerWidth
{
    [self setMasterViewControllerWidth:masterViewControllerWidth animated:NO];
}

- (void)setMasterViewControllerWidth:(CGFloat)masterViewControllerWidth animated:(BOOL)animated
{
    if (masterViewControllerWidth != _splitViewControllerFlags.masterViewControllerWidth) {
        _splitViewControllerFlags.masterViewControllerWidth = masterViewControllerWidth;
        
        if (self.isViewLoaded && !_splitViewControllerFlags.masterViewControllerHidden) {
            // adopt masterWidth
            void(^animationBlock)(void) = ^(void) {
                CGFloat masterWidth = _splitViewControllerFlags.masterViewControllerWidth;
                
                _masterView.frame = CGRectMake(0.0f, 0.0f, masterWidth, CGRectGetHeight(self.view.bounds));
                _detailsView.frame = CGRectMake(masterWidth, 0.0f, CGRectGetWidth(self.view.bounds) - masterWidth, CGRectGetHeight(self.view.bounds));
            };
            
            if (animated) {
                [UIView animateWithDuration:0.25f animations:animationBlock completion:nil];
            } else {
                animationBlock();
            }
        }
    }
}

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

- (BOOL)isMasterViewControllerHidden
{
    return _splitViewControllerFlags.masterViewControllerHidden;
}

- (void)setMasterViewControllerHidden:(BOOL)masterViewControllerHidden
{
    [self setMasterViewControllerHidden:masterViewControllerHidden animated:NO];
}

- (void)setMasterViewControllerHidden:(BOOL)masterViewControllerHidden animated:(BOOL)animated
{
    if (masterViewControllerHidden != _splitViewControllerFlags.masterViewControllerHidden) {
        _splitViewControllerFlags.masterViewControllerHidden = masterViewControllerHidden;
        
        if (_splitViewControllerFlags.masterViewControllerHidden) {
            [self _hideMasterViewControllerAnimated:animated];
        } else {
            [self _showMasterViewControllerAnimated:animated];
        }
    }
}

#pragma mark - Initialization

- (id)init 
{
    if ((self = [super init])) {
        NSAssert(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad, @"CTSplitViewController can only be used on an iPad");
        _splitViewControllerFlags.masterViewControllerWidth = 300.0f;
    }
    return self;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (!self.isMasterViewVisible) {
        [self _unloadMasterView];
    }
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    
#warning only load master view if not hidden
    [self.masterViewController viewWillAppear:NO];
    [self _loadMasterView];
    [self.view addSubview:_masterView];
    [self.masterViewController viewDidAppear:NO];
    
    [self.detailsViewController viewWillAppear:NO];
    [self _loadDetailsView];
    [self.view addSubview:_detailsView];
    [self.detailsViewController viewDidAppear:NO];
    
    _rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_rightSwipeGestureRecognized:)];
    _rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    _rightSwipeGestureRecognizer.enabled = self.isMasterViewControllerHidden;
    [self.view addGestureRecognizer:_rightSwipeGestureRecognizer];
    
    _leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_leftSwipeGestureRecognized:)];
    _leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwipeGestureRecognizer.enabled = !self.isMasterViewControllerHidden;
    [self.view addGestureRecognizer:_leftSwipeGestureRecognizer];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    _masterView = nil;
    _detailsView = nil;
    _rightSwipeGestureRecognizer = nil;
    _leftSwipeGestureRecognizer = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return  [self.masterViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation] && 
            [self.detailsViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
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
    [self addChildViewController:self.masterViewController];
    [self addChildViewController:self.detailsViewController];
    
    [self.masterViewController didMoveToParentViewController:self];
    [self.detailsViewController didMoveToParentViewController:self];
    
    if (self.isViewLoaded) {
        [self _reloadView];
    }
}

- (void)_reloadView
{
#warning inform viewControllers about view changes
    [_masterView insertSubview:self.masterViewController.view atIndex:0];
    self.masterViewController.view.frame = _masterView.bounds;
    self.masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [_detailsView insertSubview:self.detailsViewController.view atIndex:0];
    self.detailsViewController.view.frame = _detailsView.bounds;
    self.detailsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_hideMasterViewControllerAnimated:(BOOL)animated
{
    void(^animationBlock)(void) = ^(void) {
        CGFloat masterWidth = self.masterViewControllerWidth;
        
        CGPoint center = _masterView.center;
        center.x -= masterWidth;
        _masterView.center = center;
        
        _detailsView.frame = self.view.bounds;
    };
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self.masterViewController viewDidDisappear:animated];
        [self _unloadMasterView];
        
        _leftSwipeGestureRecognizer.enabled = YES;
        _rightSwipeGestureRecognizer.enabled = YES;
    };
    
    
    [self.masterViewController viewWillDisappear:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

- (void)_showMasterViewControllerAnimated:(BOOL)animated
{
    CGFloat masterWidth = _splitViewControllerFlags.masterViewControllerWidth;
    
    if (!self.isMasterViewLoaded) {
        [self _loadMasterView];
        
        CGPoint center = _masterView.center;
        center.x -= masterWidth;
        _masterView.center = center;
        [self.view addSubview:_masterView];
    }
    
    void(^animationBlock)(void) = ^(void) {
        _masterView.frame = CGRectMake(0.0f, 0.0f, masterWidth, CGRectGetHeight(self.view.bounds));
        _detailsView.frame = CGRectMake(masterWidth, 0.0f, CGRectGetWidth(self.view.bounds) - masterWidth, CGRectGetHeight(self.view.bounds));
    };
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self.masterViewController viewDidAppear:animated];
        _leftSwipeGestureRecognizer.enabled = NO;
        _rightSwipeGestureRecognizer.enabled = NO;
        
        _masterView.state = CTSplitViewControllerMasterViewStateVisible;
    };
    
    
    [self.masterViewController viewWillAppear:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

- (void)_loadMasterView
{
    CGFloat masterWidth = _splitViewControllerFlags.masterViewControllerWidth;
    
    _masterView = [[CTSplitViewControllerMasterView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, masterWidth, CGRectGetHeight(self.view.bounds))];
    _masterView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _masterView.state = CTSplitViewControllerMasterViewStateVisible;
    
    [_masterView insertSubview:self.masterViewController.view atIndex:0];
    self.masterViewController.view.frame = _masterView.bounds;
    self.masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_unloadMasterView
{
    [_masterView removeFromSuperview];
    _masterView = nil;
}

- (void)_loadDetailsView
{
    CGFloat masterWidth = _splitViewControllerFlags.masterViewControllerWidth;
    
    _detailsView = [[UIView alloc] initWithFrame:CGRectMake(masterWidth, 0.0f, CGRectGetWidth(self.view.bounds) - masterWidth, CGRectGetHeight(self.view.bounds))];
    _detailsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_detailsView insertSubview:self.detailsViewController.view atIndex:0];
    self.detailsViewController.view.frame = _detailsView.bounds;
    self.detailsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)_unloadDetailsView
{
    [_detailsView removeFromSuperview];
    _detailsView = nil;
}

- (void)_rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized && !self.isMasterViewVisible) {
        CGFloat masterWidth = _splitViewControllerFlags.masterViewControllerWidth;
        
        if (!self.isMasterViewLoaded) {
            [self _loadMasterView];
            
            CGPoint center = _masterView.center;
            center.x -= masterWidth;
            _masterView.center = center;
            [self.view addSubview:_masterView];
        }
        
        _detailsView.userInteractionEnabled = NO;
        _masterView.state = CTSplitViewControllerMasterViewStateMorphedIn;
        [self.view bringSubviewToFront:_masterView];
        
        [UIView animateWithDuration:0.25f 
                         animations:^{
                             _masterView.frame = CGRectMake(0.0f, 0.0f, masterWidth, CGRectGetHeight(self.view.bounds));
                         } completion:nil];
    }
}

- (void)_leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized && self.isMasterViewVisible && _splitViewControllerFlags.masterViewControllerHidden) {
        void(^animationBlock)(void) = ^(void) {
            CGFloat masterWidth = self.masterViewControllerWidth;
            
            CGPoint center = _masterView.center;
            center.x -= masterWidth;
            _masterView.center = center;
        };
        
        void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
            [self _unloadMasterView];
            _detailsView.userInteractionEnabled = YES;
        };
        
        [UIView animateWithDuration:0.25f animations:animationBlock completion:completionBlock];

    }
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

- (BOOL)hidesSplitViewControllersMasterView
{
    for (UIViewController *viewController in self.childViewControllers) {
        if (viewController.hidesSplitViewControllersMasterView) {
            return YES;
        }
    }
    
    return NO;
}

@end
