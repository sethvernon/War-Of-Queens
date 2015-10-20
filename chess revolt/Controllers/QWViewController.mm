//
//  QWViewController.m
//  Chess Revolt
//
//  Created by Seth Vernon on 2/3/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

#import "QWViewController.h"
#import "EngineController.h"
#import "LastMoveView.h"
#import "GameDetailsTableController.h"
#import "BoardViewController.h"

#import "PieceImageView.h"
#import "PGN.h"
#import "RemoteEngineController.h"
#import "TargetConditionals.h"
#import "OptionsViewController.h"
#import "ChessClock.h"
#import "EngineController.h"
#import "LevelViewController.h"
#import "AboutTableViewController.h"
#import "AboutViewController.h"

#include <sys/stat.h>
#include "bitboard.h"
#include "direction.h"
#include "mersenne.h"
#include "movepick.h"
#include "position.h"
#include "misc.h"
#include "mersenne.h"
#include "movepick.h"

using namespace Chess;

@interface QWViewController ()
@property (nonatomic, strong)Options *qwOptions;   /// sav 2.3.14
@property (nonatomic, strong)GameDetailsTableController *qwGameDetailsVC;
@property (nonatomic, strong)UIBarButtonItem *gameButton, *optionsButton;
@property (nonatomic, strong)UIActionSheet *gameMenu, *startGameMenu, *moveMenu; /// SAV 3.13.14 changed newGameMenu to start
@property (nonatomic, strong)UIPopoverController *optionsMenu, *saveMenu, *emailMenu, *levelsMenu, *loadMenu, *aboutMenu;
@property (nonatomic, strong)UIPopoverController *popoverMenu;
@property (nonatomic, strong)RootView *rootView;
@property (nonatomic, strong)OptionsViewController *qwOVC;
@property (nonatomic, strong)LevelViewController *qwLevelViewController;
@property (nonatomic, strong)AboutTableViewController *aboutTableViewController;
@property (nonatomic, strong)AboutViewController *aboutViewController;

@property (nonatomic, strong)UINavigationController *qwNC;
@property (nonatomic, strong)UINavigationController *qwSaveGameNC;
@property (nonatomic, strong)UINavigationController *qwGameOptionsNavigationController;
@property (nonatomic, strong)UINavigationController *qwAboutNavigationController;

@property (nonatomic, strong)ChessClock *clock;
@property (weak, nonatomic) IBOutlet UILabel *whiteClockView;
@property (weak, nonatomic) IBOutlet UILabel *blackClockView;

@property (nonatomic)Square pendingTo, pendingFrom;
@property (nonatomic, readwrite) BOOL engineIsPlaying;
@property (nonatomic, strong)NSMutableArray *pieceViews;
@property (nonatomic, strong)EngineController * engineController;
@property (nonatomic, strong)RemoteEngineController *remoteEngineController;
@property (nonatomic, readonly) BOOL *rotated;

@property (nonatomic, strong) NSTimer *foo;
@property (nonatomic, strong) UIImageView *whatEverIWant;
@property (nonatomic) int imageNumber;

@property (weak, nonatomic) IBOutlet UIImageView *closeCombat;
@property (weak, nonatomic) IBOutlet UIImageView *darkKnights;
@property (weak, nonatomic) IBOutlet UIImageView *wildSquares;



@end

@implementation QWViewController


- (BoardView *)boardView
{
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
   {
        CGRect iPad = CGRectMake(8, 74, 640, 640);
        if (! _boardView ) _boardView = [[BoardView alloc]initWithFrame:iPad GameName:@"Queens War"];
        return _boardView ;
   }
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        
    {
        
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if (iOSDeviceScreenSize.height == 568)
        {
            
            CGRect iPhone = CGRectMake(0, 148, 320, 320); //146
            if (! _boardView ) _boardView = [[BoardView alloc]initWithFrame:iPhone GameName:@"Queens War"];
            return _boardView ;
        }
        
        if (iOSDeviceScreenSize.height == 480)
        {
            CGRect iPhone4 = CGRectMake(0, 82, 320, 320); // 320
            if (!_boardView)
                _boardView = [[BoardView alloc]initWithFrame:iPhone4 GameName:@"Queens War"];
            
        }
    }
    return _boardView;
    
}

//- (BoardView *)boardView
//{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        CGRect iPad = CGRectMake(8, 74, 640, 640); //8, 74, 686, 686
//        if (! _boardView ) _boardView = [[BoardView alloc]initWithFrame:iPad GameName:@"Dark Knights"];
//        return _boardView ;
//    }
//    //    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//        
//    {
//        
//        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
//        if (iOSDeviceScreenSize.height == 568)
//        {
//            
//            CGRect iPhone = CGRectMake(0, 146, 320, 320); //146
//            if (! _boardView ) _boardView = [[BoardView alloc]initWithFrame:iPhone GameName:@"Dark Knights"];
//            return _boardView ;
//        }
//        
//        if (iOSDeviceScreenSize.height == 480)
//        {
//            CGRect iPhone4 = CGRectMake(0, 82, 320, 320); // 320
//            if (!_boardView)
//                _boardView = [[BoardView alloc]initWithFrame:iPhone4 GameName:@"Dark Knights"];
//            
//        }
//        
//    }
//    return _boardView;
//    
//    
//    
//}

