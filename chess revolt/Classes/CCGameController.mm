//
//  CCGameController.m
//  Chess Revolt
//
//  Created by Seth Vernon on 1/17/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

#import "CCGameController.h"

#import "EngineController.h"
#import "GameController.h"
#import "LastMoveView.h"
#import "MoveListView.h"
#import "Options.h"
#import "PieceImageView.h"
#import "PGN.h"
#import "RemoteEngineController.h"

#include "mersenne.h"
#include "movepick.h"


#include "../Chess/misc.h"

using namespace Chess;


@interface CCGameController()
/@property(nonatomic, readwrite)Game *game;
@property (nonatomic, readwrite) BOOL rotated;

@end


@implementation CCGameController


//@synthesize whiteClockView, blackClockView, searchStatsView, game, rotated;



// @dynamic gameMode;

// Get's the value game (also does lazy instantiation)
- (Game *)game
{
    if (!_game)
        _game = [[Game alloc] init];
    return _game;
}


- (NSMutableArray *)pieceViews
{
    if (!_pieceViews)
        _pieceViews = [[NSMutableArray alloc] init];
    return _pieceViews;
}

- (EngineController *)engineController
{
    {
        if (! _engineController )
            _engineController = [[EngineController   alloc]init];
        return _engineController ;
    }
}


- (instancetype)init  /// the new way to init. /// Seth 1.24.14
{
    self = [super init];
    
        if (self) {
            
            /* Chess init */           ///// added chess init engine. //// seth 1.19.14
            init_mersenne();
            init_direction_table();
            init_bitboards();
            Position::init_zobrist();
            Position::init_piece_square_tables();
            MovePicker::init_phase_table();
            
            // Make random number generation less deterministic, for book moves
            int i = abs(get_system_time() % 10000);
            for (int j = 0; j < i; j++)
                genrand_int32();
            
            [self loadPieceImages];
//            [self performSelectorOnMainThread: @selector(backgroundInitFinished:)
//                                   withObject: nil
//                                waitUntilDone: NO];

            
            [self setup];
//            [self startNewGame];  // test the game....
    }
    return self;
}

- (void)setup
{
    self.pendingFrom = SQ_NONE;
    self.pendingTo = SQ_NONE;
    self.rotated = NO;
    self.gameLevel = [[Options sharedOptions] gameLevel];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(pieceSetChanged:)
     name: @"StockfishPieceSetChanged"
     object: nil];
    
    
    
    
    self.engineController = nil;
    
    
    self.isPondering = NO;

}

- (void)startEngine {
   
    [self.engineController sendCommand: @"uci"];
    [self.engineController sendCommand: @"isready"];
    [self.engineController sendCommand: @"ucinewgame"];
    [self.engineController sendCommand:
     [NSString stringWithFormat:
      @"setoption name Play Style value %@",
      [[Options sharedOptions] playStyle]]];
    if ([[Options sharedOptions] permanentBrain])
        [self.engineController sendCommand: @"setoption name Ponder value true"];
    else
        [self.engineController sendCommand: @"setoption name Ponder value false"];
    
    if ([[Options sharedOptions] strength] == 2500) // Max strength
        [self.engineController
         sendCommand: @"setoption name UCI_LimitStrength value false"];
    else
        [self.engineController
         sendCommand: @"setoption name UCI_LimitStrength value true"];
    [self.engineController sendCommand:
     [NSString stringWithFormat:
      @"setoption name UCI_Elo value %d",
      [[Options sharedOptions] strength]]];
    
    [self.engineController commitCommands];
    
    [self showBookMoves];
}

- (Square)rotateSquare:(Square)sq {
    return _rotated? Square(SQ_H8 - sq) : sq;
}

///// startNewGame starts a new game, and discards the old one.  Later, we should
///// bring up some dialog to let the user choose time controls, colors etc.
///// before starting the new game.
//
- (void)startNewGame {
    NSLog(@"startNewGame");
    [self.boardView hideLastMove];
    [self.boardView stopHighlighting];
    self.game = nil;  /// ** removed [game release] from stockfish ver /// seth 12.30.13
    
    for (PieceImageView *piv in self.pieceViews)
        [piv removeFromSuperview];
    self.pieceViews = nil; /// ** removed [pieceViews release] *** for ARC added nil. /// seth 12.30.13
    
   
    self.gameLevel = [[Options sharedOptions] gameLevel];
//    gameMode = [[Options sharedOptions] gameMode];
    if ([[Options sharedOptions] isFixedTimeLevel])
        [self.game setTimeControlWithFixedTime: [[Options sharedOptions] timeIncrement]];
    else
        [self.game setTimeControlWithTime: [[Options sharedOptions] baseTime]
                           increment: [[Options sharedOptions] timeIncrement]];
    
    [self.game setWhitePlayer:
     ((self.gameMode == GAME_MODE_COMPUTER_BLACK)?
      [[[Options sharedOptions] fullUserName] copy] : ENGINE_NAME)];
    [self.game setBlackPlayer:
     ((self.gameMode == GAME_MODE_COMPUTER_BLACK)?
    ENGINE_NAME : [[[Options sharedOptions] fullUserName] copy])];
    
    _pendingFrom = SQ_NONE;
    _pendingTo = SQ_NONE;
    
    [self.moveListView setText: @""];
    [self.analysisView setText: @""];
    [self.searchStatsView setText: @""];
    [self showPiecesAnimate: NO];
    self.engineIsPlaying = NO;
    [self.engineController abortSearch];
    [self.engineController sendCommand: @"ucinewgame"];
    [self.engineController sendCommand:
     [NSString stringWithFormat:
      @"setoption name Play Style value %@",
      [[Options sharedOptions] playStyle]]];
    
    if ([[Options sharedOptions] strength] == 2500) // Max strength
        [self.engineController
         sendCommand: @"setoption name UCI_LimitStrength value false"];
    else
        [self.engineController
         sendCommand: @"setoption name UCI_LimitStrength value true"];
    
    [self.engineController commitCommands];
    
    if ([self.remoteEngineController isConnected])
        [self.remoteEngineController sendToServer: @"n\n"];
    
    [self showBookMoves];
    
    // Rotate board if the engine plays white:
    if (!self.rotated && [self computersTurnToMove])
        [self rotateBoard];
    [self engineGo];
}
//
//
- (void)updateMoveList {
    // Scroll to the end of move list.
    float height = [self.moveListView frame].size.height;
    if ([self.game atEnd]) {
        [self.moveListView setText: [self.game moveListString]];
        if ([self.moveListView contentSize].height > height)
            [self.moveListView
             setContentOffset:
             CGPointMake(0.0f, [self.moveListView contentSize].height - (height+3))];
    }
    else {
        [self.moveListView setText: [self.game partialMoveListString]];
        if ([self.moveListView contentSize].height > height)
            [self.moveListView
             setContentOffset:
             CGPointMake(0.0f, [self.moveListView contentSize].height - (height+3))];
        [self.moveListView setText: [self.game moveListString]];
    }
}

