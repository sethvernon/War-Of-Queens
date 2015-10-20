//
//  CRAppDelegate.h
//  Chess Revolt
//
//  Created by Administrator1 on 10/4/13.
//  Copyright (c) 2013 Chess Revold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardViewController.h"
//#import "GameController.h"



@interface CRAppDelegate : UIResponder <UIApplicationDelegate>
//{
//    UIWindow *window;                      //// SEth 1.3.14
//    BoardViewController *viewController;
//    GameController *gameController;
//}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) BoardViewController *viewController;
@property (nonatomic, readonly) GameController *gameController;

//- (void)backgroundInit:(id)anObject;
//- (void)backgroundInitFinished:(id)anObject;


@end