- (BoardViewController *)boardViewController
{
    if (! _boardViewController ) _boardViewController = [[BoardViewController alloc]initWithGameName:@"Queens War"];
    return _boardViewController ;
}
- (GameController *)gameController
{
    if (!_gameController)
        _gameController = [[GameController alloc] initWithGameName:@"Qweens War"];
    return _gameController;
}
- (Game *)game
{
    if (! _qwGame) _qwGame = [[Game alloc] init];
    return _qwGame;
}
- (PieceImageView *)piv
{
    if (!_piv)
        _piv = [[PieceImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,40 , 40)];
    return _piv ;
}
- (Options *)qwOptions    ///// sav 2.3.14
{
    if (!_qwOptions)
        _qwOptions = [[Options alloc] initWithGameName:@"Queens War"];
    return _qwOptions;
}

- (GameDetailsTableController *)qwGameDetailsVC  // sav 3.20.14
{
    if (!_qwGameDetailsVC)
        _qwGameDetailsVC = [[GameDetailsTableController alloc] initWithBoardViewController:self.boardViewController
                                                                                      game:self.qwGame
                                                                                     email:NO];
    return _qwGameDetailsVC;
}

- (OptionsViewController *)qwOVC
{
    if (!_qwOVC)
        _qwOVC = [[OptionsViewController alloc] init];
    return _qwOVC;
}

- (UINavigationController *)qwNC
{
    if (!_qwNC)
        _qwNC = [[UINavigationController alloc] initWithRootViewController:self.qwOVC];
    return _qwNC;
}

- (UINavigationController *)qwSaveGameNC
{
    if (!_qwSaveGameNC)
        _qwSaveGameNC = [[UINavigationController alloc] initWithRootViewController:self.qwGameDetailsVC];
    return _qwSaveGameNC;
}

- (LevelViewController *)qwLevelViewController
{
    if (!_qwLevelViewController)
        _qwLevelViewController = [[LevelViewController alloc] init];
    return _qwLevelViewController;
    
}

- (UINavigationController *)qwGameOptionsNavigationController
{
    if (!_qwGameOptionsNavigationController)
        _qwGameOptionsNavigationController = [[UINavigationController alloc] initWithRootViewController:self.qwLevelViewController];
    return _qwGameOptionsNavigationController;
}

- (UINavigationController *)qwAboutNavigationController
{
        if (!_qwAboutNavigationController)
            _qwAboutNavigationController = [[UINavigationController alloc] initWithRootViewController:self.aboutViewController];
        return _qwAboutNavigationController;
}

- (void)awakeFromNib
{
    [self setup];
    [self updateUI];
}
- (void)setup
{
    NSLog(@"%@", PGN_DIRECTORY);
	
#if defined(TARGET_OS_IPHONE)
    if (!Sandbox)
        mkdir("/var/mobile/Library/abaia", 0755);
#endif
    
//    [self.boardViewController loadView];   ////  SAV resololved subview issue... 2.6.14
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    [self performSelectorInBackground: @selector(backgroundInit:)
                           withObject: nil];
    
    
}
- (void)backgroundInit:(id)anObject {
    
	
    self.gameController =
    
    [[GameController alloc] initWithBoardView: [self boardView]
								 moveListView: [self moveListView]
								 analysisView: [self analysisView]
								bookMovesView: [self bookMovesView]
							   whiteClockView: [self whiteClockView]
							   blackClockView: [self blackClockView]
							  searchStatsView: [self searchStatsView]];
    
    
    [self.view addSubview: self.boardView];
    
	/* Chess init */
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
    
	[self.gameController loadPieceImages];
	[self performSelectorOnMainThread: @selector(backgroundInitFinished:)
						   withObject: nil
						waitUntilDone: NO];
    [self animateIcons];

}

