//
//  QWOptions.h
//  Chess Revolt
//
//  Created by Seth Vernon on 2/3/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Options.h"
#import "QWViewController.h"

//enum GameMode {
//    GAME_MODE_COMPUTER_BLACK,   //// not sure what to do with this sav 2.3.14
//    GAME_MODE_COMPUTER_WHITE,
//    GAME_MODE_ANALYSE,
//    GAME_MODE_TWO_PLAYER
//};
//
//enum GameLevel {
//    LEVEL_GAME_IN_2,
//    LEVEL_GAME_IN_2_PLUS_1,
//    LEVEL_GAME_IN_5,
//    LEVEL_GAME_IN_5_PLUS_2,
//    LEVEL_GAME_IN_15,
//    LEVEL_GAME_IN_15_PLUS_5,
//    LEVEL_GAME_IN_30,
//    LEVEL_GAME_IN_30_PLUS_5,
//    LEVEL_1S_PER_MOVE,
//    LEVEL_2S_PER_MOVE,
//    LEVEL_5S_PER_MOVE,
//    LEVEL_10S_PER_MOVE,
//    LEVEL_30S_PER_MOVE
//};


@interface QWOptions : NSObject {
    UIColor *darkSquareColor, *lightSquareColor, *highlightColor;
    UIImage *darkSquareImage, *lightSquareImage;
    NSString *colorScheme;
    NSString *playStyle;
    NSString *bookVariety;
    BOOL bookVarietyWasChanged;
    NSString *pieceSet;
    BOOL moveSound;
    BOOL figurineNotation;
    BOOL showAnalysis;
    BOOL showBookMoves;
    BOOL showLegalMoves;
    BOOL permanentBrain;
    
    GameMode gameMode;
    BOOL gameModeWasChanged;
    GameLevel gameLevel;
    BOOL gameLevelWasChanged;
    
    BOOL playStyleWasChanged;
    BOOL strengthWasChanged;
    
    NSString *saveGameFile;
    
    NSString *fullUserName;
    NSString *emailAddress;
    
    BOOL displayMoveGestureStepForwardHint;
    BOOL displayMoveGestureTakebackHint;
    
    NSString *serverName;
    int serverPort;
    
    int strength;
}

@property (nonatomic, readwrite) UIColor *darkSquareColor;    //// sav 2.3.14  was getting readwrite property error...
@property (nonatomic, readwrite) UIColor *lightSquareColor;
@property (nonatomic, readonly) UIColor *highlightColor;
@property (nonatomic, readonly) UIImage *darkSquareImage;
@property (nonatomic, readonly) UIImage *lightSquareImage;
@property (nonatomic, strong) NSString *colorScheme;
@property (nonatomic, strong) NSString *playStyle;
@property (nonatomic, strong) NSString *bookVariety;
@property (nonatomic, readonly) BOOL bookVarietyWasChanged;
@property (nonatomic, strong) NSString *pieceSet;
@property (nonatomic, readwrite) BOOL moveSound;
@property (nonatomic, readwrite) BOOL figurineNotation;
@property (nonatomic, readwrite) BOOL showAnalysis;
@property (nonatomic, readwrite) BOOL showBookMoves;
@property (nonatomic, readwrite) BOOL showLegalMoves;
@property (nonatomic, readwrite) BOOL permanentBrain;
@property (nonatomic) GameMode gameMode;
@property (nonatomic) GameLevel gameLevel;
@property (nonatomic, readonly) BOOL gameModeWasChanged;
@property (nonatomic, readonly) BOOL gameLevelWasChanged;
@property (nonatomic, readonly) BOOL playStyleWasChanged;
@property (nonatomic, strong) NSString *saveGameFile;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *fullUserName;
@property (nonatomic, readonly) BOOL displayMoveGestureStepForwardHint;
@property (nonatomic, readonly) BOOL displayMoveGestureTakebackHint;
@property (nonatomic) int strength;
@property (nonatomic, readonly) BOOL strengthWasChanged;
@property (nonatomic, strong) NSString *serverName;
@property (nonatomic) int serverPort;

+ (QWOptions *)sharedOptions;

- (void)updateColors;
- (BOOL)isFixedTimeLevel;
- (int)baseTime;
- (int)timeIncrement;







@end