///// UIActionSheet delegate method for handling menu button choices.

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet title] isEqualToString: @"Promote to"]) {
        // The ugly promotion menu. Promotions are handled by a truly hideous
        // hack, see a comment in the doMoveFrom:to:promotion function for an
        // explanation.
        static const PieceType prom[4] = { QUEEN, ROOK, KNIGHT, BISHOP };
        assert(buttonIndex >= 0 && buttonIndex < 4);
        [self doMoveFrom: self.pendingFrom to: self.pendingTo promotion: prom[buttonIndex]];
    }
    else if ([[actionSheet title] isEqualToString: @"Promote to:"]) {
        // Another ugly hack: We use a colon at the end of the string to
        // distinguish between promotions in the two move input methods.
        static const PieceType prom[4] = { QUEEN, ROOK, KNIGHT, BISHOP };
        assert(buttonIndex >= 0 && buttonIndex < 4);
        actionSheet = nil; // ARC repair // Seth 12.30.13
        
        Move m = make_promotion_move(self.pendingFrom, self.pendingTo, prom[buttonIndex]);
        [self animateMove: m];
        [self.game doMove: m];
        
        if ([self.remoteEngineController isConnected])
            [self.remoteEngineController
             sendToServer: [NSString stringWithFormat: @"m %s\n",
                            move_to_string(m).c_str()]];
        
        [self updateMoveList];
        [self showBookMoves];
        [self playClickSound];
        [self gameEndTest];
        [self engineGo];
    }
}
//
//
///// moveIsPending tests if there is a pending move waiting for the user to
///// choose the promotion piece. Related to the hideous hack in
///// doMoveFrom:to:promotion.

- (BOOL)moveIsPending {
    return self.pendingFrom != SQ_NONE;
}

- (Piece)pieceOn:(Square)sq {
    assert(square_is_ok(sq));
    return [self.game pieceOn: [self rotateSquare: sq]];
}

- (BOOL)pieceCanMoveFrom:(Square)sq {
    assert(square_is_ok(sq));
    return [self.game pieceCanMoveFrom: [self rotateSquare: sq]];
}


- (int)pieceCanMoveFrom:(Square)fSq to:(Square)tSq {
    
    fSq = [self rotateSquare: fSq];
    tSq = [self rotateSquare: tSq];
    
    // If the squares are invalid, the move can't be legal.
    if (!square_is_ok(fSq) || !square_is_ok(tSq))
        return 0;
    
    // Make sure we don't capture a friendly piece. This is important, because
    // of the way castling moves are encoded.
    if (color_of_piece([self.game pieceOn: tSq]) == color_of_piece([self.game pieceOn: fSq]))
        return 0;
    
    // HACK: Castling. The user probably tries to move the king two squares to
    // the side when castling, but Stockfish internally encodes castling moves
    // as "king captures rook". We handle this by adjusting tSq when the user
    // tries to move the king two squares to the side:
    if (fSq == SQ_E1 && tSq == SQ_G1 && [self.game pieceOn: fSq] == WK)
        tSq = SQ_H1;
    else if (fSq == SQ_E1 && tSq == SQ_C1 && [self.game pieceOn: fSq] == WK)
        tSq = SQ_A1;
    else if (fSq == SQ_E8 && tSq == SQ_G8 && [self.game pieceOn: fSq] == BK)
        tSq = SQ_H8;
    else if (fSq == SQ_E8 && tSq == SQ_C8 && [self.game pieceOn: fSq] == BK)
        tSq = SQ_A8;
    
    return [self.game pieceCanMoveFrom: fSq to: tSq];
}


///// destinationSquaresFrom:saveInArray takes a square and a C array of squares
///// as input, finds all squares the piece on the given square can move to,
///// and stores these possible destination squares in the array. This is used
///// in the GUI in order to highlight the squares a piece can move to.

- (int)destinationSquaresFrom:(Square)sq saveInArray:(Square *)sqs {
    int i, j, n;
    Move mlist[32];
    
    assert(square_is_ok(sq));
    assert(sqs != NULL);
    
    sq = [self rotateSquare: sq];
    
    n = [self.game movesFrom: sq saveInArray: mlist];
    for (i = 0, j = 0; i < n; i++)
        // Only include non-promotions and queen promotions, in order to avoid
        // having the same destination squares multiple times in the array.
        if (!move_promotion(mlist[i]) || move_promotion(mlist[i]) == QUEEN) {
            // For castling moves, adjust the destination square so that it displays
            // correctly when squares are highlighted in the GUI.
            if (move_is_long_castle(mlist[i]))
                sqs[j] = [self rotateSquare: move_to(mlist[i]) + 2];
            else if (move_is_short_castle(mlist[i]))
                sqs[j] = [self rotateSquare: move_to(mlist[i]) - 1];
            else
                sqs[j] = [self rotateSquare: move_to(mlist[i])];
            j++;
        }
    sqs[j] = SQ_NONE;
    return j;
}