- (void)backgroundInitFinished:(id)anObject {
    [self.gameController showPiecesAnimate: YES];
    [self.boardViewController stopActivityIndicator];
    
    [self setGameController: self.gameController];
    [[self.boardViewController boardView] setGameController: self.gameController];
    [[self.boardViewController moveListView] setGameController: self.gameController];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    NSString *lastGamePGNString = [defaults objectForKey: @"lastGame"];     //// sav 2.5.14
    if (lastGamePGNString)
        [self.gameController gameFromPGNString: lastGamePGNString];
    else
        [self.gameController
         gameFromFEN: @"r3k2r/1nqqqqn1/pppppppp/8/8/PPPPPPPP/1NQQQQN1/R3K2R w KQkq - 0 1"];   /// sav positions... 2.20.14
    
        
    int gameLevel = [defaults integerForKey: @"gameLevel"];
       //// changed in to NSINteger SAV 2.6.14
    if (gameLevel) {
        
        gameLevel = 1300;
//        [[Options sharedOptions] setGameLevel: (GameLevel)(gameLevel - 1)];   /// trying to override options
//        [self.gameController setGameLevel: [[Options sharedOptions] gameLevel]];
    }
    int whiteRemainingTime = [defaults integerForKey: @"whiteRemainingTime"];
    int blackRemainingTime = [defaults integerForKey: @"blackRemainingTime"];
    
//    ChessClock *clock = [[self.gameController game] clock];  // sav 3.20.14

    self.clock = [[self.gameController game] clock];
    
    if (whiteRemainingTime)
        [self.clock addTimeForWhite: (whiteRemainingTime - [self.clock whiteRemainingTime])];
    if (blackRemainingTime)
        [self.clock addTimeForBlack: (blackRemainingTime - [self.clock blackRemainingTime])];
    
    int gameMode = [defaults integerForKey: @"gameMode"];  ////////   *** SAV 2.6.14
    if (gameMode) {
        [self.qwOptions setGameMode: (GameMode)(gameMode - 1)];   //// trying to override options
        [self.gameController setGameMode: [[Options sharedOptions] gameMode]];
    } else
    {
        NSLog(@"%@",self.qwOptions );
       
    }
    
    if ([defaults objectForKey: @"rotateBoard"])
        [self.gameController rotateBoard: [defaults boolForKey: @"rotateBoard"]];
    
    [self.gameController startEngine];

    
//    int strength = [defaults integerForKey:@"Elo3"];
//    if (!strength) {
//            strength = 1300;
//        [defaults setInteger: 1300 forKey: @"Elo3"];
////        [self.qwOptions setStrength:strength];
    
        
        
//       [defaults synchronize];
    
        
    
    
//    [self.gameController showBookMoves]; sav removed this 3.21.14
    
//    [self startNewGame];

//    [self updateUI]; ////// sav 2.5.14
}

- (void)updateUI
{
//    [self.gameController takeBackAllMoves]; /// sav 3.20.14
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.foo = [NSTimer scheduledTimerWithTimeInterval:15
                
                                                target:self
                                              selector:@selector(animateIcons)
                                              userInfo:nil
                                               repeats:YES];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        UIToolbar *toolbar =
        [[UIToolbar alloc]
         initWithFrame: CGRectMake(0.0f, 20.0f, 320.0f, 44.0f)];
        [self.view addSubview: toolbar];
        [toolbar setAutoresizingMask: UIViewAutoresizingFlexibleWidth];
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        UIBarButtonItem *button;
        
        button = [[UIBarButtonItem alloc] initWithTitle: @"Game"
                                                  style: UIBarButtonItemStyleBordered
                                                 target: self
                                                 action: @selector(toolbarButtonPressed:)];
        [button setWidth: 84.0f];
        [buttons addObject: button];
        self.gameButton = button;
        
        button = [[UIBarButtonItem alloc] initWithTitle: @"Options"
                                                  style: UIBarButtonItemStyleBordered
                                                 target: self
                                                 action: @selector(toolbarButtonPressed:)];
        [button setWidth: 84.0f];
        [buttons addObject: button];
        self.optionsButton = button;
        
        button = [[UIBarButtonItem alloc] initWithTitle: @"Flip"
                                                  style: UIBarButtonItemStyleBordered
                                                 target: self
                                                 action: @selector(toolbarButtonPressed:)];
        [button setWidth: 64.0f];
        [buttons addObject: button];
        
        button = [[UIBarButtonItem alloc] initWithTitle: @"Move"
                                                  style: UIBarButtonItemStyleBordered
                                                 target: self
                                                 action: @selector(toolbarButtonPressed:)];
        [button setWidth: 64.0f];
        [buttons addObject: button];
        
        button = [[UIBarButtonItem alloc] initWithTitle: @"Hint"
                                                  style: UIBarButtonItemStyleBordered
                                                 target: self
                                                 action: @selector(toolbarButtonPressed:)];
        [button setWidth: 64.0f];
        [buttons addObject: button];
        
        [toolbar setItems: buttons animated: YES];
        [toolbar sizeToFit];
        
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if (iOSDeviceScreenSize.height == 568)
        {
            // Toolbar
            UIToolbar *toolbar =
            [[UIToolbar alloc]
             initWithFrame: CGRectMake(0, 527, 320, 40)]; // 0.0f, 480.0f-64.0f, 320.0f, 64.0f
            [self.view addSubview: toolbar];
            
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            UIBarButtonItem *button;
            
            button = [[UIBarButtonItem alloc] initWithTitle: @"Game"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth: 58.0f];
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Options"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Flip"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth: 34.0f];
            
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Move"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth: 53.0f];
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Hint"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth: 29.0f];
            [buttons addObject: button];
            
            [toolbar setItems: buttons animated: YES];
            [toolbar sizeToFit];
            
        } else if (iOSDeviceScreenSize.height == 480)
            
        {
            UIToolbar *toolbar =
            [[UIToolbar alloc]
             initWithFrame: CGRectMake(0, 444, 320, 40)]; // 0.0f, 480.0f-64.0f, 320.0f, 64.0f//0, 449, 320, 40
            [self.view addSubview: toolbar];
            
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            UIBarButtonItem *button;
            
            button = [[UIBarButtonItem alloc] initWithTitle: @"Game"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth: 58.0f];
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Options"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            //[button setWidth: 60.0f];
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Flip"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth:34.0f];
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Move"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth: 53.0f];
            [buttons addObject: button];
            button = [[UIBarButtonItem alloc] initWithTitle: @"Hint"
                                                      style: UIBarButtonItemStyleBordered
                                                     target: self
                                                     action: @selector(toolbarButtonPressed:)];
            [button setWidth: 29.0f];
            [buttons addObject: button];
            
            [toolbar setItems: buttons animated: YES];
            [toolbar sizeToFit];
            
        }
    }
        
        self.gameMenu = [[UIActionSheet alloc] initWithTitle: @"Game"
                                                    delegate: self
                                           cancelButtonTitle: @"Cancel"
                                      destructiveButtonTitle: nil
                                           otherButtonTitles: @"New game", @"Game Options", @"About", @"Cancel", nil];
        
        
        //// Or add an alert view etc ... sav 3.21.14
        // @"E-mail game", @"Delete",@"Cancel", nil]; @"Save game", @"Load game", @"Cancel"
        
        
        
        self.startGameMenu = [[UIActionSheet alloc] initWithTitle: nil
                                                         delegate: self
                                                cancelButtonTitle: @"Cancel"
                                           destructiveButtonTitle: nil
                                                otherButtonTitles:
                              @"Play white", @"Play black", nil]; //@"Play both", @"Analysis",
        self.moveMenu = [[UIActionSheet alloc] initWithTitle: nil
                                                    delegate: self
                                           cancelButtonTitle: @"Cancel"
                                      destructiveButtonTitle: nil
                                           otherButtonTitles:
                         @"Take back", @"Step forward", @"Take back all", @"Step forward all", @"Move now",@"Cancel", nil];
        
        NSLog(@"ActionSheets loaded");
        

    
}

