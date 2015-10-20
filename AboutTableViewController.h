//
//  AboutTableViewController.h
//  Chess Revolt - War of Queens
//
//  Created by Seth Vernon on 4/22/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BoardViewController;


@interface AboutTableViewController : UITableViewController

{

    BoardViewController *boardViewController;
}

- (id)initWithBoardViewController:(BoardViewController *)bvc;
//- (void)deselect:(UITableView *)tableView;


@end