///// doMoveFrom:to:promotion executes a move made by the user, and is called by
///// touchesEnded:withEvent in the PieceImageView class. Legality is checked
///// by that method, so at present we can safely assume that the move is legal.
///// Update the game, and do necessary updates to the board view (remove
///// captured pieces, move rook in case of castling).
//
- (void)doMoveFrom:(Square)fSq to:(Square)tSq promotion:(PieceType)prom {
    assert(square_is_ok(fSq));
    assert(square_is_ok(tSq));
    
    fSq = [self rotateSquare: fSq];
    tSq = [self rotateSquare: tSq];
    
    if ([self.game pieceCanMoveFrom: fSq to: tSq] > 1 && prom == NO_PIECE_TYPE) {
        // More than one legal move between the two squares. This means that the
        // user tries to do a promotion move, even though the "prom" parameter
        // doesn't say so. Handling this is really messy, because the iPhone SDK
        // doesn't seem to have anything equivalent to Cocoa's NSAlert() function.
        // What we really want to do is to bring up a modal dialog and stopping
        // until the user chooses a piece to promote to. This doesn't seem to be
        // possible: When the user chooses a menu option, the delegate method.
        // actionSheet:clickedButtonAtIndex: function is called, and control never
        // returns to the present function.
        //
        // We hack around this problem by remembering fSq and tSq, and calling
        // doMoveFrom:to:promotion again with the remembered values and the chosen
        // promotion piece from the delegate method. This is really ugly.  :-(
        self.pendingFrom = [self rotateSquare: fSq];
        self.pendingTo = [self rotateSquare: tSq];
        UIActionSheet *menu =
        [[UIActionSheet alloc]
         initWithTitle: @"Promote to"
         delegate: self
         cancelButtonTitle: nil
         destructiveButtonTitle: nil
         otherButtonTitles: @"Queen", @"Rook", @"Knight", @"Bishop", nil];
        [menu showInView: [self.boardView superview]];
        return;
    }
    
//    // HACK: Castling. The user probably tries to move the king two squares to
//    // the side when castling, but Stockfish internally encodes castling moves
//    // as "king captures rook". We handle this by adjusting tSq when the user
//    // tries to move the king two squares to the side:
    static const int woo = 1, wooo = 2, boo = 3, booo = 4;
    int castle = 0;
    if (fSq == SQ_E1 && tSq == SQ_G1 && [self.game pieceOn: fSq] == WK) {
        tSq = SQ_H1; castle = woo;
    } else if (fSq == SQ_E1 && tSq == SQ_C1 && [self.game pieceOn: fSq] == WK) {
        tSq = SQ_A1; castle = wooo;
    } else if (fSq == SQ_E8 && tSq == SQ_G8 && [self.game pieceOn: fSq] == BK) {
        tSq = SQ_H8; castle = boo;
    } else if (fSq == SQ_E8 && tSq == SQ_C8 && [self.game pieceOn: fSq] == BK) {
        tSq = SQ_A8; castle = booo;
    }
    
    if (castle) {
        // Move the rook.
        PieceImageView *piv;
        Square rsq;
        
        if (castle == woo) {
            piv = [self pieceImageViewForSquare: SQ_H1];
            rsq = [self rotateSquare: SQ_F1];
        }
        else if (castle == wooo) {
            piv = [self pieceImageViewForSquare: SQ_A1];
            rsq = [self rotateSquare: SQ_D1];
        }
        else if (castle == boo) {
            piv = [self pieceImageViewForSquare: SQ_H8];
            rsq = [self rotateSquare: SQ_F8];
        }
        else if (castle == booo) {
            piv = [self pieceImageViewForSquare: SQ_A8];
            rsq = [self rotateSquare: SQ_D8];
        }
        else
            assert(false);
        [piv moveToSquare: rsq];
    }
    else if ([self.game pieceOn: tSq] != EMPTY)
        // Capture. Remove captured piece.
        [self removePieceOn: tSq];
    else if (type_of_piece([self.game pieceOn: fSq]) == PAWN
             && square_file(tSq) != square_file(fSq)) {
        // Pawn moves to a different file, and destination square is empty. This
        // must be an en passant capture. Remove captured pawn:
        Square epSq = tSq - pawn_push([self.game sideToMove]);
        assert([self.game pieceOn: epSq]
               == pawn_of_color(opposite_color([self.game sideToMove])));
        [self removePieceOn: epSq];
    }
    
    // In case of promotion, update the piece image view.
    if (prom) {
        [self removePieceOn: fSq];
        [self putPiece: piece_of_color_and_type([self.game sideToMove], prom)
                    on: tSq];
    }
    
    // Update the game and move list:
    Move m = [self.game doMoveFrom: fSq to: tSq promotion: prom];
    if ([self.remoteEngineController isConnected])
        [self.remoteEngineController
         sendToServer: [NSString stringWithFormat: @"m %s\n",
                        move_to_string(m).c_str()]];
    [self updateMoveList];
    [self showBookMoves];
    self.pendingFrom = self.pendingTo = SQ_NONE;
    
    // Play a click sound when the move has been made.
    [self playClickSound];
    
    // Game over?
    [self gameEndTest];
    
    // Clear the search stats view
    [self.searchStatsView setText: @""];
    
    // HACK to handle promotions
    if (prom)
        [self engineGo];
}


- (void)promotionMenu {
    [[[UIActionSheet alloc]
      initWithTitle: @"Promote to:"
      delegate: self
      cancelButtonTitle: nil
      destructiveButtonTitle: nil
      otherButtonTitles: @"Queen", @"Rook", @"Knight", @"Bishop", nil]
     showInView: [self.boardView superview]];
}


- (void)animateMoveFrom:(Square)fSq to:(Square)tSq {
    assert(square_is_ok(fSq));
    assert(square_is_ok(tSq));
    
    fSq = [self rotateSquare: fSq];
    tSq = [self rotateSquare: tSq];
    
    if ([self.game pieceCanMoveFrom: fSq to: tSq] > 1) {
        self.pendingFrom = fSq;
        self.pendingTo = tSq;
        [self promotionMenu];
        return;
    }
    
//    // HACK: Castling. The user probably tries to move the king two squares to
//    // the side when castling, but Stockfish internally encodes castling moves
//    // as "king captures rook". We handle this by adjusting tSq when the user
//    // tries to move the king two squares to the side:
    static const int woo = 1, wooo = 2, boo = 3, booo = 4;
    int castle = 0;
    BOOL ep = NO;
    if (fSq == SQ_E1 && tSq == SQ_G1 && [self.game pieceOn: fSq] == WK) {
        tSq = SQ_H1; castle = woo;
    } else if (fSq == SQ_E1 && tSq == SQ_C1 && [self.game pieceOn: fSq] == WK) {
        tSq = SQ_A1; castle = wooo;
    } else if (fSq == SQ_E8 && tSq == SQ_G8 && [self.game pieceOn: fSq] == BK) {
        tSq = SQ_H8; castle = boo;
    } else if (fSq == SQ_E8 && tSq == SQ_C8 && [self.game pieceOn: fSq] == BK) {
        tSq = SQ_A8; castle = booo;
    }
    else if (type_of_piece([self.game pieceOn: fSq]) == PAWN &&
            [self.game pieceOn: tSq] == EMPTY &&
             square_file(fSq) != square_file(tSq))
        ep = YES;
    
    Move m;
    if (castle)
        m = make_castle_move(fSq, tSq);
    else if (ep)
        m = make_ep_move(fSq, tSq);
    else
        m = make_move(fSq, tSq);
    
    [self animateMove: m];
    [self.game doMove: m];
    
    if ([self.remoteEngineController isConnected])
        [self.remoteEngineController
         sendToServer: [NSString stringWithFormat: @"m %s\n",
                        move_to_string(m).c_str()]];
    
    [self updateMoveList];
    [self showBookMoves];
    [self playClickSound];
    [self gameEndTest];
    [self engineGo];
}


///// removePieceOn: removes a piece from the board view.  The piece is
///// assumed to still be present on the board in the current position
///// in the game: The method is called directly before a captured piece
///// is removed from the game board.

- (void)removePieceOn:(Square)sq {
    sq = [self rotateSquare: sq];
    assert(square_is_ok(sq));
    for (int i = 0; i < [self.pieceViews count]; i++)
        if ([[self.pieceViews objectAtIndex: i] square] == sq) {
            [[self.pieceViews objectAtIndex: i] removeFromSuperview];
            [self.pieceViews removeObjectAtIndex: i];
            break;
        }
}


///// putPiece:on: inserts a new PieceImage subview to the board view. This method
///// is called when the user takes back a capturing move.

- (void)putPiece:(Piece)p on:(Square)sq {
    assert(piece_is_ok(p));
    assert(square_is_ok(sq));
    
    sq = [self rotateSquare: sq];
    
    float sqSize = [self.boardView sqSize];
    CGRect rect = CGRectMake(0.0f, 0.0f, sqSize, sqSize);
    rect.origin = CGPointMake((int(sq)%8) * sqSize, (7-int(sq)/8) * sqSize);
    PieceImageView *piv = [[PieceImageView alloc] init];  ///: rect       <<<< *************** NEeed to FIX /... SEth 1.25.14
//                                                  gameController: self
//                                                      boardView: self.boardView];
    [piv setImage: self.pieceImages[p]];
    [piv setUserInteractionEnabled: YES];
    [piv setAlpha: 0.0];
    [self.boardView addSubview: piv];
    [self.pieceViews addObject: piv];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations: nil context: context];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 0.25];
    [piv setAlpha: 1.0];
    [UIView commitAnimations];
    
    piv = nil; //// ARC repair Seth 12.30.13 ////
    
}