- (IBAction)closeCombat:(UITapGestureRecognizer *)sender
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    self.closeCombat.layer.zPosition = 100;
    self.closeCombat.layer.doubleSided = YES;
    
    self.closeCombat.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CATransform3D transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    transform.m41 = 5.0/1000.0;
    
    [animation setToValue:[NSValue valueWithCATransform3D:transform]];
    [animation setDuration:.2]; //5
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setRemovedOnCompletion:YES];
    [animation setDelegate:self];
    animation.repeatCount = 6;
    animation.cumulative = YES;
    
    [self.closeCombat.layer addAnimation:animation forKey:@"transform"];
    
    NSString *AppLink = @"https://itunes.apple.com/us/app/chess-revolt-close-combat/id873392874?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppLink]];
}
- (IBAction)darkKnights:(UITapGestureRecognizer *)sender
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    self.darkKnights.layer.zPosition = 100;
    self.darkKnights.layer.doubleSided = YES;
    
    self.darkKnights.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CATransform3D transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    transform.m41 = 5.0/1000.0;
    
    [animation setToValue:[NSValue valueWithCATransform3D:transform]];
    [animation setDuration:.2]; //5
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setRemovedOnCompletion:YES];
    [animation setDelegate:self];
    animation.repeatCount = 6;
    animation.cumulative = YES;
    
    [self.darkKnights.layer addAnimation:animation forKey:@"transform"];
    
    NSString *AppLink = @"https://itunes.apple.com/us/app/chess-revolt-dark-knights/id877156290?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppLink]];
}
- (IBAction)wildSquares:(UITapGestureRecognizer *)sender
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    self.wildSquares.layer.zPosition = 100;
    self.wildSquares.layer.doubleSided = YES;
    
    self.wildSquares.layer.anchorPoint = CGPointMake(0.5, 0.5);
    CATransform3D transform = CATransform3DMakeRotation(M_PI, 1, 0, 0);
    transform.m41 = 5.0/1000.0;
    
    [animation setToValue:[NSValue valueWithCATransform3D:transform]];
    [animation setDuration:.2]; //5
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFillMode:kCAFillModeBoth];
    [animation setRemovedOnCompletion:YES];
    [animation setDelegate:self];
    animation.repeatCount = 6;
    animation.cumulative = YES;
    
    [self.wildSquares.layer addAnimation:animation forKey:@"transform"];
    
    NSString *AppLink = @"https://itunes.apple.com/us/app/chess-revolt-wild-squares/idQ2N35F35FC?mt=8";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppLink]];
}

- (void)animateIcons
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        NSArray *iconArray = @[self.darkKnights, self.wildSquares, self.closeCombat];
        self.imageNumber ++;
        if (self.imageNumber > [iconArray count]-1) self.imageNumber = 0; //-1
        self.whatEverIWant = [iconArray objectAtIndex:self.imageNumber];

        /// Flip Chess Revolt icons
        self.closeCombat.layer.zPosition = 100;
        self.closeCombat.layer.doubleSided = YES;
        
        //    [self.darkKnightsIcon.layer addSublayer:self.backIcon.layer];
        self.wildSquares.layer.zPosition = 100;
        self.wildSquares.layer.doubleSided = YES;
        
        self.darkKnights.layer.zPosition = 100;
        self.darkKnights.layer.doubleSided = YES;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
        CATransform3D transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        
        transform.m34 = 5.0/1000.0;
        [animation setToValue:[NSValue valueWithCATransform3D:transform]];
        [animation setDuration:3]; //5
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        //    [animation setFillMode:kCAFillModeBoth];
        [animation setRemovedOnCompletion:YES];
        //    [animation setDelegate:self];
        animation.repeatCount = 5;
        animation.cumulative = NO;
        
        
        [self.whatEverIWant.layer addAnimation:animation
                                        forKey:@"transform"];
    }
    
}

