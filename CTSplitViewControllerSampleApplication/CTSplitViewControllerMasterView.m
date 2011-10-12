//
//  CTSplitViewControllerMasterView.m
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 12.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "CTSplitViewControllerMasterView.h"
#import <QuartzCore/QuartzCore.h>


@implementation CTSplitViewControllerMasterView
@synthesize state=_state;

#pragma mark - setters and getters

- (void)setState:(CTSplitViewControllerMasterViewState)state
{
    if (state != _state) {
        _state = state;
        
        switch (_state) {
            case CTSplitViewControllerMasterViewStateHidden:
            case CTSplitViewControllerMasterViewStateVisible:
                self.layer.shadowOpacity = 0.0f;
                break;
            case CTSplitViewControllerMasterViewStateMorphedIn:
                self.layer.shadowOpacity = 1.0f;
                break;
            default:
                break;
        }
    }
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor blackColor];
        
        CALayer *layer = self.layer;
        
        layer.shadowColor = [UIColor blackColor].CGColor;
        layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        layer.shadowOpacity = 0.0f;
        layer.shadowRadius = 10.0f;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:10.0f].CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
