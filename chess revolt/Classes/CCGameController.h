//
//  CCGameController.h
//  Chess Revolt
//
//  Created by Seth Vernon on 1/17/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

//#import "GameController.h" /// trying to replace this /// Seth 1.24.14
#import "CCGame.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

//#import "BoardView.h"
#import "CCView.h"
#import "Game.h"
#import "Options.h"


@class EngineController;
@class LastMoveView;
@class MoveListView;
@class PieceImageView;
@class RemoteEngineController;


@interface CCGameController : UIViewController <UIActionSheetDelegate>


@property (nonatomic, strong) LastMoveView *lastMoveView;
@property (nonatomic) BOOL isPondering;
@property (nonatomic) BOOL engineIsPlaying;
@property (nonatomic) Move ponderMove;

@property (nonatomic) SystemSoundID *clickSound;
@property (nonatomic, strong)NSTimer *timer;


@property (nonatomic) Square pendingFrom;
@property (nonatomic) Square pendingTo;

@property (nonatomic, strong) EngineController *engineController;
@property (nonatomic, strong) RemoteEngineController *remoteEngineController;
@property (nonatomic, strong) CCView *boardView;

@property (nonatomic, readonly) UILabel *whiteClockView;
@property (nonatomic, readonly) UILabel *blackClockView;
@property (nonatomic, readonly) UILabel *searchStatsView;
@property (nonatomic, readonly) UILabel *analysisView;
@property (nonatomic, readonly) UILabel *bookMovesView;

@property (nonatomic, strong) MoveListView *moveListView;
@property (nonatomic, strong) NSMutableArray *pieceViews;
@property (nonatomic, strong) NSMutableArray *pieceImages;  /// removed [16] from this
           ////     changed to NSMutableArray  it might need to be fixed ////


@property (nonatomic, readonly) Game *game;
@property (nonatomic) GameMode gameMode;
@property (nonatomic, readonly) BOOL rotated;
@property (nonatomic) GameLevel gameLevel;



//// designated Initializer /////                old init
//- (id)initWithBoardView:(BoardView *)bv
//           moveListView:(MoveListView *)mlv
//           analysisView:(UILabel *)av
//          bookMovesView:(UILabel *)bmv
//         whiteClockView:(UILabel *)wcv
//         blackClockView:(UILabel *)bcv
//        searchStatsView:(UILabel *)ssv;

- (instancetype)init;    /// new init


- (void)startEngine;
- (void)startNewGame;
- (void)updateMoveList;
- (BOOL)moveIsPending;

- (void)loadPieceImages;
- (Piece)pieceOn:(Square)sq;
- (BOOL)pieceCanMoveFrom:(Square)sq;
- (int)pieceCanMoveFrom:(Square)fSq to:(Square)tSq;

- (int)destinationSquaresFrom:(Square)sq saveInArray:(Square *)sqs;
- (void)doMoveFrom:(Square)fSq to:(Square)tSq promotion:(PieceType)prom;
- (void)animateMoveFrom:(Square)fSq to:(Square)tSq;
- (void)removePieceOn:(Square)sq;

- (void)putPiece:(Piece)p on:(Square)sq;
- (void)animateMove:(Move)m;
- (void)takeBackMove;
- (void)replayMove;
- (void)takeBackAllMoves;
- (void)replayAllMoves;
- (void)showPiecesAnimate:(BOOL)animate;
- (PieceImageView *)pieceImageViewForSquare:(Square)sq;
- (void)rotateBoard;
- (void)rotateBoard:(BOOL)rotate;
- (void)showHint;
- (NSString *)emailPgnString;
- (void)playClickSound;
- (void)displayPV:(NSString *)pv;
- (void)displaySearchStats:(NSString *)searchStats;
- (void)setGameLevel:(GameLevel)newGameLevel;
- (void)setGameMode:(GameMode)newGameMode;
- (void)doEngineMove:(Move)m;
- (void)engineGo;
- (void)engineGoPonder:(Move)pMove;
- (void)engineMadeMove:(NSArray *)array;
- (BOOL)usersTurnToMove;
- (BOOL)computersTurnToMove;
- (void)engineMoveNow;
- (void)gameEndTest;


- (void)pieceSetChanged:(NSNotification *)aNotification;
- (void)gameFromPGNString:(NSString *)pgnString;
- (void)gameFromFEN:(NSString *)fen;
- (void)showBookMoves;
- (void)changePlayStyle;
- (void)startThinking;
- (BOOL)engineIsThinking;
- (void)piecesSetUserInteractionEnabled:(BOOL)enable;
- (void)connectToServer;
- (void)disconnectFromServer;
- (BOOL)isConnectedToServer;
- (void)redrawPieces;

@end