/// The Action Sheet is how Target Action Objects Were called ///

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[alertView title] isEqualToString: @"Start new game?"]) {
        if (buttonIndex == 1)
            [self startNewGame];
    }
    
    
    else if ([[alertView title] isEqualToString:
              @"Exit Chess Revolt and send e-mail?"]) {
        if (buttonIndex == 1)
            [[UIApplication sharedApplication]
             openURL: [[NSURL alloc] initWithString:
                       [self.gameController emailPgnString]]];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [actionSheet title];
    
    NSLog(@"Menu: %@ selection: %d", title, buttonIndex);
    
    if (actionSheet == self.gameMenu || [title isEqualToString: @"Game"]) {
        UIActionSheet *menu;
        switch(buttonIndex) {
            case 0:
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                    [self.startGameMenu showFromBarButtonItem: self.gameButton animated: YES];
                
                
                /// sav 3.13.14
         else {
                    menu =
                    [[UIActionSheet alloc] initWithTitle: @"New game"
                                                delegate: self
                                       cancelButtonTitle: @"Cancel"
                                  destructiveButtonTitle: nil
                                       otherButtonTitles:
                     @"Play white", @"Play black", nil]; ///@"Play both",              @"Analysis"

                    [menu showInView: self.view];
                }
                break;
            case 1:
                [self showLevelsMenu];  // showSaveGameMenu
                break;
            case 2:
                [self showAboutMenu];  /// showLoadGameMenu
                break;
            case 3:
                [self showEmailGameMenu];
                break;
            case 4:
                [self editPosition];
                break;
            case 5:
                [self showLevelsMenu];
                break;
            case 6:
                break;
            default:
                NSLog(@"Not implemented yet");
        }
    }
    else if (actionSheet == self.moveMenu || [title isEqualToString: @"Move"]) {
        switch(buttonIndex) {
            case 0: // Take back
                if ([[Options sharedOptions] displayMoveGestureTakebackHint])
                    [[[UIAlertView alloc] initWithTitle: @"Hint:"
                                                message: ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?
                                                          @"You can also take back moves by swiping your finger from right to left in the move list window." :
                                                          @"You can also take back moves by swiping your finger from right to left in the move list area below the board.")
                                               delegate: self
                                      cancelButtonTitle: nil
                                      otherButtonTitles: @"OK", nil] show];
                [self.gameController takeBackMove];
                break;
            case 1: // Step forward
                if ([[Options sharedOptions] displayMoveGestureStepForwardHint])
                    [[[UIAlertView alloc] initWithTitle: @"Hint:"
                                                message: ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?
                                                          @"You can also step forward in the game by swiping your finger from left to right in the move list window." :
                                                          @"You can also step forward in the game by swiping your finger from left to right in the move list area below the board.")
                                               delegate: self
                                      cancelButtonTitle: nil
                                      otherButtonTitles: @"OK", nil] show];
                [self.gameController replayMove];
                break;
            case 2: // Take back all
                [self.gameController takeBackAllMoves];
                break;
            case 3: // Step forward all
                [self.gameController replayAllMoves];
                break;
            case 4: // Move now
                if ([self.gameController computersTurnToMove]) {
                    if ([self.gameController engineIsThinking])
                        [self.gameController engineMoveNow];
                    else
                        [self.gameController engineGo];
                }
                else
                    [self.gameController startThinking];
                break;
            case 5:
                break;
            default:
                NSLog(@"Not implemented yet");
        }
    }
    else if (actionSheet == self.startGameMenu || [title isEqualToString: @"New game"]) {  /// changed new to startGame sav 3.13.14
        switch (buttonIndex) {
            case 0:
                NSLog(@"new game with white");
                [[Options sharedOptions] setGameMode:GAME_MODE_COMPUTER_BLACK];
//                [self.qwOptions setGameMode: GAME_MODE_COMPUTER_BLACK];
                
                [self.gameController setGameMode:GAME_MODE_COMPUTER_BLACK];
//                [self.gameController setGameMode: [[Options sharedOptions] gameMode]];
                
                [self startNewGame];
                break;
                
            case 1:
                NSLog(@"new game with black");
                [[Options sharedOptions] setGameMode: GAME_MODE_COMPUTER_WHITE];
                [self.gameController setGameMode: GAME_MODE_COMPUTER_WHITE];
                [self startNewGame];
                
                break;
            case 2:
                NSLog(@"new game (both)");
                [[Options sharedOptions] setGameMode: GAME_MODE_TWO_PLAYER];
                [self.gameController setGameMode: GAME_MODE_TWO_PLAYER];
                [self startNewGame];
                break;
            case 3:
                NSLog(@"new game (analysis)");
                [[[UIAlertView alloc] initWithTitle: @"Analysis"
                                            message: @"Has not been implemented yet"
                                           delegate: self
                                  cancelButtonTitle: nil
                                  otherButtonTitles: @"OK", nil] show];
//                [[Options sharedOptions] setGameMode: GAME_MODE_ANALYSE];
//                [self.gameController setGameMode: GAME_MODE_ANALYSE];
//                [self startNewGame];
                break;
            default:
                NSLog(@"not implemented yet");
        }
    }
    
}

