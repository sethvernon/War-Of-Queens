//
//  CRAppDelegate.m
//  Chess Revolt
//
//  Created by Administrator1 on 10/4/13.
//  Copyright (c) 2013 Chess Revold. All rights reserved.
//

#import "CRAppDelegate.h"
#import "TargetConditionals.h"
#import "Options.h"
#import "PGN.h"
#import "MoveListView.h"
#import "GameController.h"

#include <sys/stat.h>
#include "bitboard.h"
#include "direction.h"
#include "mersenne.h"
#include "Chess/movepick.h"
#include "Chess/position.h"


using namespace Chess;



@implementation CRAppDelegate

//@synthesize window, viewController, gameController;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [self initializeStoryBoardBasedOnScreenSize];
    
    return YES;
}

-(void)initializeStoryBoardBasedOnScreenSize
{
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {    // The iOS device = iPhone or iPod Touch
        
        
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 480)
        {   // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation: 3.5 inch screen (diagonally measured)
            
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            UIStoryboard *iPhone35Storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone 4" bundle:nil];
            
            // Instantiate the initial view controller object from the storyboard
            UIViewController *initialViewController = [iPhone35Storyboard instantiateInitialViewController];
            
            // Instantiate a UIWindow object and initialize it with the screen size of the iOS device
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            
            // Set the initial view controller to be the root view controller of the window object
            self.window.rootViewController  = initialViewController;
            
            [self.window makeKeyAndVisible];
            
        }
        
        if (iOSDeviceScreenSize.height == 568)
        {   // iPhone 5 and iPod Touch 5th generation: 4 inch screen (diagonally measured)
            
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone4
            UIStoryboard *iPhone5Storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            
            // Instantiate the initial view controller object from the storyboard
            UIViewController *initialViewController = [iPhone5Storyboard instantiateInitialViewController];
            
            // Instantiate a UIWindow object and initialize it with the screen size of the iOS device
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            
            // Set the initial view controller to be the root view controller of the window object
            self.window.rootViewController  = initialViewController;
            
            // Set the window object to be the key window and show it
            [self.window makeKeyAndVisible];
        }
    }
}


//{

    
    ///**** Storybaord initialization.. removed BoardViewController Alloc init. Seth 1/2/2014 ***///////
    ////// temporarily replaced it to try and run in code first...
    
    // Override point for customization after application launch.
//    NSLog(@"%@", PGN_DIRECTORY);      ////// testing seth 1.19.14
//	
//#if defined(TARGET_OS_IPHONE)
//    if (!Sandbox)
//        mkdir("/var/mobile/Library/abaia", 0755);
//#endif
//
//    viewController = [[BoardViewController alloc] init];
//   	[viewController loadView];
//   	[window addSubview: [viewController view]];
//    
//    
//    
//    
//    [window makeKeyAndVisible];
//	
//    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
//    
//    [self performSelectorInBackground: @selector(backgroundInit:)
//                           withObject: nil];
//    
//    
//    
//    return YES;
//}
//
//
//- (void)backgroundInit:(id)anObject
//
//{   //// removed for testing 1.19.14
//
//	gameController =
//	[[GameController alloc] initWithBoardView: [viewController boardView]
//								 moveListView: [viewController moveListView]
//								 analysisView: [viewController analysisView]
//								bookMovesView: [viewController bookMovesView]
//							   whiteClockView: [viewController whiteClockView]
//							   blackClockView: [viewController blackClockView]
//							  searchStatsView: [viewController searchStatsView]];
//    
//
//	/* Chess init */
//    init_mersenne();
//	init_direction_table();
//	init_bitboards();
//	Position::init_zobrist();
//	Position::init_piece_square_tables();
//	MovePicker::init_phase_table();
//
//	// Make random number generation less deterministic, for book moves
//	int i = abs(get_system_time() % 10000);
//	for (int j = 0; j < i; j++)
//		genrand_int32();
//    
//    [gameController loadPieceImages];
//	[self performSelectorOnMainThread: @selector(backgroundInitFinished:)
//						   withObject: nil
//						waitUntilDone: NO];
//}
//
//
//
//
//- (void)backgroundInitFinished:(id)anObject {
//    	[gameController showPiecesAnimate: YES];
//    	[viewController stopActivityIndicator];
//    
//    	[viewController setGameController: gameController];
//    	[[viewController boardView] setGameController: gameController];
//    	[[viewController moveListView] setGameController: gameController];
//    
//    	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    	NSString *lastGamePGNString = [defaults objectForKey: @"lastGame"];
//    	if (lastGamePGNString)
//    		[gameController gameFromPGNString: lastGamePGNString];
//    	else
//    		[gameController
//             gameFromFEN: @"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"];
//    
//    	int gameLevel = [defaults integerForKey: @"gameLevel"];
//    	if (gameLevel) {
//    		[[Options sharedOptions] setGameLevel: (GameLevel)(gameLevel - 1)];
//    		[gameController setGameLevel: [[Options sharedOptions] gameLevel]];
//    	}
//    
//    	int whiteRemainingTime = [defaults integerForKey: @"whiteRemainingTime"];
//    	int blackRemainingTime = [defaults integerForKey: @"blackRemainingTime"];
//    	ChessClock *clock = [[gameController game] clock];
//    	if (whiteRemainingTime)
//    		[clock addTimeForWhite: (whiteRemainingTime - [clock whiteRemainingTime])];
//    	if (blackRemainingTime)
//    		[clock addTimeForBlack: (blackRemainingTime - [clock blackRemainingTime])];
//    
//    	int gameMode = [defaults integerForKey: @"gameMode"];
//    	if (gameMode) {
//    		[[Options sharedOptions] setGameMode: (GameMode)(gameMode - 1)];
//    		[gameController setGameMode: [[Options sharedOptions] gameMode]];
//    	}
//    
//    	if ([defaults objectForKey: @"rotateBoard"])
//    		[gameController rotateBoard: [defaults boolForKey: @"rotateBoard"]];
//    
//    	[gameController startEngine];
//    	[gameController showBookMoves];
//}
//
//
//
//- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)encoder  /// added this but probably won't need this. /// Seth 1.17.14
//{
//    return YES;
//}
//
//- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)decoder
//{
//    return YES;
//}
//
//							
//
//- (void)applicationWillTerminate:(UIApplication *)application {
//	NSLog(@"GlaurungAppDelegate applicationWillTerminate:");
//	
//	// Save the current game, level and game mode so we can recover it the next
//	// time the program starts up:
//    	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    	[defaults setObject: [[gameController game] pgnString]
//    				 forKey: @"lastGame"];
//    	[defaults setInteger: ((int)[[Options sharedOptions] gameLevel] + 1)
//    				  forKey: @"gameLevel"];
//    	[defaults setInteger: ((int)[[Options sharedOptions] gameMode] + 1)
//                      forKey: @"gameMode"];
//    	[defaults setInteger: [[[gameController game] clock] whiteRemainingTime] + 1
//    				  forKey: @"whiteRemainingTime"];
//    	[defaults setInteger: [[[gameController game] clock] blackRemainingTime] + 1
//    				  forKey: @"blackRemainingTime"];
//    	[defaults setBool: [gameController rotated]
//    			   forKey: @"rotateBoard"];
//    	[defaults synchronize];
//
//}
//
//- (void)dealloc {
//	// removed dealloc
//       viewController = nil;
//       gameController = nil;
//       window = nil;
//	
//}
//
@end
