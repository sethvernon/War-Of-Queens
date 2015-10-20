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

#import "BoardView.h"
#import "GameController.h"
#import "HighlightedSquaresView.h"
#import "LastMoveView.h"
#import "Options.h"
#import "PieceImageView.h"
#import "SelectedSquareView.h"

#include "../Chess/position.h"

using namespace Chess;

@interface BoardView()
@property (nonatomic, strong) NSString *gameName;
@property (nonatomic, strong) Options *options;
@end

@implementation BoardView

@synthesize gameController, fromSquare, sqSize;

/// initWithFrame: for BoardView simply initializes the square colors with
/// a brownish color scheme.

//
#define SquaresWide 8
#define SquaresHigh 8


-(Options *)options
{
    
    if (! _options ) _options = [[Options  alloc]initWithGameName:self.gameName];
    return _options ;

}

-(NSString *)gameName
{
    
    if (! _gameName ) _gameName = [[NSString  alloc]init];
    return _gameName ;

}


- (id)initWithFrame:(CGRect)frame
           GameName:(NSString *)gameName
{
    self.gameName = gameName;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
   if (self = [super initWithFrame: frame]) {
      darkSquareColor = [self.options darkSquareColor];
      lightSquareColor = [self.options lightSquareColor];
      darkSquareImage = [self.options darkSquareImage];
      lightSquareImage = [self.options lightSquareImage];
      selectedSquare = SQ_NONE;
      fromSquare = SQ_NONE;
      [[NSNotificationCenter defaultCenter] addObserver: self
                                               selector:@selector(colorsChanged:)
                                                   name: @"StockfishColorSchemeChanged"
                                                 object: nil];
      lastMoveView = nil;
       NSLog(@"%d", 8);  /// Mike 1.14.14
       
       NSLog(@"Loaded initWithFrame "); /// Seth 1.19.14
       
    
      sqSize = frame.size.width / 8;
   }
   return self;
    
    
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"darkSquareColor: %@  lightSquareColor: %@", darkSquareColor, lightSquareColor];
}


- (void)setFrame:(CGRect)frame {
   [super setFrame: frame];
    
   NSLog(@"setFrame Called");
    
   [self stopHighlighting];
   [self hideLastMove];
   selectedSquare = SQ_NONE;
   fromSquare = SQ_NONE;
   lastMoveView = nil;
   sqSize = frame.size.width / 8;
    
   NSLog(@"selectedSquare, fromSquare, lastMoveView, lastMoveView");
    
   [gameController redrawPieces];
    
    NSLog(@"Loaded redrawPieces from gameController");
}


/// drawRect: for BoardView just draws the squares.

- (void)drawRect:(CGRect)rect { //// SEth 1.19.14
   int i, j;
   for (i = 0; i < 8; i++)
      for (j = 0; j < 8; j++) {                                ///// Changes the squares for QueensWar SAV 2.10.14
         if (darkSquareImage && lightSquareImage) {
            [(((i + j) & 1)? darkSquareImage : lightSquareImage)
               drawAtPoint: CGPointMake(i * sqSize, j * sqSize)];
         }
         else {
            [(((i + j) & 1)? darkSquareColor : lightSquareColor) set];
            UIRectFill(CGRectMake(i*sqSize, j*sqSize, sqSize, sqSize));
             
             
         }
     }
}


- (Square)squareAtPoint:(CGPoint)point {
   return make_square(File(point.x / sqSize), Rank((8*sqSize-point.y) / sqSize));
}


- (CGPoint)originOfSquare:(Square)sq {
   return CGPointMake(int(square_file(sq)) * sqSize,
                      (7 - int(square_rank(sq))) * sqSize);
}


- (CGRect)rectForSquare:(Square)sq {
   CGRect r = CGRectMake(0.0f, 0.0f, sqSize, sqSize);
   r.origin = [self originOfSquare: sq];
   return r;
}

//
/// highlightSquares is passed an array of squares, and highlights these squares
/// on the board.  It is used to display the squares a piece can move to.

