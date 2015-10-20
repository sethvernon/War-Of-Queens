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

#import "Options.h"
#import "QWViewController.h"   ///// sav 2.5.14

@interface Options()

@property (nonatomic, strong) QWViewController *qwController;
@property (nonatomic, readwrite) NSString *colorScheme;

@end

@implementation Options

@synthesize darkSquareColor, lightSquareColor, highlightColor;
@synthesize darkSquareImage, lightSquareImage;

@synthesize colorScheme = _colorScheme;  //// SAV 2.5.14

@dynamic  pieceSet, figurineNotation;
//@dynamic colorScheme, pieceSet, figurineNotation;
@dynamic playStyle, bookVariety, bookVarietyWasChanged, moveSound;
@dynamic showAnalysis, showBookMoves, showLegalMoves, permanentBrain;
@dynamic gameMode, gameLevel, gameModeWasChanged, gameLevelWasChanged;
@dynamic saveGameFile, emailAddress, fullUserName;
@dynamic displayMoveGestureStepForwardHint, displayMoveGestureTakebackHint;
@dynamic playStyleWasChanged, strength, strengthWasChanged;
@dynamic serverName, serverPort;



- (id)initWithGameName:(NSString *)gameName
{
    self.gameName = gameName;
    
    return [self init];
    
}

- (id)init {
   if (self = [super init]) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

      if (![defaults objectForKey: @"showAnalysis2"]) {
         showAnalysis = YES;
         [defaults setBool: YES forKey: @"showAnalysis2"];
      }
      else
         showAnalysis = [defaults boolForKey: @"showAnalysis2"];

      if (![defaults objectForKey: @"showBookMoves2"]) {
         showBookMoves = YES;
         [defaults setBool: YES forKey: @"showBookMoves2"];
      }
      else
         showBookMoves = [defaults boolForKey: @"showBookMoves2"];

      if (![defaults objectForKey: @"showLegalMoves2"]) {
         showLegalMoves = YES;
         [defaults setBool: YES forKey: @"showLegalMoves2"];
      }
      else
         showLegalMoves = [defaults boolForKey: @"showLegalMoves2"];

      if (![defaults objectForKey: @"permanentBrain2"]) {
         permanentBrain = NO;
         [defaults setBool: NO forKey: @"permanentBrain2"];
      }
      else
         permanentBrain = [defaults boolForKey: @"permanentBrain2"];

      pieceSet = [defaults objectForKey: @"pieceSet3"];
      if (!pieceSet) {
         // For some reason, I prefer the Leipzig pieces on the iPhone,
         // but Alpha on the iPad.
         if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            pieceSet = [NSString stringWithFormat: @"Alpha"];
            [defaults setObject: @"Alpha" forKey: @"pieceSet3"];
         }
         else {
            pieceSet = [NSString stringWithFormat: @"Alpha"];    /// sav 2.24.14
            [defaults setObject: @"Alpha" forKey: @"pieceSet3"];
         }
      }

      playStyle = [defaults objectForKey: @"playStyle2"];
      if (!playStyle) {
         playStyle = [NSString stringWithFormat: @"Active"];
         [defaults setObject: @"Active" forKey: @"playStyle2"];
      }

      bookVariety = [defaults objectForKey: @"bookVariety2"];
      if (!bookVariety) {
         bookVariety = [NSString stringWithFormat: @"Medium"];
         [defaults setObject: @"Medium" forKey: @"bookVariety2"];
      }

      if (![defaults objectForKey: @"moveSound"]) {
         moveSound = YES;
         [defaults setBool: YES forKey: @"moveSound"];
      }
      else
         moveSound = [defaults boolForKey: @"moveSound"];

      if (![defaults objectForKey: @"figurineNotation2"]) {
         figurineNotation = NO;
         [defaults setBool: NO forKey: @"figurineNotation2"];
      }
      else
         figurineNotation = [defaults boolForKey: @"figurineNotation2"];
       
      
       if(!self.gameName)                                                     //// mm 2.4.14
           self.colorScheme = [defaults objectForKey: @"colorScheme3"];
       
       else
