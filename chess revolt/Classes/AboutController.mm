/*
  Stockfish, a chess program for the Apple iPhone.
  Copyright (C) 2004-2010 Tord Romstad, Marco Costalba, Joona Kiiski.

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "AboutController.h"
#import "PGN.h"
#import "BoardViewController.h"
#import "Options.h"



@implementation AboutController


- (id)initWithBoardViewController:(BoardViewController *)bvc {
    if (self = [super initWithStyle: UITableViewStylePlain]) {
        [self setTitle: @"War Of Queens tm"];
        boardViewController = bvc;
    }
    return self;
    
}

- (void)loadView {
    [super loadView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self navigationItem] setRightBarButtonItem:
         [[UIBarButtonItem alloc]
          initWithTitle: @"Done"
          style: UIBarButtonItemStylePlain
          target: boardViewController
          action: @selector(levelsMenuDonePressed)]];
        
        [[self navigationItem] setTitle:@"War Of Queens tm"];
        
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [[self navigationItem] setTitle:@"War Of Queens tm"];
        }
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //3;
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    
    switch(section) {
            
        case 0: // Game mode
            return 2;
        case 1: // Level
            return 13;
        case 2: // Strength
            return 1;
        default:
            assert(NO);
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    UITableViewCell *cell =
    [[self tableView] dequeueReusableCellWithIdentifier: @"any-cell"];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithFrame: CGRectZero
                                      reuseIdentifier: @"any-cell"];
    if (section == 0) {
        [cell setAccessoryType:
         (([[Options sharedOptions] gameMode] == (GameMode)row)?
          UITableViewCellAccessoryCheckmark :
          UITableViewCellAccessoryNone)];
        if (row == 0)
            [[cell textLabel] setText: @"Computer plays black"];
        else if (row == 1)
            [[cell textLabel] setText: @"Computer plays white"];
        
        
        //      else if (row == 2)
        //         [[cell textLabel] setText: @"Analyse mode"];
        //      else if (row == 3)
        //         [[cell textLabel] setText: @"Two player"];
    }
    else if (section == 1) {
        [cell setAccessoryType:
         (([[Options sharedOptions] gameLevel] == (GameLevel)row)?
          UITableViewCellAccessoryCheckmark :
          UITableViewCellAccessoryNone)];
        if (row == 0)
            [[cell textLabel] setText: @"Game in 2"];
        else if (row == 1)
            [[cell textLabel] setText: @"Game in 2+1"];
        else if (row == 2)
            [[cell textLabel] setText: @"Game in 5"];
        else if (row == 3)
            [[cell textLabel] setText: @"Game in 5+2"];
        else if (row == 4)
            [[cell textLabel] setText: @"Game in 15"];
        else if (row == 5)
            [[cell textLabel] setText: @"Game in 15+5"];
        else if (row == 6)
            [[cell textLabel] setText: @"Game in 30"];
        else if (row == 7)
            [[cell textLabel] setText: @"Game in 30+5"];
        else if (row == 8)
            [[cell textLabel] setText: @"1 second/move"];
        else if (row == 9)
            [[cell textLabel] setText: @"2 seconds/move"];
        else if (row == 10)
            [[cell textLabel] setText: @"5 seconds/move"];
        else if (row == 11)
            [[cell textLabel] setText: @"10 seconds/move"];
        else if (row == 12)
            [[cell textLabel] setText: @"30 seconds/move"];
    }
    /*
     else if (section == 2) {
     [[cell textLabel] setText: @"Elo: 2400"];
     }
     */
    return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)newIndexPath {
    int row = [newIndexPath row];
    int section = [newIndexPath section];
    
    [self performSelector:@selector(deselect:) withObject: tableView
               afterDelay: 0.1f];
    if (section == 0) { // Game mode
        GameMode newGameMode = (GameMode)row;
        GameMode oldGameMode = [[Options sharedOptions] gameMode];
        
        if (newGameMode != oldGameMode) {
            [[Options sharedOptions] setGameMode: newGameMode];
            [boardViewController gameModeWasChanged];
            [[tableView cellForRowAtIndexPath:
              [NSIndexPath indexPathForRow:(NSUInteger)oldGameMode
                                 inSection: 0]]
             setAccessoryType: UITableViewCellAccessoryNone];
            [[tableView cellForRowAtIndexPath: newIndexPath]
             setAccessoryType: UITableViewCellAccessoryCheckmark];
            
            //          if (row == 1){
            //              GameMode foo = [[Options sharedOptions] gameMode];
            //          }
        }
    }
    else if (section == 1) { // Level
        GameLevel newGameLevel = (GameLevel)row;
        GameLevel oldGameLevel = [[Options sharedOptions] gameLevel];
        
        if (newGameLevel != oldGameLevel) {
            [[Options sharedOptions] setGameLevel: newGameLevel];
            [boardViewController levelWasChanged];
            [[tableView cellForRowAtIndexPath:
              [NSIndexPath indexPathForRow:(NSUInteger)oldGameLevel
                                 inSection: 1]]
             setAccessoryType: UITableViewCellAccessoryNone];
            [[tableView cellForRowAtIndexPath: newIndexPath]
             setAccessoryType: UITableViewCellAccessoryCheckmark];
        }
    }
}


- (void)deselect:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath: [tableView indexPathForSelectedRow]
                             animated: YES];
}


//#if defined(SANDBOX)
//   NSString *path = [[NSBundle mainBundle] pathForResource: @"about"
//                                                    ofType: @"html"];
//#else
//   NSString *path = [[NSBundle mainBundle] pathForResource: @"about-abaia"
//                                                    ofType: @"html"];
//#endif
//   NSURL *url = [[NSURL alloc] initFileURLWithPath: path];
//   NSURLRequest *req = [NSURLRequest requestWithURL: url];
//   UIWebView *webView =
//      [[UIWebView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
//   [webView setScalesPageToFit: YES];
//   [webView loadRequest: req];
//   [self setView: webView];
//    webView = nil; /// Arc fix Seth 1/2/2014
//   url = nil; /// Arc fix Seth 1/2/2014
//}
//
//
//- (void)didReceiveMemoryWarning {
//   [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
//   // Release anything that's not essential, such as cached data
//}
//
//
//- (void)dealloc {
////   [super dealloc]; /// Arc fix Seth 1/2/2014
//}


@end