- (void)highlightSquares:(Square *)sqs {
   int i;
   for (i = 0; sqs[i] != SQ_NONE; i++)
      highlightedSquares[i] = sqs[i];
   highlightedSquares[i] = SQ_NONE;

   CGRect rect = [self frame];
   rect.origin = CGPointMake(0.0f, 0.0f);
   highlightedSquaresView =
      [[HighlightedSquaresView alloc] initWithFrame: rect squares: sqs];
   [highlightedSquaresView setOpaque: NO];
   [self addSubview: highlightedSquaresView];

   selectedSquare = SQ_NONE;
   selectedSquareView =
      [[SelectedSquareView alloc]
         initWithFrame: CGRectMake(0.0f, 0.0f, sqSize + 60.0f, sqSize + 60.0f)];
   [selectedSquareView setOpaque: NO];
   [self addSubview: selectedSquareView];
}
//
//
///// stopHighlighting stops highlighting squares.  It is called when the user
///// releases a piece.
//
- (void)stopHighlighting {
   if (highlightedSquaresView) {
      [highlightedSquaresView removeFromSuperview];
      highlightedSquaresView = nil;
   }
   if (selectedSquareView) {
      [selectedSquareView removeFromSuperview];
      selectedSquareView = nil;
   }
   selectedSquare = fromSquare = SQ_NONE;
    
    NSLog(@"stopHighlighting method called");
//
}
//
//
//
- (void)selectionMovedToPoint: (CGPoint)point {
   Square s = [self squareAtPoint: point];
   if (s != selectedSquare) {
      int i;
      for (i = 0; highlightedSquares[i] != SQ_NONE; i++)
         if (highlightedSquares[i] == s) {
            selectedSquare = s;
            [selectedSquareView
               moveToPoint: CGPointMake(int(square_file(s)) * sqSize - 30.0f,
                                        (7-int(square_rank(s))) * sqSize - 30.0f)];
            return;
         }
      [selectedSquareView hide];
      selectedSquare = SQ_NONE;
   }
}
//
//
- (void)colorsChanged:(NSNotification *)aNotification
{
   darkSquareColor = [self.options darkSquareColor];
   lightSquareColor = [self.options lightSquareColor];
   darkSquareImage = [self.options darkSquareImage];
   lightSquareImage = [self.options lightSquareImage];
   if (lastMoveView)
      [lastMoveView setNeedsDisplay];
   [self setNeedsDisplay];
}
//

- (void)showLastMoveWithFrom:(Square)s1 to:(Square)s2 {
   if (lastMoveView)
      [lastMoveView removeFromSuperview];
   lastMoveView =
      [[LastMoveView alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 8*sqSize, 8*sqSize)
                                   fromSq: s1
                                     toSq: s2];
   [lastMoveView setUserInteractionEnabled: NO];
   [lastMoveView setOpaque: NO];
   [self addSubview: lastMoveView];
}
//
//
- (void)hideLastMove {
   if (lastMoveView) {
      [lastMoveView removeFromSuperview];
      lastMoveView = nil;
   }
   fromSquare = SQ_NONE;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   if (fromSquare == SQ_NONE)
      [self hideLastMove];
   else {
      CGPoint pt = [[touches anyObject] locationInView: self];
      if ([self squareAtPoint: pt] == fromSquare) {
         [self stopHighlighting];
         [self hideLastMove];
      }
      else
         [self selectionMovedToPoint: pt];
   }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   if (fromSquare != SQ_NONE)
      [self selectionMovedToPoint: [[touches anyObject] locationInView: self]];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   if (fromSquare != SQ_NONE) {
      CGPoint pt = [[touches anyObject] locationInView: self];
      Square fSq = fromSquare, tSq = [self squareAtPoint: pt];
      [self hideLastMove];
      [self stopHighlighting];
      if ([gameController pieceCanMoveFrom: fSq to: tSq])
         [gameController animateMoveFrom: fSq to: tSq];
   }
   else {
      [self hideLastMove];
      [self stopHighlighting];
   }
   fromSquare = SQ_NONE;
}


- (void)pieceTouchedAtSquare:(Square)s {
   [self hideLastMove];
   [self showLastMoveWithFrom: s to: s]; // HACK
   fromSquare = s;
}
//
//
/// Clean up.

- (void)dealloc {
   [[NSNotificationCenter defaultCenter] removeObserver: self];
}


@end