///// takeBackMove takes back the last move played, unless we are at the beginning
///// of the game, in which case nothing happens. Both the game and the board view
///// are updated. We should maybe highlight the current move in the move list,
///// too, but this seems tricky.

- (void)takeBackMove {
    if (![self.game atBeginning]) {
        ChessMove *cm = [self.game previousMove];
        Square from = move_from([cm move]), to = move_to([cm move]);
        UndoInfo ui = [cm undoInfo];
        
        // If the engine is pondering, stop it before unmaking the move.
        if (self.isPondering) {
            NSLog(@"pondermiss because of take back");
            [self.engineController pondermiss];
            self.isPondering = NO;
        }
        
        // HACK: Castling. Stockfish internally encodes castling moves as "king
        // captures rook", which means that the "to" square does not contain the
        // king's current square on the board. Adjust the "to" square, and check
        // what sort of castling move it is, to help us move the rook back home
        // later.
        static const int woo = 1, wooo = 2, boo = 3, booo = 4;
        int castle = 0;
        if (move_is_short_castle([cm move])) {
            castle = ([self.game sideToMove] == BLACK)? woo : boo;
            to = ([self.game sideToMove] == BLACK)? SQ_G1 : SQ_G8;
        }
        else if (move_is_long_castle([cm move])) {
            castle = ([self.game sideToMove] == BLACK)? wooo : booo;
            to = ([self.game sideToMove] == BLACK)? SQ_C1 : SQ_C8;
        }
        
        // In case of promotion, unpromote the piece before moving it back:
        if (move_promotion([cm move]))
            [[self pieceImageViewForSquare: to]
             setImage: self.pieceImages[pawn_of_color(opposite_color([self.game sideToMove]))]];
        
        // Put the moving piece back at its source square:
        [[self pieceImageViewForSquare: to] moveToSquare:
         [self rotateSquare: from]];
        
        // For castling moves, move the rook back:
        if (castle == woo)
            [[self pieceImageViewForSquare: SQ_F1]
             moveToSquare: [self rotateSquare: SQ_H1]];
        else if (castle == wooo)
            [[self pieceImageViewForSquare: SQ_D1]
             moveToSquare: [self rotateSquare: SQ_A1]];
        else if (castle == boo)
            [[self pieceImageViewForSquare: SQ_F8]
             moveToSquare: [self rotateSquare: SQ_H8]];
        else if (castle == booo)
            [[self pieceImageViewForSquare: SQ_D8]
             moveToSquare: [self rotateSquare: SQ_A8]];
        
        // In the case of a capture, put the captured piece back on the board.
        if (move_is_ep([cm move]))
            [self putPiece: pawn_of_color([self.game sideToMove])
                        on: to + pawn_push([self.game sideToMove])];
        else if (ui.capture)
            [self putPiece: piece_of_color_and_type([self.game sideToMove], ui.capture)
                        on: to];
        
        // Don't show the last move played any more:
        [self.boardView hideLastMove];
        [self.boardView stopHighlighting];
        
        // Stop engine:
        if ([self computersTurnToMove]) {
            self.engineIsPlaying = NO;
            [self.engineController abortSearch];
            [self.engineController commitCommands];
        }
        
        // Update remote engine:
        if ([self.remoteEngineController isConnected]) {
            //[remoteEngineController sendToServer: @"s\n"];  // Stop search
            [self.remoteEngineController sendToServer: @"t\n"];  // Take back
        }
        
        // Update the game:
        [self.game takeBack];
        
        // If in analyse mode, send new position to engine, and tell it to start
        // thinking:
        if (self.gameMode == GAME_MODE_ANALYSE && ![self.game positionIsTerminal]) {
            if (![self.remoteEngineController isConnected]) {
                [self.engineController abortSearch];
                [self.engineController sendCommand: [self.game uciGameString]];
                [self.engineController sendCommand: @"go infinite"];
                [self.engineController commitCommands];
            }
            else {
                [self.remoteEngineController sendToServer: @"gi\n"];
            }
        }
        
        // Stop the clock:
        [self.game stopClock];
    }
    [self updateMoveList];
    [self showBookMoves];
}


- (void)takeBackAllMoves {
    if (![self.game atBeginning]) {
        
        [self.boardView hideLastMove];
        [self.boardView stopHighlighting];
        
        // Release piece images
        for (PieceImageView *piv in self.pieceViews)
            [piv removeFromSuperview];
        
        // Update game
        [self.game toBeginning];
        
        // Update board
        self.pieceViews = [[NSMutableArray alloc] init];
        [self showPiecesAnimate: NO];
        
        // Stop engine:
        if ([self computersTurnToMove]) {
            self.engineIsPlaying = NO;
            [self.engineController abortSearch];
            [self.engineController commitCommands];
        }
        
        // Update remote engine:
        if ([self.remoteEngineController isConnected]) {
            //[remoteEngineController sendToServer: @"s\n"];  // Stop search
            [self.remoteEngineController sendToServer: @"b\n"];  // Go to beginning of game
        }
        
        // If in analyse mode, send new position to engine, and tell it to start
        // thinking:
        if (self.gameMode == GAME_MODE_ANALYSE && ![self.game positionIsTerminal]) {
            if (![self.remoteEngineController isConnected]) {
                [self.engineController abortSearch];
                [self.engineController sendCommand: [self.game uciGameString]];
                [self.engineController sendCommand: @"go infinite"];
                [self.engineController commitCommands];
            }
            else {
                [self.remoteEngineController sendToServer: @"gi\n"];
            }
        }
        
        // Stop the clock:
        [self.game stopClock];
        
        [self updateMoveList];
        [self showBookMoves];
    }
}


- (void)animateMove:(Move)m {
    Square from = move_from(m), to = move_to(m);
    
    // HACK: Castling. Stockfish internally encodes castling moves as "king
    // captures rook", which means that the "to" square does not contain the
    // king's current square on the board. Adjust the "to" square, and check
    // what sort of castling move it is, to help us move the rook later.
    static const int woo = 1, wooo = 2, boo = 3, booo = 4;
    int castle = 0;
    if (move_is_short_castle(m)) {
        castle = ([self.game sideToMove] == WHITE)? woo : boo;
        to = ([self.game sideToMove] == WHITE)? SQ_G1 : SQ_G8;
    }
    else if (move_is_long_castle(m)) {
        castle = ([self.game sideToMove] == WHITE)? wooo : booo;
        to = ([self.game sideToMove] == WHITE)? SQ_C1 : SQ_C8;
    }
    
    // In the case of a capture, remove the captured piece.
    if ([self.game pieceOn: to] != EMPTY)
        [self removePieceOn: to];
    else if (move_is_ep(m))
        [self removePieceOn: to - pawn_push([self.game sideToMove])];
    
    // Move the piece
    [[self pieceImageViewForSquare: from] moveToSquare:
     [self rotateSquare: to]];
    
    // If move is promotion, update the piece image:
    if (move_promotion(m))
        [[self pieceImageViewForSquare: to]
         setImage:
         self.pieceImages[piece_of_color_and_type([self.game sideToMove],
                                             move_promotion(m))]];
    
    // If move is a castle, move the rook
    if (castle == woo)
        [[self pieceImageViewForSquare: SQ_H1]
         moveToSquare: [self rotateSquare: SQ_F1]];
    else if (castle == wooo)
        [[self pieceImageViewForSquare: SQ_A1]
         moveToSquare: [self rotateSquare: SQ_D1]];
    else if (castle == boo)
        [[self pieceImageViewForSquare: SQ_H8]
         moveToSquare: [self rotateSquare: SQ_F8]];
    else if (castle == booo)
        [[self pieceImageViewForSquare: SQ_A8]
         moveToSquare: [self rotateSquare: SQ_D8]];
}


