//
//  CTSplitViewController.m
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CTSplitViewController.h"
#import "CTSplitViewControllerMasterView.h"

static inline CTSplitViewControllerVisibleMasterViewOrientation CTSplitViewControllerVisibleMasterViewOrientationFromUIInterfaceOrientation(UIInterfaceOrientation interfaceOrientation)
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
            return CTSplitViewControllerVisibleMasterViewOrientationPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return CTSplitViewControllerVisibleMasterViewOrientationPortraitUpsideDown;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return CTSplitViewControllerVisibleMasterViewOrientationLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            return CTSplitViewControllerVisibleMasterViewOrientationLandscapeRight;
            break;
        default:
            break;
    }
    
    return CTSplitViewControllerVisibleMasterViewOrientationUnkown;
}





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

@property (nonatomic, readonly) CGRect visibleMasterFrame;
@property (nonatomic, readonly) CGRect visibleMasterDetailsFrame;
@property (nonatomic, readonly) CGRect hiddenMasterDetailsFrame;
@property (nonatomic, readonly) CGRect hiddenMasterFrame;

- (void)_loadDetailsView;
- (void)_unloadDetailsView;

- (void)_hideMasterViewControllerAnimated:(BOOL)animated;
- (void)_showMasterViewControllerAnimated:(BOOL)animated;

- (void)_rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer;
- (void)_leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer;
- (void)_tapGestureRecognized:(UITapGestureRecognizer *)recognizer;

- (void)_morphMasterViewInAnimated:(BOOL)animated;
- (void)_morphMasterViewOutAnimated:(BOOL)animated;

- (BOOL)_isMasterViewControllerVisibleInInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)_barButtonItemClicked:(UIBarButtonItem *)sender;
- (void)_masterViewWillDisappearAndCreateBarButtonItem;
- (void)_masterViewWillAppearAndInvalidateBarButtonItem;

@end





@implementation CTSplitViewController
@synthesize delegate=_delegate, viewControllers=_viewControllers, leftSwipeGestureRecognizer=_leftSwipeGestureRecognizer, rightSwipeGestureRecognizer=_rightSwipeGestureRecognizer, tapGestureRecognizer=_tapGestureRecognizer, supportedMasterViewOrientations=_supportedMasterViewOrientations;

#pragma mark - setters and getters

- (CGRect)hiddenMasterFrame
{
    return CGRectMake(-self.masterViewControllerWidth, 0.0f, self.masterViewControllerWidth, CGRectGetHeight(self.view.bounds));
}

- (CGRect)visibleMasterDetailsFrame
{
    return CGRectMake(self.masterViewControllerWidth + 1.0f, 0.0f, CGRectGetWidth(self.view.bounds) - self.masterViewControllerWidth - 1.0f, CGRectGetHeight(self.view.bounds));
}

- (CGRect)hiddenMasterDetailsFrame
{
    return self.view.bounds;
}

- (CGRect)visibleMasterFrame
{
    return CGRectMake(0.0f, 0.0f, self.masterViewControllerWidth, CGRectGetHeight(self.view.bounds));
}

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
        
        if (self.isViewLoaded && self.isMasterViewVisible) {
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
        } else if ([self _isMasterViewControllerVisibleInInterfaceOrientation:self.interfaceOrientation]) {
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
        _supportedMasterViewOrientations = CTSplitViewControllerVisibleMasterViewOrientationLandscapeLeft | CTSplitViewControllerVisibleMasterViewOrientationLandscapeRight;
    }
    return self;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if (!self.isMasterViewVisible && self.isMasterViewLoaded) {
        [self _unloadMasterView];
    }
}

#pragma mark - View lifecycle

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor blackColor];
    
    // first load _detailsView because its always visible
    [self.detailsViewController viewWillAppear:NO];
    [self _loadDetailsView];
    [self.view addSubview:_detailsView];
    [self.detailsViewController viewDidAppear:NO];
    
    if ([self _isMasterViewControllerVisibleInInterfaceOrientation:self.interfaceOrientation]) {
        // load master view if allowed
        [self _loadMasterView];
        [self.view addSubview:_masterView];
    } else {
        // not allowed to load master view, update details view frame
        _detailsView.frame = self.view.bounds;
    }
    
    _rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_rightSwipeGestureRecognized:)];
    _rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    _rightSwipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_rightSwipeGestureRecognizer];
    
    _leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_leftSwipeGestureRecognized:)];
    _leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    _leftSwipeGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_leftSwipeGestureRecognizer];
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapGestureRecognized:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    _tapGestureRecognizer.numberOfTouchesRequired = 1;
    _tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![self _isMasterViewControllerVisibleInInterfaceOrientation:self.interfaceOrientation]) {
        [self _masterViewWillDisappearAndCreateBarButtonItem];
    }
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    
    _masterView = nil;
    _detailsView = nil;
    _rightSwipeGestureRecognizer = nil;
    _leftSwipeGestureRecognizer = nil;
    _tapGestureRecognizer = nil;
}

