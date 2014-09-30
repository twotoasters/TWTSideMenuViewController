//
//  TWTMenuViewController.m
//  TWTSideMenuViewController-Sample
//
//  Created by Josh Johnson on 8/14/13.
//  Copyright (c) 2013 Two Toasters. All rights reserved.
//

#import "TWTMenuViewController.h"
#import "TWTMainViewController.h"
#import "TWTSideMenuViewController.h"

@interface TWTMenuViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

@end

@implementation TWTMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"galaxy"]];
    self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGRect imageViewRect = [[UIScreen mainScreen] bounds];
    imageViewRect.size.width += 589;
    self.backgroundImageView.frame = imageViewRect;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.backgroundImageView];

    NSDictionary *viewDictionary = @{ @"imageView" : self.backgroundImageView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]" options:0 metrics:nil views:viewDictionary]];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(10.0f, 100.0f, 200.0f, 44.0f);
    [closeButton setBackgroundColor:[UIColor whiteColor]];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    changeButton.frame = CGRectMake(10.0f, 200.0f, 200.0f, 44.0f);
    [changeButton setTitle:@"Swap" forState:UIControlStateNormal];
    [changeButton setBackgroundColor:[UIColor greenColor]];
    [changeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    
    UIButton *modalButton = [UIButton buttonWithType:UIButtonTypeSystem];
    modalButton.frame = CGRectMake(10.0f, 300.0f, 200.0f, 44.0f);
    [modalButton setTitle:@"Modal Test" forState:UIControlStateNormal];
    [modalButton setBackgroundColor:[UIColor redColor]];
    [modalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [modalButton addTarget:self action:@selector(modalButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:modalButton];
}

- (void)changeButtonPressed
{
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[TWTMainViewController new]];
    [self.sideMenuViewController setMainViewController:controller animated:YES closeMenu:YES];
}

- (void)modalButtonPressed
{
    // Test with presenting a modal view controller when in the context of a menuviewcontroller
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    viewController.view.backgroundColor = [UIColor redColor];
    [self presentViewController:viewController animated:YES completion:^{
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [viewController dismissViewControllerAnimated:YES completion:^{
                UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[TWTMainViewController new]];
                [self.sideMenuViewController setMainViewController:controller animated:YES closeMenu:YES];
            }];
        });
    }];
}

- (void)closeButtonPressed
{
    [self.sideMenuViewController closeMenuAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