///// replayMove steps forward one move in the game, unless we are at the end of
///// the game, in which case nothing happens. Both the game and the board view
///// are updated. We should maybe highlight the current move in the move list,
///// too, but this seems tricky.

- (void)replayMove {
    if (![self.game atEnd]) {
        ChessMove *cm = [self.game nextMove];
        
        [self animateMove: [cm move]];
        
        // Update the game:
        [self.game stepForward];
        
        // Don't show the last move played any more:
        [self.boardView hideLastMove];
        [self.boardView stopHighlighting];
        
        // Update remote engine:
        if ([self.remoteEngineController isConnected]) {
            //[remoteEngineController sendToServer: @"s\n"];  // Stop search
            [self.remoteEngineController sendToServer: @"f\n"];  // Step forward
        }
        
        // If in analyse mode, send new position to engine, and tell it to start
        // thinking:
        if (self.gameMode == GAME_MODE_ANALYSE && ![self.game positionIsTerminal]) {
            if (![self.remoteEngineController isConnected]) {
                [self.engineController abortSearch];
                [self.engineController sendCommand: [self.game uciGameString]];
                [self.engineController sendCommand: @"go infinite"];
                [self.engineController commitCommands];
            }
            else {
                [self.remoteEngineController sendToServer: @"gi\n"]; // Start new search
            }
        }
    }
    [self updateMoveList];
    [self showBookMoves];
}


- (void)replayAllMoves {
    if (![self.game atEnd]) {
        
        [self.boardView hideLastMove];
        [self.boardView stopHighlighting];
        
        // Release piece images
        for (PieceImageView *piv in self.pieceViews)
            [piv removeFromSuperview];
        
        // Update game
        [self.game toEnd];
        
        // Update board
        self.pieceViews = [[NSMutableArray alloc] init];
        [self showPiecesAnimate: NO];
        
        // Stop engine:
        if ([self computersTurnToMove]) {
            self.engineIsPlaying = NO;
            [self.engineController abortSearch];
            [self.engineController commitCommands];
        }
        
        // Update remote engine:
        if ([self.remoteEngineController isConnected]) {
            //[remoteEngineController sendToServer: @"s\n"]; // Stop search
            [self.remoteEngineController sendToServer: @"e\n"]; // Go to end of game
        }
        
        // If in analyse mode, send new position to engine, and tell it to start
        // thinking:
        if (self.gameMode == GAME_MODE_ANALYSE && ![self.game positionIsTerminal]) {
            if (![self.remoteEngineController isConnected]) {
                [self.engineController abortSearch];
                [self.engineController sendCommand: [self.game uciGameString]];
                [self.engineController sendCommand: @"go infinite"];
                [self.engineController commitCommands];
            }
            else {
                [self.remoteEngineController sendToServer: @"gi\n"];
            }
        }
        
        // Stop the clock:
        [self.game stopClock];
        
        [self updateMoveList];
        [self showBookMoves];
    }
}


///// showPiecesAnimate: creates the piece image views and attaches them as
///// subviews to the board view.  There is a boolean parameter which tells
///// the method whether the pieces should appear gradually or instantly.

- (void)showPiecesAnimate:(BOOL)animate {
    float sqSize = [self.boardView sqSize];
    CGRect rect = CGRectMake(0.0f, 0.0f, sqSize, sqSize);
    for (Square sq = SQ_A1; sq <= SQ_H8; sq++) {
        Square s = [self rotateSquare: sq];
        Piece p = [self pieceOn: s];
        if (p != EMPTY) {
            assert(piece_is_ok(p));
            rect.origin = CGPointMake((int(s)%8) * sqSize, (7-int(s)/8) * sqSize);   ///  <--------  Need to FiX .// seth 1.25.14
            PieceImageView *piv = [[PieceImageView alloc] init]; //// ..... //// might need to pass a pieceImageview through somethoe...... *************************** <------------------******************
            
            
            
            
            
            
            
            [piv setImage: self.pieceImages[p]];
            [piv setUserInteractionEnabled: YES];
            [piv setAlpha: 0.0];
            [self.boardView addSubview: piv];
            [self.pieceViews addObject: piv];
            
        }
    }
    if (animate) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations: nil context: context];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration: 1.2];
        for (PieceImageView *piv in self.pieceViews)
            [piv setAlpha: 1.0];
        [UIView commitAnimations];
    }
    else
        for (PieceImageView *piv in self.pieceViews)
            [piv setAlpha: 1.0];
}


- (PieceImageView *)pieceImageViewForSquare:(Square)sq {
    sq = [self rotateSquare: sq];
    for (PieceImageView *piv in self.pieceViews)
        if ([piv square] == sq)
            return piv;
    return nil;
}


- (void)rotateBoard {
    self.rotated = !self.rotated;
    for (PieceImageView *piv in self.pieceViews)
        [piv moveToSquare: Square(SQ_H8 - [piv square])];
    [self.boardView hideLastMove];
    [self.boardView stopHighlighting];
}


- (void)rotateBoard:(BOOL)rotate {
    if (self.rotated != self.rotated)
       [self rotateBoard];
}


///// showHint displays a suggestion for a good move to the user. At the
///// moment, it just displays a random legal move.

- (void)showHint {
    if (self.gameMode == GAME_MODE_ANALYSE)
        [[[UIAlertView alloc] initWithTitle: @"Hints are not available in analyse mode!"
                                    message: nil
                                   delegate: self
                          cancelButtonTitle: nil
                          otherButtonTitles: @"OK", nil] show];  /// ARC repair // removed autorelease // Seth 12.30.13
    
    else if (self.gameMode == GAME_MODE_TWO_PLAYER)
        [[[UIAlertView alloc] initWithTitle: @"Hints are not available in two player mode!"
                                    message: nil
                                   delegate: self
                          cancelButtonTitle: nil
                          otherButtonTitles: @"OK", nil] show];  /// ARC repair // removed autorelease // Seth 12.30.13
    else {
        Move mlist[256], m;
        int n;
        n = [self.game generateLegalMoves: mlist];
        m = [self.game getBookMove];
        
        if (m == MOVE_NONE)
            m = [self.game getHintForCurrentPosition];
        
        if (m != MOVE_NONE) {
            Square to = move_to(m);
            if (move_is_long_castle(m)) to += 2;
            else if (move_is_short_castle(m)) to -= 1;
            [[self pieceImageViewForSquare: move_from(m)]
             moveToSquareAndBack: [self rotateSquare: to]];
        }
        else
             [[[UIAlertView alloc] initWithTitle: @"No hint available!"
                                        message: nil
                                       delegate: self
                              cancelButtonTitle: nil
                              otherButtonTitles: @"OK", nil] show];  /// ARC repair // removed autorelease // Seth 12.30.13
        
    }
}


