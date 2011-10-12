//
//  CTSplitViewControllerMasterView.h
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 12.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CTSplitViewControllerMasterViewStateVisible = 0,
    CTSplitViewControllerMasterViewStateHidden,
    CTSplitViewControllerMasterViewStateMorphedIn
} CTSplitViewControllerMasterViewState;

@interface CTSplitViewControllerMasterView : UIView {
@private
    CTSplitViewControllerMasterViewState _state;
}

@property (nonatomic, assign) CTSplitViewControllerMasterViewState state;

@end