#pragma This is how we changed the color schemes of the the baord. this is probably how we will need to change the pieces based on the game name.
           
       {
           if ([self.gameName isEqualToString:@"Queens War"]) self.colorScheme = @"Blue";
           if ([self.gameName isEqualToString:@"Close Combat"]) self.colorScheme = @"Wood";
           if ([self.gameName isEqualToString:@"Wild Squares"]) self.colorScheme = @"Red";
           if ([self.gameName isEqualToString:@"Dark Knights"]) self.colorScheme = @"Brown";
           if ([self.gameName isEqualToString:@"Lost Army"]) self.colorScheme = @"Green";
//           
          [defaults setObject: self.colorScheme forKey: @"colorScheme3"]; /// 2.5.14 sav 
          [defaults synchronize];
        }
           
       if (!self.colorScheme)
		   {
		   self.colorScheme = [NSString stringWithFormat: @"Gray"];
		   [defaults setObject: @"Green" forKey: @"colorScheme3"];
		   }
       
#pragma SET DEFAULT GAME LEVEL
       
//      darkSquareColor = lightSquareColor = highlightColor = nil;    sav 2.6.14
      [self updateColors];

      gameMode = GAME_MODE_COMPUTER_BLACK;
      gameLevel = LEVEL_GAME_IN_5_PLUS_2;
       strength = 1300; /// SAV 4.11.14
      gameModeWasChanged = NO;
      gameLevelWasChanged = NO;
      playStyleWasChanged = NO;
      strengthWasChanged = NO;

      saveGameFile = [defaults objectForKey: @"saveGameFile2"];
      if (!saveGameFile) {
         saveGameFile = [NSString stringWithFormat: @"My games.pgn"];
         [defaults setObject: @"My Games.pgn" forKey: @"saveGameFile2"];
      }

      emailAddress = [defaults objectForKey: @"emailAddress2"];
      if (!emailAddress) {
         emailAddress = [NSString stringWithFormat: @""];
         [defaults setObject: @"" forKey: @"emailAddress2"];
      }
      fullUserName = [defaults objectForKey: @"fullUserName2"];
      if (!fullUserName) {
         fullUserName = [NSString stringWithFormat: @"Me"];
         [defaults setObject: @"Me" forKey: @"fullUserName2"];
      }

      strength = [defaults integerForKey: @"Elo3"]; // sav 4.8.14
       if (!strength) {
         strength = 1300;
         [defaults setInteger: 1300 forKey: @"Elo3"]; ///2500
         [defaults synchronize];
       }

      NSString *tmp = [defaults objectForKey: @"displayMoveGestureTakebackHint2"];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: @"displayMoveGestureTakebackHint2"];
         displayMoveGestureTakebackHint = YES;
      }
      else if ([tmp isEqualToString: @"YES"])
         displayMoveGestureTakebackHint = YES;
      else
         displayMoveGestureTakebackHint = NO;

      tmp = [defaults objectForKey: @"displayMoveGestureStepForwardHint2"];
      if (!tmp) {
         [defaults setObject: @"YES"
                      forKey: @"displayMoveGestureStepForwardHint2"];
         displayMoveGestureStepForwardHint = YES;
      }
      else if ([tmp isEqualToString: @"YES"])
         displayMoveGestureStepForwardHint = YES;
      else
         displayMoveGestureStepForwardHint = NO;

      serverName = [defaults objectForKey: @"serverName2"];
      if (!serverName) {
         serverName = [NSString stringWithFormat: @""];
         [defaults setObject: @"" forKey: @"serverName2"];
      }

      serverPort = [defaults integerForKey: @"serverPort2"];
      if (!serverPort) {
         serverPort = 1685;
         [defaults setInteger: 1685 forKey: @"serverPort2"];
      }

      [defaults synchronize];
   }
   return self;
}

- (void)setColorScheme:(NSString *)newColorScheme {
    
	_colorScheme = newColorScheme;                                    // mm 2.5.14

	[[NSUserDefaults standardUserDefaults] setObject: newColorScheme
                                              forKey: @"colorScheme3"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter]             //   sav 2.24.14
     postNotificationName: @"StockfishPieceSetChanged"
     object: self];
	
	
	
	
	
    [self updateColors];
}