///// emailPgnString returns an NSString representing a mailto: URL with the
///// current game in PGN notation included in the body.
- (NSString *)emailPgnString {
    return [self.game emailPgnString];
}


//- (void)playClickSound {                                      <----------*************FIX ME ///// seth 1.25.14
//    if ([[Options sharedOptions] moveSound])
//        AudioServicesPlaySystemSound(clickSound);
//}

- (void)displayPV:(NSString *)pv {
    if ([[Options sharedOptions] showAnalysis]) {
        if ([[Options sharedOptions] figurineNotation]) {
            unichar c;
            NSString *s;
            NSString *pc[6] = { @"K", @"Q", @"R", @"B", @"N" };
            int i;
            for (i = 0, c = 0x2654; i < 5; i++, c++) {
                s = [NSString stringWithCharacters: &c length: 1];
                pv = [pv stringByReplacingOccurrencesOfString: pc[i] withString: s];
            }
        }
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [self.analysisView setText: [NSString stringWithFormat: @"  %@", pv]];
        else
            [self.analysisView setText: pv];
    }
    else
        [self.analysisView setText: @""];
}


- (void)displaySearchStats:(NSString *)searchStats {
    if ([[Options sharedOptions] showAnalysis]) {
        if ([[Options sharedOptions] figurineNotation]) {
            unichar c;
            NSString *s;
            NSString *pc[6] = { @"K", @"Q", @"R", @"B", @"N" };
            int i;
            for (i = 0, c = 0x2654; i < 5; i++, c++) {
                s = [NSString stringWithCharacters: &c length: 1];
                searchStats =
                [searchStats stringByReplacingOccurrencesOfString: pc[i]
                                                       withString: s
                                                          options: 0
                                                            range: NSMakeRange(0, 20)];
            }
        }
        [self.searchStatsView setText: searchStats];
    }
    else
        [self.searchStatsView setText: @""];
}


- (void)setGameLevel:(GameLevel)newGameLevel {
    NSLog(@"new game level: %d", newGameLevel);
    _gameLevel = newGameLevel;
    if ([[Options sharedOptions] isFixedTimeLevel]) {
        NSLog(@"fixed time: %d", [[Options sharedOptions] timeIncrement]);
        [self.game setTimeControlWithFixedTime: [[Options sharedOptions] timeIncrement]];
    }
    else {
        NSLog(@"base time: %d increment: %d",
              [[Options sharedOptions] baseTime],
              [[Options sharedOptions] timeIncrement]);
        [self.game setTimeControlWithTime: [[Options sharedOptions] baseTime]
                           increment: [[Options sharedOptions] timeIncrement]];
    }
}

// MSM  1-26-14 We got rid of this getter, becuase it is not doing anything special, and
// by default it is included in the new Xcode - with the automatic synthesize.
// If we override BOTH setters and getters, we have to add in our own synthesize command.

//- (GameMode)gameMode
//{
//    return _gameMode;
//}


- (void)setGameMode:(GameMode)newGameMode
{
    NSLog(@"new game mode: %d", newGameMode);
    if (newGameMode == GAME_MODE_ANALYSE && newGameMode != GAME_MODE_ANALYSE)
    {
        [self.engineController pondermiss]; // HACK
        [self.engineController sendCommand:
         @"setoption name UCI_AnalyseMode value false"];
        [self.engineController commitCommands];
        if ([self.remoteEngineController isConnected])
            [self.remoteEngineController sendToServer: @"s\n"];
    }
    else if (self.isPondering)
    {
        NSLog(@"pondermiss because game mode changed while pondering");
        [self.engineController pondermiss];
        self.isPondering = NO;
    }
    [self.game setWhitePlayer:
     ((newGameMode == GAME_MODE_COMPUTER_BLACK)?
      [[[Options sharedOptions] fullUserName] copy] : ENGINE_NAME)];
    [self.game setBlackPlayer:
     ((newGameMode == GAME_MODE_COMPUTER_BLACK)?
      ENGINE_NAME : [[[Options sharedOptions] fullUserName] copy])];
    _gameMode = newGameMode;
    
    // If in analyse mode, automatically switch on "Show analysis"
    if (self.gameMode == GAME_MODE_ANALYSE && ![self.remoteEngineController isConnected]) {
        [[Options sharedOptions] setShowAnalysis: YES];
        [[self.boardView superview] bringSubviewToFront: self.searchStatsView];
        [self.searchStatsView setNeedsDisplay];
    }
    else
        [[self.boardView superview] sendSubviewToBack: self.searchStatsView];
    
    // Rotate board if necessary:
    if ((self.gameMode == GAME_MODE_COMPUTER_WHITE && !self.rotated) ||
        (self.gameMode == GAME_MODE_COMPUTER_BLACK && self.rotated))
        [self rotateBoard];
    
    // Start thinking if necessary:
    [self engineGo];
}


- (void)doEngineMove:(Move)m
{
    Square to = move_to(m);
    if (move_is_long_castle(m)) to += 2;
    else if (move_is_short_castle(m)) to -= 1;
    [self.boardView showLastMoveWithFrom: [self rotateSquare: move_from(m)]
                                 to: [self rotateSquare: to]];
    
    [self animateMove: m];
    [self.game doMove: m];
    
    if ([self.remoteEngineController isConnected])
        [self.remoteEngineController
         sendToServer: [NSString stringWithFormat: @"m %s\n",
                        move_to_string(m).c_str()]];
    
    [self updateMoveList];
    [self showBookMoves];
}


///// engineGo is called directly after the user has made a move.  It checks
///// the game mode, and sends a UCI "go" command to the engine if necessary.

