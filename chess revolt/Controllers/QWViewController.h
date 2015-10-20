//
//  QWViewController.h
//  Chess Revolt
//
//  Created by Seth Vernon on 2/3/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameController.h"
#import "BoardView.h"
#import "Game.h"
#import "Options.h"
//#import "QWOptions.h"  /// sav  2.3.14
#import "BoardViewController.h"
#import "ContentView.h"
#import "MoveListView.h"

@interface QWViewController : UIViewController <UIActionSheetDelegate> 

@property (nonatomic, strong)BoardView *boardView;
//@property (nonatomic, strong)QWBoardView *qwBoardView; /// sav 2.3.14
@property (nonatomic, strong)GameController *gameController; // sav 2.20.14
@property (nonatomic, strong)Game *qwGame;   /// sav 2.20.14 piece positions
@property (nonatomic, strong)PieceImageView *piv;
@property (nonatomic, strong)BoardViewController *boardViewController;
@property (nonatomic, strong)ContentView *contentView;
@property (nonatomic, strong)MoveListView *moveListView;
@property (nonatomic, strong)UILabel *analysisView;
@property (nonatomic, strong)UILabel *bookMovesView;
//@property (nonatomic, strong)UILabel *whiteClockView; 
//@property (nonatomic, strong)UILabel *blackClockView;
@property (nonatomic, strong)UILabel *searchStatsView;

- (void)backgroundInit:(id)anObject;
- (void)backgroundInitFinished:(id)anObject;
- (void)updateUI;

- (void)showOptionsMenu;
- (void)optionsMenuPressed;
//- (id)initWithBoardView:(BoardView *)bv
//           moveListView:(MoveListView *)mlv
//           analysisView:(UILabel *)av
//          bookMovesView:(UILabel *)bmv
//         whiteClockView:(UILabel *)wcv
//         blackClockView:(UILabel *)bcv
//        searchStatsView:(UILabel *)ssv;

@end