- (void)updateColors
{
    
//    darkSquareImage = nil;    sav 2.6.14
//    lightSquareImage = nil;
    
	if ([self.colorScheme isEqualToString: @"Blue"])
	{

        darkSquareColor = [UIColor colorWithRed: 0.20
										  green: 0.40
										   blue: 0.70
                                          alpha: 1.0];
        
        lightSquareColor = [UIColor colorWithRed: 0.69
										   green: 0.78
											blue: 1.0
                                           alpha: 1.0];
        
        highlightColor = [UIColor purpleColor];
    }
    else if ([self.colorScheme isEqualToString: @"Gray"]) {
        darkSquareColor = [UIColor colorWithRed: 0.5
										  green: 0.5
										   blue: 0.5
                                          alpha: 1.0];
        
        lightSquareColor = [UIColor colorWithRed: 0.8
										   green: 0.8
											blue: 0.8
                                           alpha: 1.0];
        
        highlightColor = [UIColor blueColor];
    }
    else if ([self.colorScheme isEqualToString: @"Green"]) {
        darkSquareColor = [UIColor colorWithRed: 0.57
										  green: 0.40
										   blue: 0.35
                                          alpha: 1.0];
        
        lightSquareColor = [UIColor colorWithRed: 0.9
										   green: 0.8
											blue: 0.7
                                           alpha: 1.0];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            darkSquareImage = [UIImage imageNamed: @"DarkGreenMarble96.png"];
            lightSquareImage = [UIImage imageNamed: @"LightGreenMarble96.png"];
            highlightColor = [UIColor blueColor];
        }
        else {
            darkSquareImage = [UIImage imageNamed: @"DarkGreenMarble.png"];
            lightSquareImage = [UIImage imageNamed: @"LightGreenMarble.png"];
            highlightColor = [UIColor blueColor];
        }
    }
    else if ([self.colorScheme isEqualToString: @"Brown"]) {
        darkSquareColor = [UIColor colorWithRed:0.65  // 0.38
										  green:0.45 // 0.28
										   blue:0.4// 0.28
                                          alpha:1.0];
        
        lightSquareColor = [UIColor colorWithRed: 0.92
										   green: 0.86
											blue: 0.76
                                           alpha: 1.0];
        highlightColor = [UIColor blueColor];
    }
    else if ([self.colorScheme isEqualToString: @"Red"]) {
        darkSquareColor = [UIColor colorWithRed: 0.6
										  green: 0.28
										   blue: 0.28
                                          alpha: 1.0];
        
        lightSquareColor = [UIColor colorWithRed: 0.8     // 1.0
										   green: 0.7		  // 0.8
											blue: 0.7	  //0.8
                                           alpha: 1.0];
        highlightColor = [UIColor blueColor];
    }
    else if ([self.colorScheme isEqualToString: @"Wood"]) {
        darkSquareColor = [UIColor colorWithRed: 0.57
										  green: 0.40
										   blue: 0.35
                                          alpha: 1.0];
        
        lightSquareColor = [UIColor colorWithRed: 0.9
										   green: 0.8
											blue: 0.7
                                           alpha: 1.0];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            darkSquareImage = [UIImage imageNamed: @"DarkWood96.png"];
            lightSquareImage = [UIImage imageNamed: @"LightWood96.png"];
            highlightColor = [UIColor blueColor];
        }
        else {
            darkSquareImage = [UIImage imageNamed: @"DarkWood.png"];
            lightSquareImage = [UIImage imageNamed: @"LightWood.png"];
            highlightColor = [UIColor blueColor];
        }
    }
    else if ([self.colorScheme isEqualToString: @"Marble"]) {
        darkSquareColor = [UIColor colorWithRed: 0.57 green: 0.40 blue: 0.35
                                          alpha: 1.0];
        
        lightSquareColor = [UIColor colorWithRed: 0.9 green: 0.8 blue: 0.7
                                           alpha: 1.0];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            darkSquareImage = [UIImage imageNamed: @"DarkMarble96.png"];
            lightSquareImage = [UIImage imageNamed: @"LightMarble96.png"];
            highlightColor = [UIColor blueColor];
        }
        else {
            darkSquareImage = [UIImage imageNamed: @"DarkMarble.png"];
            lightSquareImage = [UIImage imageNamed: @"LightMarble.png"];
            highlightColor = [UIColor blueColor];
        }
    }
    else { // Default brown color scheme

        
//        darkSquareColor = [UIColor colorWithRed: 0.57 green: 0.40 blue: 0.35
//                                          alpha: 1.0];
//        
//        lightSquareColor = [UIColor colorWithRed: 0.9 green: 0.8 blue: 0.7
//                                           alpha: 1.0];
//        highlightColor = [UIColor blueColor];
        
        

    }
    // Post a notification about the new colors, in order to make the board
    // update itself:
    [[NSNotificationCenter defaultCenter]
     postNotificationName: @"StockfishColorSchemeChanged"
     object: self];
}