#pragma mark - rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return  [self.masterViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation] && 
            [self.detailsViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    _detailsView.userInteractionEnabled = YES;
    
    // called after rotation, we also need to layout our master and details view here, because this may be called after loadView
    if ([self _isMasterViewControllerVisibleInInterfaceOrientation:self.interfaceOrientation]) {
        // master view is visible
        if (!self.isMasterViewLoaded) {
            // but master view is not loaded
            [self _loadMasterView];
            [self.view addSubview:_masterView];
        }
        
        _masterView.state = CTSplitViewControllerMasterViewStateVisible;
        _masterView.frame = self.visibleMasterFrame;
        _detailsView.frame = self.visibleMasterDetailsFrame;
    } else {
        [self _unloadMasterView];
        _detailsView.frame = self.hiddenMasterDetailsFrame;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if ([self _isMasterViewControllerVisibleInInterfaceOrientation:toInterfaceOrientation]) {
        // master view will be visible
        if (!self.isMasterViewLoaded) {
            [self _loadMasterView];
            [self.view insertSubview:_masterView belowSubview:_detailsView];
        }
        
        _masterView.frame = self.visibleMasterFrame;
        _detailsView.frame = self.visibleMasterDetailsFrame;
    } else {
        // master view will not be visible
        _masterView.frame = self.hiddenMasterFrame;
        _detailsView.frame = self.hiddenMasterDetailsFrame;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    BOOL animated = duration > 0.0;
    
    if ([self _isMasterViewControllerVisibleInInterfaceOrientation:toInterfaceOrientation] && !self.isMasterViewVisible) {
        [self.masterViewController viewWillAppear:animated];
        
        double delayInSeconds = duration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.masterViewController viewDidAppear:animated];
        });
    } else if (![self _isMasterViewControllerVisibleInInterfaceOrientation:toInterfaceOrientation] && self.isMasterViewVisible) {
        [self.masterViewController viewWillDisappear:animated];
        
        double delayInSeconds = duration;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.masterViewController viewDidDisappear:animated];
        });
    }
    
    if (![self _isMasterViewControllerVisibleInInterfaceOrientation:toInterfaceOrientation]) {
        [self _masterViewWillDisappearAndCreateBarButtonItem];
    } else if ([self _isMasterViewControllerVisibleInInterfaceOrientation:toInterfaceOrientation]) {
        [self _masterViewWillAppearAndInvalidateBarButtonItem];
    }
}

#pragma mark - UIContainerViewControllerCallbacks

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _tapGestureRecognizer) {
        return _masterView.state == CTSplitViewControllerMasterViewStateMorphedIn;
    } else if (gestureRecognizer == _leftSwipeGestureRecognizer) {
        return _masterView.state == CTSplitViewControllerMasterViewStateMorphedIn;
    } else if (gestureRecognizer == _rightSwipeGestureRecognizer) {
        return ![self _isMasterViewControllerVisibleInInterfaceOrientation:self.interfaceOrientation] && _masterView.state != CTSplitViewControllerMasterViewStateMorphedIn;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _tapGestureRecognizer) {
        UIView *recognizerView = gestureRecognizer.view;
        
        CGPoint locationInMasterView = [recognizerView convertPoint:[touch locationInView:recognizerView] toView:_masterView];
        CGRect masterViewFrame = _masterView.frame;
        
        return !CGRectContainsPoint(masterViewFrame, locationInMasterView);
    }
    
    return YES;
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
    
    if (self.isViewLoaded) {
        [self.masterViewController viewWillAppear:NO];
        [self.detailsViewController viewWillAppear:NO];
        
        [self _reloadView];
        
        [self.masterViewController viewDidAppear:NO];
        [self.detailsViewController viewDidAppear:NO];
    }
    
    [self.masterViewController didMoveToParentViewController:self];
    [self.detailsViewController didMoveToParentViewController:self];
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

- (void)_hideMasterViewControllerAnimated:(BOOL)animated
{
    if (!self.isMasterViewVisible) {
        return;
    }
    
    void(^animationBlock)(void) = ^(void) {
        _masterView.frame = self.hiddenMasterFrame;
        _detailsView.frame = self.hiddenMasterDetailsFrame;
    };
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self.masterViewController viewDidDisappear:animated];
        [self _unloadMasterView];
    };
    
    
    [self _masterViewWillDisappearAndCreateBarButtonItem];
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
    if (!self.isMasterViewLoaded) {
        [self _loadMasterView];
        
        _masterView.frame = self.hiddenMasterFrame;
        [self.view addSubview:_masterView];
    }
    
    void(^animationBlock)(void) = ^(void) {
        _masterView.frame = self.visibleMasterFrame;
        _detailsView.frame = self.visibleMasterDetailsFrame;
    };
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self.masterViewController viewDidAppear:animated];
        
        _detailsView.userInteractionEnabled = YES;
        _masterView.state = CTSplitViewControllerMasterViewStateVisible;
    };
    
    
    [self _masterViewWillAppearAndInvalidateBarButtonItem];
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
    _masterView = [[CTSplitViewControllerMasterView alloc] initWithFrame:self.visibleMasterFrame];
    _masterView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _masterView.state = CTSplitViewControllerMasterViewStateVisible;
    
    UIView *view = self.masterViewController.view;
    [_masterView insertSubview:view atIndex:0];
    view.frame = _masterView.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    view.layer.cornerRadius = 3.0f;
    view.layer.masksToBounds = YES;
}

