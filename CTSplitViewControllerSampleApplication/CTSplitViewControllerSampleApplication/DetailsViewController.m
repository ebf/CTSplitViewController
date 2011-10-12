//
//  DetailsViewController.m
//  CTSplitViewControllerSampleApplication
//
//  Created by Oliver Letterer on 11.10.11.
//  Copyright 2011 Home. All rights reserved.
//

#import "DetailsViewController.h"
#import "CTSplitViewController.h"

@implementation DetailsViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    cell.textLabel.text = indexPath.description;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    if (indexPath.section == 0) {
        [self.CTSplitViewController setMasterViewControllerHidden:!self.CTSplitViewController.isMasterViewControllerHidden animated:YES];
    } else {
        CGFloat masterWidth = self.CTSplitViewController.masterViewControllerWidth;
        
        if (masterWidth == 200.0f) {
            masterWidth = 300.0f;
        } else {
            masterWidth = 200.0f;
        }
        
        [self.CTSplitViewController setMasterViewControllerWidth:masterWidth animated:YES];
    }
}

@end
