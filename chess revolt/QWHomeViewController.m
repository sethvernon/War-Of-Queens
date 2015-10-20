//
//  QWHomeViewController.m
//  chess revolt-current
//
//  Created by Seth Vernon on 3/20/14.
//  Copyright (c) 2014 Chess Revold. All rights reserved.
//

#import "QWHomeViewController.h"
#import "QWViewController.h"

@interface QWHomeViewController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) QWHomeViewController *qwVC;
@property (nonatomic, strong) GameController *gc;

@property (nonatomic, strong) NSTimer *foo;
@property (weak, nonatomic) IBOutlet UIImageView *whatEverIWant;
@property (nonatomic) int imageNumber;

@property (nonatomic, strong)UIImage *closeCombat;
@property (nonatomic, strong)UIImage *darkKnights;





@end

@implementation QWHomeViewController



- (void)awakeFromNib
{
    self.qwVC = nil;
    [self.qwVC.gc takeBackAllMoves]; /// trying to stop the crashes
    
}

- (void)changePic
{
    
 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
     
 {
     NSArray *foo2 = @[@"CloseCombat_iPadSS.png", @"DarkKnights_iPadSS.png", @"WildSquares_iPadSS.png"];
     self.imageNumber ++;
     if (self.imageNumber > [foo2 count]-1) self.imageNumber = 0;
     self.whatEverIWant.image = [UIImage imageNamed:[foo2 objectAtIndex:self.imageNumber]];
     
     CATransition* transition = [CATransition animation];
     transition.startProgress = 0;
     transition.endProgress = 1.0;
     transition.type = kCATransitionPush;
     
     transition.subtype = kCATransitionFromRight;
     transition.duration = 1.0;

     
     [UIImageView animateWithDuration:3
                           animations:^{
                               [self.whatEverIWant.layer addAnimation:transition forKey:@"transition"];
                           }
                           completion:^(BOOL finished) {
                               [UIImageView animateWithDuration:3
                                                     animations:^{
//                                                         self.whatEverIWant.alpha = .05;
                                                         
                                                         [UIImageView animateWithDuration:3
                                                                               animations:^{
//                                                                                   self.whatEverIWant.alpha = 1;
                                                          
                                                          }];
                                                     }];
                               
                           }];

    
 } else {  NSArray *foo = @[@"CloseCombat_iPhoneSS.png", @"DarkKnights_iPhoneSS.png", @"WildSquares_iPhoneSS.png"];
        self.imageNumber ++;
        if (self.imageNumber > [foo count]-1) self.imageNumber = 0;
        self.whatEverIWant.image = [UIImage imageNamed:[foo objectAtIndex:self.imageNumber]];
     
     CATransition* transition = [CATransition animation];
     transition.startProgress = 0;
     transition.endProgress = 1.0;
     transition.type = kCATransitionPush;
     
     transition.subtype = kCATransitionFromRight;
     transition.duration = 1.0;

     
     [UIImageView animateWithDuration:3
                           animations:^{
                               [self.whatEverIWant.layer addAnimation:transition forKey:@"transition"];
                           }
                           completion:^(BOOL finished) {
                               [UIImageView animateWithDuration:2
                                                     animations:^{
//                                                         self.whatEverIWant.alpha = .05;
                                                         
                                                         [UIImageView animateWithDuration:3
                                                                               animations:^{
//                                                                                   self.whatEverIWant.alpha = 1;
                                                                                   
                                                                                   
                                                                               }];
                                                     }];
                               
                           }];
     
            }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.foo = [NSTimer scheduledTimerWithTimeInterval:6
                                                target:self
                                              selector:@selector(changePic)
                                              userInfo:nil
                                               repeats:YES];
    
                          

    
    
    // Do any additional setup after loading the view.
//    NSUInteger numberPages = self.contentList.count;
//    
//    // view controllers are created lazily
//    // in the meantime, load the array with placeholders which will be replaced on demand
//    NSMutableArray *controllers = [[NSMutableArray alloc] init];
//    for (NSUInteger i = 0; i < numberPages; i++)
//    {
//		[controllers addObject:[NSNull null]];
//    }
//    self.viewControllers = controllers;
//    
//    // a page is the width of the scroll view
//    self.scrollView.pagingEnabled = YES;
//    self.scrollView.contentSize =
//    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
//    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.showsVerticalScrollIndicator = NO;
//    self.scrollView.scrollsToTop = NO;
//    self.scrollView.delegate = self;
//    
//    self.pageControl.numberOfPages = numberPages;
//    self.pageControl.currentPage = 0;
//    
//    // pages are created on demand
//    // load the visible page
//    // load the page on either side to avoid flashes when the user starts scrolling
//    //
//    [self loadScrollViewWithPage:0];
//    [self loadScrollViewWithPage:1];
//
//}
//
//- (void)loadScrollViewWithPage:(NSUInteger)page
//{
//    if (page >= self.contentList.count)
//        return;
//    
//    // replace the placeholder if necessary
//    MyViewController *controller = [self.viewControllers objectAtIndex:page];
//    if ((NSNull *)controller == [NSNull null])
//    {
//        controller = [[MyViewController alloc] initWithPageNumber:page];
//        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
//    }
//    
//    // add the controller's view to the scroll view
//    if (controller.view.superview == nil)
//    {
//        CGRect frame = self.scrollView.frame;
//        frame.origin.x = CGRectGetWidth(frame) * page;
//        frame.origin.y = 0;
//        controller.view.frame = frame;
//        
//        [self addChildViewController:controller];
//        [self.scrollView addSubview:controller.view];
//        [controller didMoveToParentViewController:self];
//        
//        NSDictionary *numberItem = [self.contentList objectAtIndex:page];
//        controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:kImageKey]];
//        controller.numberTitle.text = [numberItem valueForKey:kNameKey];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