- (void)engineGo {
    if (!self.engineController)
        [self startEngine];
    
    if (![self.game positionIsTerminal]) {
        if (self.gameMode == GAME_MODE_ANALYSE) {
            self.engineIsPlaying = NO;
            [self.engineController abortSearch];
            if (![self.remoteEngineController isConnected]) {
                [self.engineController sendCommand: [self.game uciGameString]];
                [self.engineController sendCommand:
                 @"setoption name UCI_AnalyseMode value true"];
                [self.engineController sendCommand: @"go infinite"];
                [self.engineController commitCommands];
            }
            else {
                [self.remoteEngineController sendToServer: @"s\n"];
                [self.remoteEngineController sendToServer: @"gi\n"];
            }
            return;
        }
        if (self.isPondering) {
            if ([self.game currentMove] == self.ponderMove) {
                [self.engineController ponderhit];
                self.isPondering = NO;
                return;
            }
            else {
                NSLog(@"REAL pondermiss");
                [self.engineController pondermiss];
                while ([self.engineController engineIsThinking]);
            }
            self.isPondering = NO;
        }
        if ((self.gameMode==GAME_MODE_COMPUTER_BLACK && [self.game sideToMove]==BLACK) ||
            (self.gameMode==GAME_MODE_COMPUTER_WHITE && [self.game sideToMove]==WHITE)) {
            // Computer's turn to move.  First look for a book move.  If no book move
            // is found, start a search.
            Move m;
            if ([[Options sharedOptions] strength] > 2200 ||
                [self.game currentMoveIndex] < 10 ||
                [self.game currentMoveIndex] < [[Options sharedOptions] strength] / 70)
                m = [self.game getBookMove];
            else
                m = MOVE_NONE;
            if (m != MOVE_NONE)
                [self doEngineMove: m];
            else {
                // Update play style, if necessary
                if ([[Options sharedOptions] playStyleWasChanged]) {
                    NSLog(@"play style was changed to: %@",
                          [[Options sharedOptions] playStyle]);
                    [self.engineController sendCommand:
                     [NSString stringWithFormat:
                      @"setoption name Play Style value %@",
                      [[Options sharedOptions] playStyle]]];
                    [self.engineController commitCommands];
                }
                // Update strength, if necessary
                if ([[Options sharedOptions] strengthWasChanged]) {
                    [self.engineController sendCommand: @"setoption name Clear Hash"];
                    if ([[Options sharedOptions] strength] == 2500) // Max strength
                        [self.engineController
                         sendCommand: @"setoption name UCI_LimitStrength value false"];
                    else
                        [self.engineController
                         sendCommand: @"setoption name UCI_LimitStrength value true"];
                    [self.engineController sendCommand:
                     [NSString stringWithFormat:
                      @"setoption name UCI_Elo value %d",
                      [[Options sharedOptions] strength]]];
                    [self.engineController commitCommands];
                }
                // Start thinking.
                self.engineIsPlaying = YES;
                if (![self.remoteEngineController isConnected]) {
                    [self.engineController sendCommand: [self.game uciGameString]];
                    if ([[Options sharedOptions] isFixedTimeLevel])
                        [self.engineController
                         sendCommand: [NSString stringWithFormat: @"go movetime %d",
                                       [[Options sharedOptions] timeIncrement]]];
                    else
                        [self.engineController
                         sendCommand: [NSString stringWithFormat: @"go wtime %d btime %d winc %d binc %d",
                                       [[self.game clock] whiteRemainingTime],
                                       [[self.game clock] blackRemainingTime],
                                       [[self.game clock] whiteIncrement],
                                       [[self.game clock] blackIncrement]]];
                    [self.engineController commitCommands];
                }
                else {
                    // TODO: Fixed time levels
                    [self.remoteEngineController
                     sendToServer: [NSString stringWithFormat: @"go %d %d %d %d\n",
                                    [[self.game clock] whiteRemainingTime],
                                    [[self.game clock] whiteIncrement],
                                    [[self.game clock] blackRemainingTime],
                                    [[self.game clock] blackIncrement]]];
                }
            }
        }
    }
}


- (void)engineGoPonder:(Move)pMove {
    // TODO: Pondering with remote engine.
    if ([self.remoteEngineController isConnected])
        return;
    
    if (![self.game positionIsTerminal] && ![self.game positionAfterMoveIsTerminal: pMove]) {
        assert(self.engineIsPlaying);
        assert((self.gameMode==GAME_MODE_COMPUTER_BLACK && [self.game sideToMove]==WHITE) ||
               (self.gameMode==GAME_MODE_COMPUTER_WHITE && [self.game sideToMove]==BLACK));
        assert(pMove != MOVE_NONE);
        
        // Start thinking.
        self.engineIsPlaying = YES;
        [self.engineController
         sendCommand:
         [NSString stringWithFormat: @"%@ %s",
          [self.game uciGameString], move_to_string(pMove).c_str()]];
        self.isPondering = YES;
        [self.engineController
         sendCommand: [NSString stringWithFormat: @"go ponder wtime %d btime %d winc %d binc %d",
                       [[self.game clock] whiteRemainingTime],
                       [[self.game clock] blackRemainingTime],
                       [[self.game clock] whiteIncrement],
                       [[self.game clock] blackIncrement]]];
        [self.engineController commitCommands];
    }
}


/// engineMadeMove: is called by the engine controller whenever the engine
/// makes a move.  The input is an NSArray which is assumed to consist of two
/// NSStrings, representing a move and a ponder move.  The reason we stuff the
/// move strings into an array is that the method is called from another thread,
/// using the performSelectorOnMainThread:withObject:waitUntilDone: method,
/// and this method can only pass a single argument to the selector.

- (void)engineMadeMove:(NSArray *)array {
    assert([array count] <= 2);
    Move m = [self.game moveFromString: [array objectAtIndex: 0]];
    assert(m != MOVE_NONE);
    [self.game setHintForCurrentPosition: m];
    if (self.engineIsPlaying) {
        [self doEngineMove: m];
        [self playClickSound];
        if ([array count] == 2) {
            self.ponderMove = [self.game moveFromString: [array objectAtIndex: 1]];
            [self.game setHintForCurrentPosition: self.ponderMove];
            if ([[Options sharedOptions] permanentBrain])
                [self engineGoPonder: self.ponderMove];
        }
        [self gameEndTest];
    }
}


- (BOOL)usersTurnToMove {
    return
    self.gameMode == GAME_MODE_TWO_PLAYER ||
    self.gameMode == GAME_MODE_ANALYSE ||
    (self.gameMode == GAME_MODE_COMPUTER_BLACK && [self.game sideToMove] == WHITE) ||
    (self.gameMode == GAME_MODE_COMPUTER_WHITE && [self.game sideToMove] == BLACK);
}


- (BOOL)computersTurnToMove {
    return ![self usersTurnToMove];
}


- (void)engineMoveNow {
    if ([self computersTurnToMove]) {
        if (![self.remoteEngineController isConnected]) {
            [self.engineController abortSearch];
            [self.engineController commitCommands];
        }
        else
            [self.remoteEngineController sendToServer: @"s\n"];
    }
}


- (void)gameEndTest {
    if ([self.game positionIsMate]) {
        [[[UIAlertView alloc] initWithTitle: (([self.game sideToMove] == WHITE)?
                                              @"Black wins" : @"White wins")
                                    message: @"Checkmate!"
                                   delegate: self
                          cancelButtonTitle: nil
                          otherButtonTitles: @"OK", nil] show];  /// ARC repair // removed autorelease // Seth 12.30.13
        
        [self.game setResult: (([self.game sideToMove] == WHITE)? @"0-1" : @"1-0")];
    }
    else if ([self.game positionIsDraw]) {
        [[[UIAlertView alloc] initWithTitle: @"Game drawn"
                                    message: [self.game drawReason]
                                   delegate: self
                          cancelButtonTitle: nil
                          otherButtonTitles: @"OK", nil] show];  /// ARC repair // removed autorelease // Seth 12.30.13
        
        [self.game setResult: @"1/2-1/2"];
    }
}