- (void)toolbarButtonPressed:(id)sender {
    NSString *title = [sender title];
    
    // Ignore duplicate presses on the "Game" and "Move" buttons:
    if ([self.gameMenu isVisible] && [title isEqualToString: @"Game"])
        return;
    if ([self.moveMenu isVisible] && [title isEqualToString: @"Move"])
        return;
    
    
    // Dismiss action sheet popovers, if visible:
    if ([self.gameMenu isVisible] && ![title isEqualToString: @"Game"])
        [self.gameMenu dismissWithClickedButtonIndex: -1 animated: YES];
    if ([self.startGameMenu isVisible])
        [self.startGameMenu dismissWithClickedButtonIndex: -1 animated: YES];
    if ([self.moveMenu isVisible])
        [self.moveMenu dismissWithClickedButtonIndex: -1 animated: YES];
    if (self.optionsMenu != nil) {
        [self.optionsMenu dismissPopoverAnimated: YES];
        self.optionsMenu = nil;
    }
    if (self.levelsMenu != nil) {
        [self.levelsMenu dismissPopoverAnimated: YES];
        self.levelsMenu = nil;
    }
    
    if (self.aboutMenu != nil) {
        [self.aboutMenu dismissPopoverAnimated:YES];
        self.aboutMenu = nil;
    }
    if (self.saveMenu != nil) {
        [self.saveMenu dismissPopoverAnimated: YES];
        self.saveMenu = nil;
    }
    if (self.emailMenu != nil) {
        [self.emailMenu dismissPopoverAnimated: YES];
        self.emailMenu = nil;
    }
    if (self.loadMenu != nil) {
        [self.loadMenu dismissPopoverAnimated: YES];
        self.loadMenu = nil;
    }
    if (self.popoverMenu != nil) {
        [self.popoverMenu dismissPopoverAnimated: YES];
        self.popoverMenu = nil;
    }
    
    if ([title isEqualToString: @"Game"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.gameMenu showFromBarButtonItem: sender animated: YES];
        
        
    } else {
        //// Need to implement these Game menu options like email game etc.

            UIActionSheet *menu =
            [[UIActionSheet alloc]
             initWithTitle: @"Game"
             delegate: self
             cancelButtonTitle: @"Cancel"
             destructiveButtonTitle: nil
             otherButtonTitles: @"New game", @"Game Options", @"About", nil];
            [menu showInView: self.view];
              /// @"E-mail game", @"Edit position", , nil]; @"Save game", @"Load game"
              /// removed content view sav 3.16.14
//            menu = nil; // Arc repair Seth 12/30/13
        }
    }
    
//    else if ([title isEqualToString:@"Game Options"])
//        [self showLevelsMenu];
    
    
    else if ([title isEqualToString: @"Options"])
        [self showOptionsMenu];
    
    else if ([title isEqualToString: @"Flip"])
        [self.gameController rotateBoard];
    else if ([title isEqualToString: @"Move"]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.moveMenu showFromBarButtonItem: sender animated: YES];
        }
        else {
            UIActionSheet *menu =
            [[UIActionSheet alloc]
             initWithTitle: @"Move"
             delegate: self
             cancelButtonTitle: @"Cancel"
             destructiveButtonTitle: nil
             otherButtonTitles:
             @"Take back", @"Step forward", @"Take back all", @"Step forward all", @"Move now", nil];
            [menu showInView: self.view]; /// 3.14.14
            menu = nil; // Arc repair Seth 1.2.14
        }
    }
    else if ([title isEqualToString: @"Hint"])
        [self.gameController showHint];
    else if ([title isEqualToString: @"New"])
        [self.gameController startNewGame];
    else
        NSLog(@"%@", [sender title]);
}