- (void)_unloadMasterView
{
    [_masterView removeFromSuperview];
    _masterView = nil;
}

- (void)_loadDetailsView
{
    _detailsView = [[UIView alloc] initWithFrame:self.visibleMasterDetailsFrame];
    _detailsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [_detailsView insertSubview:self.detailsViewController.view atIndex:0];
    self.detailsViewController.view.frame = _detailsView.bounds;
    self.detailsViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:_detailsView.bounds];
    cornerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    cornerImageView.image = [[UIImage imageNamed:@"CTSplitViewCornerImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f)];
    [_detailsView addSubview:cornerImageView];
}

- (void)_unloadDetailsView
{
    [_detailsView removeFromSuperview];
    _detailsView = nil;
}

- (void)_rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized && ![self _isMasterViewControllerVisibleInInterfaceOrientation:self.interfaceOrientation]) {
        [self _morphMasterViewInAnimated:YES];
    }
}

- (void)_leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized && ![self _isMasterViewControllerVisibleInInterfaceOrientation:self.interfaceOrientation] && self.isMasterViewVisible) {
        [self _morphMasterViewOutAnimated:YES];
    }
}

- (void)_tapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    UIView *recognizerView = recognizer.view;
    
    CGPoint locationInDetailsView = [recognizerView convertPoint:[recognizer locationInView:recognizerView] toView:_detailsView];
    CGRect detailsViewFrame = _detailsView.frame;
    
    if (CGRectContainsPoint(detailsViewFrame, locationInDetailsView)) {
        [self _morphMasterViewOutAnimated:YES];
    }
}

- (void)_morphMasterViewInAnimated:(BOOL)animated
{
    if (!self.isMasterViewLoaded) {
        [self _loadMasterView];
        
        _masterView.frame = self.hiddenMasterFrame;
        [self.view addSubview:_masterView];
    }
    
    [self.masterViewController viewWillAppear:animated];
    
    _masterView.state = CTSplitViewControllerMasterViewStateMorphedIn;
    [self.view bringSubviewToFront:_masterView];
    
    void(^animationBlock)(void) = ^(void) {
        _masterView.frame = self.visibleMasterFrame;
    };
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        _detailsView.userInteractionEnabled = NO;
        [self.masterViewController viewDidAppear:animated];
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
    
    [UIView animateWithDuration:0.25f 
                     animations:^{
                         
                     } completion:nil];
}

- (void)_morphMasterViewOutAnimated:(BOOL)animated
{
    void(^animationBlock)(void) = ^(void) {
        _masterView.frame = self.hiddenMasterFrame;
    };
    
    void(^completionBlock)(BOOL finished) = ^(BOOL finished) {
        [self _unloadMasterView];
        _detailsView.userInteractionEnabled = YES;
        [self.masterViewController viewDidDisappear:animated];
    };
    
    [self.masterViewController viewWillDisappear:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:animationBlock completion:completionBlock];
    } else {
        animationBlock();
        completionBlock(YES);
    }
}

- (BOOL)_isMasterViewControllerVisibleInInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CTSplitViewControllerVisibleMasterViewOrientation orientation = CTSplitViewControllerVisibleMasterViewOrientationFromUIInterfaceOrientation(interfaceOrientation);
    
    return orientation & _supportedMasterViewOrientations && !self.isMasterViewControllerHidden;
}

- (void)_barButtonItemClicked:(UIBarButtonItem *)sender
{
    if (sender == _barButtonItem) {
        [self _morphMasterViewInAnimated:YES];
    }
}

- (void)_masterViewWillDisappearAndCreateBarButtonItem
{
    NSString *title = self.masterViewController.title;
    if (!title) {
        title = NSLocalizedString(@"Master", @"");
    }
    
    _barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title
                                                      style:UIBarButtonItemStyleBordered 
                                                     target:self action:@selector(_barButtonItemClicked:)];
    
    if ([_delegate respondsToSelector:@selector(CTSplitViewController:willHideViewController:withBarButtonItem:)]) {
        [_delegate CTSplitViewController:self willHideViewController:self.masterViewController withBarButtonItem:_barButtonItem];
    }
}

- (void)_masterViewWillAppearAndInvalidateBarButtonItem
{
    if (_barButtonItem) {
        if ([_delegate respondsToSelector:@selector(CTSplitViewController:willShowViewController:invalidatingBarButtonItem:)]) {
            [_delegate CTSplitViewController:self willShowViewController:self.masterViewController invalidatingBarButtonItem:_barButtonItem];
        }
        
        _barButtonItem = nil;
    }
}

@end





@implementation UIViewController (CTSplitViewController)

- (CTSplitViewController *)CTSplitViewController
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 5.0f) {
        return nil;
    }
    
    UIViewController *parentViewController = self.parentViewController;
    
    while (parentViewController && ![parentViewController isKindOfClass:[CTSplitViewController class]]) {
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
