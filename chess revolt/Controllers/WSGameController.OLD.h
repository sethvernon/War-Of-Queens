//
//  WSGameController.h
//  Chess Revolt
//
//  Created by Seth Vernon on 1/27/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

//#import "GameController.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>

#import "WSView.h"
//#import "Game.h"  replacing this with WSGame
#import "WSGame.h"
#import "Options.h"

@class EngineController;
@class LastMoveView;
@class MoveListView;
@class PieceImageView;
@class RemoteEngineController;

@interface WSGameController : NSObject <UIActionSheetDelegate>

@property (nonatomic, strong)EngineController *engineController;
@property (nonatomic, strong)RemoteEngineController *remoteEngineController;
@property (nonatomic, strong)WSView *boardView;

@property (nonatomic, readonly)UILabel *analysisView;
@property (nonatomic, readonly)UILabel *bookMovesView;
@property (nonatomic, readonly)UILabel *whiteClockView;
@property (nonatomic, readonly)UILabel *blackClockView;
@property (nonatomic, readonly)UILabel *searchStatsView;

@property (nonatomic, strong)MoveListView *moveListView;

@property (nonatomic, readonly)WSGame *wsGame;
@property (nonatomic) GameMode gameMode;

@property (nonatomic, strong)NSMutableArray *pieceViews;
@property (nonatomic, strong)NSArray *pieceImages;    ///// replaced UIImage *pieceImages[16] from old code. SAV 1.27.14

@property (nonatomic)Square pendingFrom; // HACK for handling promotions.  Changed this to *pendingFrom to adhere to new objective c syntax. SAV 1.27.14
@property (nonatomic)Square pendingTo; // HACK for handling promotions.

@property (nonatomic, readonly)BOOL rotated;
@property (nonatomic, getter = clickSound)SystemSoundID clickSound; //// getting error for property for return type added getter syntax.. what better place to test this theory than with something simple as a system sound SAV 1.27.14
@property (nonatomic, strong)NSTimer *timer;

@property (nonatomic)GameLevel gameLevel; /// took out both of these
@property (nonatomic)Move ponderMove;

@property (nonatomic)BOOL engineIsPlaying; 
@property (nonatomic)BOOL isPondering;

@property (nonatomic, strong)LastMoveView *lastMoveView;

- (instancetype)initWithWSView:(WSView *)bv          /////// OLD StockFish init /////// this is what we are trying to replace               replaced with instancetypeWithWSView
           moveListView:(MoveListView *)mlv
           analysisView:(UILabel *)av
          bookMovesView:(UILabel *)bmv
         whiteClockView:(UILabel *)wcv
         blackClockView:(UILabel *)bcv
        searchStatsView:(UILabel *)ssv;

- (void)startEngine;
- (void)startNewGame;
- (void)updateMoveList;
- (BOOL)moveIsPending;

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

- (void)loadPieceImages;
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