//- (NSString *)colorScheme {        mm 2.5.14
//   
//    return self.colorScheme;
//}

- (BOOL)figurineNotation {
   return figurineNotation;
}


- (void)setFigurineNotation:(BOOL)newValue {
   figurineNotation = newValue;
   [[NSUserDefaults standardUserDefaults] setBool: figurineNotation
                                           forKey: @"figurineNotation2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)moveSound {
   return moveSound;
}


- (void)setMoveSound:(BOOL)newValue {
   moveSound = newValue;
   [[NSUserDefaults standardUserDefaults] setBool: moveSound
                                           forKey: @"moveSound"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)pieceSet {
   return pieceSet;
}


- (void)setPieceSet:(NSString *)newPieceSet {

   pieceSet = newPieceSet;
    
   newPieceSet = @"Alpha";
//   [[NSUserDefaults standardUserDefaults] setObject: newPieceSet
//                                             forKey: @"pieceSet3"];
//   [[NSUserDefaults standardUserDefaults] synchronize];
//   [[NSNotificationCenter defaultCenter]
//      postNotificationName: @"StockfishPieceSetChanged"
//                    object: self];
}


- (NSString *)playStyle {
   return playStyle;
}


- (void)setPlayStyle:(NSString *)newPlayStyle {
    
    playStyle = newPlayStyle;
   playStyleWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setObject: newPlayStyle
                                             forKey: @"playStyle2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)playStyleWasChanged {
   BOOL result = playStyleWasChanged;
   playStyleWasChanged = NO;
   return result;
}


- (NSString *)bookVariety {
   return bookVariety;
}


- (void)setBookVariety:(NSString *)newBookVariety {
    bookVariety = newBookVariety;
   bookVarietyWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setObject: newBookVariety
                                             forKey: @"bookVariety2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)bookVarietyWasChanged {
   BOOL result = bookVarietyWasChanged;
   bookVarietyWasChanged = NO;
   return result;
}


- (BOOL)showAnalysis {
   return showAnalysis;
}


- (void)setShowAnalysis:(BOOL)shouldShowAnalysis {
   showAnalysis = shouldShowAnalysis;
   [[NSUserDefaults standardUserDefaults] setBool: showAnalysis
                                           forKey: @"showAnalysis2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showBookMoves {
   return showBookMoves;
}


- (void)setShowBookMoves:(BOOL)shouldShowBookMoves {
   showBookMoves = shouldShowBookMoves;
   [[NSUserDefaults standardUserDefaults] setBool: showBookMoves
                                           forKey: @"showBookMoves2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)showLegalMoves {
   return showLegalMoves;
}


- (void)setShowLegalMoves:(BOOL)shouldShowLegalMoves {
   showLegalMoves = shouldShowLegalMoves;
   [[NSUserDefaults standardUserDefaults] setBool: showLegalMoves
                                           forKey: @"showLegalMoves2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)permanentBrain {
   return permanentBrain;
}


- (void)setPermanentBrain:(BOOL)shouldUsePermanentBrain {
   permanentBrain = shouldUsePermanentBrain;
   [[NSUserDefaults standardUserDefaults] setBool: permanentBrain
                                           forKey: @"permanentBrain2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)dealloc {
 }


+ (Options *)sharedOptions
{
   static Options *o = nil;
   if (o == nil) {
      o = [[Options alloc] init];
   }
   return o;
}


- (GameLevel)gameLevel {
    
   return gameLevel;
}


- (void)setGameLevel:(GameLevel)newGameLevel {
   gameLevel = newGameLevel;
   gameLevelWasChanged = YES;
}

- (GameMode)gameMode {
   return gameMode;
}


- (void)setGameMode:(GameMode)newGameMode {
   gameMode = newGameMode;
   gameModeWasChanged = YES;
}


- (BOOL)gameModeWasChanged {
   BOOL result = gameModeWasChanged;
   gameModeWasChanged = NO;
   return result;
}


- (BOOL)gameLevelWasChanged {
   BOOL result = gameLevelWasChanged;
   gameLevelWasChanged = NO;
   return result;
}


- (NSString *)saveGameFile {
   return saveGameFile;
}


- (void)setSaveGameFile:(NSString *)newFileName {
  // saveGameFile;
   saveGameFile = newFileName;
   [[NSUserDefaults standardUserDefaults] setObject: saveGameFile
                                             forKey: @"saveGameFile2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)emailAddress {
   return emailAddress;
}


- (void)setEmailAddress:(NSString *)newEmailAddress {
  // [emailAddress ];
   emailAddress = newEmailAddress;
   [[NSUserDefaults standardUserDefaults] setObject: emailAddress
                                             forKey: @"emailAddress2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (NSString *)fullUserName {
   return fullUserName;
}


- (void)setFullUserName:(NSString *)name {
 //  [fullUserName ];
   fullUserName = name;
   [[NSUserDefaults standardUserDefaults] setObject: fullUserName
                                             forKey: @"fullUserName2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (int)strength {
   return strength;
}

#pragma This is the strength setter...
- (void)setStrength:(int)newStrength
{
   strength = newStrength;
    newStrength = 1300;
//   strengthWasChanged = YES;
   [[NSUserDefaults standardUserDefaults] setInteger: newStrength
                                              forKey: @"Elo3"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)strengthWasChanged
{
   BOOL result = strengthWasChanged;
   strengthWasChanged = NO;
   return result;
}


- (BOOL)displayMoveGestureTakebackHint {
   BOOL tmp = displayMoveGestureTakebackHint;
   displayMoveGestureTakebackHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: @"displayMoveGestureTakebackHint2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


- (BOOL)displayMoveGestureStepForwardHint {
   BOOL tmp = displayMoveGestureStepForwardHint;
   displayMoveGestureStepForwardHint = NO;
   [[NSUserDefaults standardUserDefaults] setObject: @"NO"
                                             forKey: @"displayMoveGestureStepForwardHint2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
   return tmp;
}


static const BOOL FixedTime[13] = {
   NO, NO, NO, NO, NO, NO, NO, NO, YES, YES, YES, YES, YES
};
static const int LevelTime[13] = {
   2, 2, 5, 5, 15, 15, 30, 30, 0, 0, 0, 0, 0
};
static const int LevelIncr[13] = {
   0, 1, 0, 2, 0, 5, 0, 5, 1, 2, 5, 10, 30
};

- (BOOL)isFixedTimeLevel {
   assert(gameLevel < 13);
   return FixedTime[gameLevel];
}

- (int)baseTime {
   assert(gameLevel < 13);
   return LevelTime[gameLevel] * 60000;
}

- (int)timeIncrement {
   assert(gameLevel < 13);
   return LevelIncr[gameLevel] * 1000;
}

- (NSString *)serverName {
   return serverName;
}

- (void)setServerName:(NSString *)newServerName {
  // [serverName ];
   serverName = newServerName;
   [[NSUserDefaults standardUserDefaults] setObject: serverName
                                             forKey: @"serverName2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (int)serverPort {
   return serverPort;
}

- (void)setServerPort:(int)newPort {
   serverPort = newPort;
   [[NSUserDefaults standardUserDefaults] setInteger: serverPort
                                              forKey: @"serverPort2"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