//This loads the pieces images into the pieces array.
- (void)loadPieceImages {
    
    static NSString *pieceImageNames[16] = {
        nil, @"WPawn", @"WKnight", @"WBishop", @"WRook", @"WQueen", @"WKing", nil,
        nil, @"BPawn", @"BKnight", @"BBishop", @"BRook", @"BQueen", @"BKing", nil
    };
    NSString *pieceSet = [[Options sharedOptions] pieceSet];
    for (Piece p = WP; p <= BK; p++) {
        if (piece_is_ok(p)) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                self.pieceImages[p] =
                [UIImage imageNamed: [NSString stringWithFormat: @"%@%@96.png",
                                      pieceSet, pieceImageNames[p]]];
            else
                self.pieceImages[p] =
                [UIImage imageNamed: [NSString stringWithFormat: @"%@%@.png",
                                      pieceSet, pieceImageNames[p]]];
        }
        else
            self.pieceImages[p] = nil;
    }
    
}
//
//
//
//
//
- (void)pieceSetChanged:(NSNotification *)aNotification {
    [self loadPieceImages];
    for (Square sq = SQ_A1; sq <= SQ_H8; sq++) {
        Square s = [self rotateSquare: sq];
        if ([self pieceOn: s] != EMPTY) {
            PieceImageView *piv = [self pieceImageViewForSquare: sq];
            [piv setImage: self.pieceImages[[self pieceOn: s]]];
            [piv setNeedsDisplay];
        }
    }
}


- (void)gameFromPGNString:(NSString *)pgnString {
    self.game = nil;  /// ARC repair // removed release // Seth 12.30.13
    
    for (PieceImageView *piv in self.pieceViews)
        [piv removeFromSuperview];
    self.pieceViews = nil;   /// ARC repair // removed release // Seth 12.30.13
    
    
    @try {
        self.game = [[Game alloc] init];  //// need to <------------- FIX ME Seth 1.25.14
    }
    @catch (NSException *e) {
        NSLog(@"Exception while parsing stored game: %@", [e reason]);
        NSLog(@"game:\n%@", pgnString);
        self.game = [[Game alloc] init];    /// changed the alloc init on this...  sseth 1.25.14
    }
    
    if ([self.remoteEngineController isConnected])
        [self.remoteEngineController sendToServer: [self.game remoteEngineGameString]];
    
    self.gameLevel = [[Options sharedOptions] gameLevel];
    self.gameMode = [[Options sharedOptions] gameMode];
    [self.game setTimeControlWithTime: [[Options sharedOptions] baseTime]
                       increment: [[Options sharedOptions] timeIncrement]];
    self.pieceViews = [[NSMutableArray alloc] init];
    self.pendingFrom = SQ_NONE;
    self.pendingTo = SQ_NONE;
    
    [self showPiecesAnimate: YES];
    [self updateMoveList];
    [self showBookMoves];
    
  self.engineIsPlaying = NO;
    [self.engineController abortSearch];
    [self.engineController sendCommand: @"ucinewgame"];
    [self.engineController commitCommands];
    if (self.gameMode == GAME_MODE_ANALYSE)
        [self engineGo];
}


- (void)gameFromFEN:(NSString *)fen {
    self.game = nil; /// ARC repair // removed release // Seth 12.30.13
    
    for (PieceImageView *piv in self.pieceViews)
        [piv removeFromSuperview];
    self.pieceViews = nil; /// ARC repair // removed release // Seth 12.30.13
    
    self.game = [[Game alloc] init]; /////////// <------------------*************** FIX ME SEth 1.25.14
    if ([self.remoteEngineController isConnected])
        [self.remoteEngineController sendToServer: [self.game remoteEngineGameString]];
    self.gameLevel = [[Options sharedOptions] gameLevel];
    self.gameMode = [[Options sharedOptions] gameMode];
    [self.game setTimeControlWithTime: [[Options sharedOptions] baseTime]
                       increment: [[Options sharedOptions] timeIncrement]];
    self.pieceViews = [[NSMutableArray alloc] init];
    self.pendingFrom = SQ_NONE;
    self.pendingTo = SQ_NONE;
    
    [self showPiecesAnimate: YES];
    [self.moveListView setText: [self.game moveListString]];
    [self showBookMoves];
    
    self.engineIsPlaying = NO;
    [self.engineController abortSearch];
    [self.engineController sendCommand: @"ucinewgame"];
    [self.engineController commitCommands];
    if (self.gameMode == GAME_MODE_ANALYSE)
        [self engineGo];
}


- (void)showBookMoves {
    if ([[Options sharedOptions] showBookMoves]) {
        NSString *s = [self.game bookMovesAsString];
        if (s)
            [self.bookMovesView setText: [NSString stringWithFormat: @"  Book: %@",
                                     [self.game bookMovesAsString]]];
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [self.bookMovesView setText: @"  Book:"];
        else if ([[self.bookMovesView text] hasPrefix: @"  Book:"])
            [self.bookMovesView setText: @""];
    }
    else if ([[self.bookMovesView text] hasPrefix: @"  Book:"])
        [self.bookMovesView setText: @""];
}


- (void)changePlayStyle {
}


- (void)startThinking {
    if ([self.game sideToMove] == WHITE) {
        [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_WHITE];
        [self setGameMode: GAME_MODE_COMPUTER_WHITE];
    }
    else {
        [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_BLACK];
        [self setGameMode: GAME_MODE_COMPUTER_BLACK];
    }
}


- (BOOL)engineIsThinking {
    return [self.engineController engineIsThinking];
}


- (void)piecesSetUserInteractionEnabled:(BOOL)enable {
    for (PieceImageView *piv in self.pieceViews)
        [piv setUserInteractionEnabled: enable];
}


- (void)connectToServer {
    NSLog(@"Connecting to server %@ on port %d",
          [[Options sharedOptions] serverName], [[Options sharedOptions] serverPort]);
    [self.remoteEngineController
     connectToServer: [[Options sharedOptions] serverName]
     port: [[Options sharedOptions] serverPort]];
    [self.remoteEngineController sendToServer: [self.game remoteEngineGameString]];
    [[self.boardView superview] sendSubviewToBack: self.searchStatsView];
}

- (void)disconnectFromServer {
    NSLog(@"Disconnecting from server %@ on port %d",
          [[Options sharedOptions] serverName], [[Options sharedOptions] serverPort]);
    [self.remoteEngineController disconnect];
}


- (BOOL)isConnectedToServer {
    return [self.remoteEngineController isConnected];
}


- (void)redrawPieces {
    NSLog(@"preparing to redraw pieces");
    for (PieceImageView *piv in self.pieceViews)
        [piv removeFromSuperview];
    self.pieceViews = [[NSMutableArray alloc] init];
    [self showPiecesAnimate: NO];
    NSLog(@"finished redrawing pieces");
}


- (void)dealloc {
    NSLog(@"GameController dealloc");
    self.remoteEngineController = nil;
    [self.engineController quit];
    self.game = nil;
    self.pieceViews = nil; // Should we remove them from superview first??
//    for (Piece p = WP; p <= BK; p++)
//        self.pieceImages[p];
    self.engineController = nil;
//    
//    [[NSNotificationCenter defaultCenter] removeObserver: self];
//    AudioServicesDisposeSystemSoundID(clickSound);
    
    while ([self.engineController engineThreadIsRunning]);
    
    
    
}




@end