- (void)startNewGame {
    NSLog(@"startNewGame");
    
    [self.gameController replayAllMoves];  /// this might have fixed the move engine problem thing sav 3.21.14
    
    [self.boardView hideLastMove];
    [self.boardView stopHighlighting];
    self.qwGame = nil;  /// ** removed [game release] from stockfish ver /// seth 12.30.13
    
//    self.boardView = nil;
    
    for (PieceImageView *piv in self.pieceViews)
        [piv removeFromSuperview];
    self.piv = nil; /// ** removed [pieceViews release] *** for ARC added nil. /// seth 12.30.13
    
    //// *** something needs to stop here and remove the pieceViews sav 3.20.14
    self.pieceViews = nil;
    [self.gameController takeBackAllMoves];
    /////// ****
    
    
//    self.qwGame = [[Game alloc] initWithGameController: self];
    self.gameController.gameLevel = [[Options sharedOptions] gameLevel];
    self.gameController.gameMode = [[Options sharedOptions] gameMode];
    if ([[Options sharedOptions] isFixedTimeLevel])
        [self.qwGame setTimeControlWithFixedTime: [[Options sharedOptions] timeIncrement]];
    else
        [self.qwGame setTimeControlWithTime: [[Options sharedOptions] baseTime]
                           increment: [[Options sharedOptions] timeIncrement]];
    
    [self.qwGame setWhitePlayer:
     ((self.gameController.gameMode == GAME_MODE_COMPUTER_BLACK)?
      [[[Options sharedOptions] fullUserName] copy] : ENGINE_NAME)];
    [self.qwGame setBlackPlayer:
     ((self.gameController.gameMode == GAME_MODE_COMPUTER_BLACK)?
      ENGINE_NAME : [[[Options sharedOptions] fullUserName] copy])];
    
    
    // NOt sure how to fix this sav 3.21.14
//    self.pieceViews = [[NSMutableArray alloc] init];  /// lazy instantiate? sav 3.21.14

    self.pendingFrom = SQ_NONE;
    self.pendingTo = SQ_NONE;
    
    [self.moveListView setText: @""];
    [self.analysisView setText: @""];
    [self.searchStatsView setText: @""];
    [self.gameController showPiecesAnimate: NO];
    self.engineIsPlaying = NO;
    [self.engineController abortSearch];
    [self.engineController sendCommand: @"ucinewgame"];
    [self.engineController sendCommand:
     [NSString stringWithFormat:
      @"setoption name Play Style value %@",
      [[Options sharedOptions] playStyle]]];
    
    if ([[Options sharedOptions] strength] == 1300) // Max strength  /// 2500
        [self.engineController
         sendCommand: @"setoption name UCI_LimitStrength value false"];
    else
        [self.engineController
         sendCommand: @"setoption name UCI_LimitStrength value true"];
    
    [self.engineController commitCommands];
    
    if ([self.remoteEngineController isConnected])
        [self.remoteEngineController sendToServer: @"n\n"];
    
    [self.gameController showBookMoves];
    
    // Rotate board if the engine plays white:
//    if (! self.rotated && [self.gameController computersTurnToMove])
//        [self.gameController rotateBoard];
    [self.gameController engineGo];
    
    //// I added this
    [self.gameController redrawPieces];
}

//+ (int)currentSystemTime {
//    return Chess::get_system_time();
//}


//- (void)startWhiteClock
//{
////     self.whiteClock = 
//}




- (void)showSaveGameMenu

{
////    //  [gdtc ];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        self.saveMenu = [[UIPopoverController alloc] initWithContentViewController: self.qwSaveGameNC];
//        [self.saveMenu presentPopoverFromBarButtonItem: self.gameButton
//                         permittedArrowDirections: UIPopoverArrowDirectionAny
//                                         animated: YES];
//        
//        
//    } else {
//        CGRect r = [[self.qwSaveGameNC view] frame];
////        // Why do I suddenly have to use -20.0f for the Y coordinate below?
////        // 0.0f seems right, and used to work in SDK 2.x.
//        r.origin = CGPointMake(0.0f, 20.0f);
//        [[self.qwSaveGameNC view] setFrame: r];
//        [self.view insertSubview: [self.qwSaveGameNC view] atIndex: 0];
//        [self.view bringSubviewToFront:self.qwSaveGameNC.view];
//        [self flipSubviewsLeft];
//    }
}

/// *** Button Actions *** /////

- (void)showLoadGameMenu
{
//    LoadFileListController *lflc =
//    [[LoadFileListController alloc] initWithBoardViewController: self];
//    navigationController =
//    [[UINavigationController alloc] initWithRootViewController: lflc];
//    //  [lflc ];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        loadMenu = [[UIPopoverController alloc]
//                    initWithContentViewController: navigationController];
//        [loadMenu presentPopoverFromBarButtonItem: gameButton
//                         permittedArrowDirections: UIPopoverArrowDirectionAny
//                                         animated: YES];
//    }
//    else {
//        CGRect r = [[navigationController view] frame];
//        // Why do I suddenly have to use -20.0f for the Y coordinate below?
//        // 0.0f seems right, and used to work in SDK 2.x.
//        r.origin = CGPointMake(0.0f, -20.0f);
//        [[navigationController view] setFrame: r];
//        [rootView insertSubview: [navigationController view] atIndex: 0];
//        [rootView flipSubviewsLeft];
//    }
}

- (void)showEmailGameMenu
{
//    GameDetailsTableController *gdtc =
//    [[GameDetailsTableController alloc]
//     initWithBoardViewController: self
//     game: [gameController game]
//     email: YES];
//    navigationController =
//    [[UINavigationController alloc] initWithRootViewController: gdtc];
//    //  [gdtc ];
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        emailMenu = [[UIPopoverController alloc]
//                     initWithContentViewController: navigationController];
//        [emailMenu presentPopoverFromBarButtonItem: gameButton
//                          permittedArrowDirections: UIPopoverArrowDirectionAny
//                                          animated: YES];
//    }
//    else {
//        CGRect r = [[navigationController view] frame];
//        // Why do I suddenly have to use -20.0f for the Y coordinate below?
//        // 0.0f seems right, and used to work in SDK 2.x.
//        r.origin = CGPointMake(0.0f, -20.0f);
//        [[navigationController view] setFrame: r];
//        [rootView insertSubview: [navigationController view] atIndex: 0];
//        [rootView flipSubviewsLeft];
//    }
}

- (void)editPosition
{
//    SetupViewController *svc =
//    [[SetupViewController alloc]
//     initWithBoardViewController: self
//     fen: [[gameController game] currentFEN]];
//    navigationController =
//    [[UINavigationController alloc] initWithRootViewController: svc];
//    svc = nil;  // ARC repair Seth 1.2.14
//    
//    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        popoverMenu = [[UIPopoverController alloc]
//                       initWithContentViewController: navigationController];
//        //[popoverMenu setPopoverContentSize: CGSizeMake(320.0f, 460.0f)];
//        [popoverMenu presentPopoverFromBarButtonItem: gameButton
//                            permittedArrowDirections: UIPopoverArrowDirectionAny
//                                            animated: NO];
//    }
//    else {
//        CGRect r = [[navigationController view] frame];
//        // Why do I suddenly have to use -20.0f for the Y coordinate below?
//        // 0.0f seems right, and used to work in SDK 2.x.
//        r.origin = CGPointMake(0.0f, -20.0f);
//        [[navigationController view] setFrame: r];
//        [rootView insertSubview: [navigationController view] atIndex: 0];
//        [rootView flipSubviewsLeft];
//    }
}

- (void)showLevelsMenu
{
    NSLog(@"levels menu");
//
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {  /// sav 4.9.14
        self.levelsMenu = [[UIPopoverController alloc]
                      initWithContentViewController: self.qwGameOptionsNavigationController];
        [self.levelsMenu presentPopoverFromBarButtonItem: self.gameButton
                           permittedArrowDirections: UIPopoverArrowDirectionAny
                                           animated: YES];
    } else {
    CGRect rect = [[self.qwGameOptionsNavigationController view] frame];
        rect.origin = CGPointMake(0.0f, 20.0f);
        [[self.qwGameOptionsNavigationController view] setFrame: rect];
        [self.view insertSubview: [self.qwGameOptionsNavigationController view] atIndex: 0];
        [self flipSubviewsLeft];
        [self.view bringSubviewToFront:self.qwGameOptionsNavigationController.view];
    }
}

- (void)showAboutMenu
{

    
        self.aboutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
        self.aboutViewController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        [self presentViewController:self.aboutViewController animated:YES completion:nil];
        
}

- (void)showOptionsMenu
{

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.optionsMenu = [[UIPopoverController alloc] initWithContentViewController:self.qwNC];
        [self.optionsMenu presentPopoverFromBarButtonItem:self.optionsButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
         } else {
             
           
             CGRect rect = [[self.qwNC view] frame];
             rect.origin = CGPointMake(0.0f, 20.0f);
             [[self.qwNC view] setFrame:rect];
             [self.view insertSubview:[self.qwNC view] atIndex:0];
             [self flipSubviewsLeft];
             [self.view bringSubviewToFront:self.qwNC.view];
         }
}

- (void)optionsMenuPressed
{
    // do something here
}

- (void)levelsMenuDonePressed {
    NSLog(@"options menu done");
    
    if ([[Options sharedOptions] gameLevelWasChanged])
        [self.gameController setGameLevel: [[Options sharedOptions] gameLevel]];
    if ([[Options sharedOptions] gameModeWasChanged])
        [self.gameController setGameMode: [[Options sharedOptions] gameMode]];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.levelsMenu dismissPopoverAnimated: YES];
        //    [levelsMenu ];
        self.levelsMenu = nil;
    }
    else {
        [self flipSubviewsRight];
        [[self.qwLevelViewController view] removeFromSuperview];
        [[self.qwGameOptionsNavigationController view] removeFromSuperview];
    }
    self.qwLevelViewController = nil; // ARC repair Seth 1.2.14
    self.qwGameOptionsNavigationController = nil;
    
}


- (void)optionsMenuDonePressed
{
        NSLog(@"options menu done");
        if ([[Options sharedOptions] bookVarietyWasChanged])
            [self.gameController showBookMoves];
    
    
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.optionsMenu dismissPopoverAnimated: YES];
            
            //  [optionsMenu ];
            self.optionsMenu = nil;
        }
        else {
            [self flipSubviewsRight];
            [[self.qwNC view] removeFromSuperview];
        }
    }


- (void)flipSubviewsLeft {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations: nil context: context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft
                           forView: self.view cache: YES];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 1.0];
    [self.view exchangeSubviewAtIndex: 0 withSubviewAtIndex: 1];
    [UIView commitAnimations];
}

- (void)flipSubviewsRight {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations: nil context: context];
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight
                           forView: self.view cache: YES];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration: 1.0];
    [self.view exchangeSubviewAtIndex: 0 withSubviewAtIndex: 1];
    [UIView commitAnimations];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.boardView = nil;
    self.boardViewController = nil;
    self.gameController = nil;
    self.qwGame = nil;
   // Dispose of any resources that can be recreated.
}

@end
