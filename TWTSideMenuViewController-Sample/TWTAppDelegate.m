//
//  TWTAppDelegate.m
//  TWTSideMenuViewController-Sample
//
//  Created by Josh Johnson on 8/14/13.
//  Copyright (c) 2013 Two Toasters. All rights reserved.
//

#import "TWTAppDelegate.h"
#import "TWTMenuViewController.h"
#import "TWTMainViewController.h"

#import "TWTSideMenuViewController.h"

@interface TWTAppDelegate ()

@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
@property (nonatomic, strong) TWTMenuViewController *menuViewController;
@property (nonatomic, strong) TWTMainViewController *mainViewController;

@end

@implementation TWTAppDelegate

- (TWTMenuViewController *)menuViewController {
    if (!_menuViewController) {
        _menuViewController = [[TWTMenuViewController alloc] init];
    }
    return _menuViewController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    self.mainViewController = [[TWTMainViewController alloc] init];
    
    _sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:self.menuViewController mainViewController:[[UINavigationController alloc] initWithRootViewController:self.mainViewController]];
    _sideMenuViewController.shadowColor = [UIColor blackColor];
    _sideMenuViewController.edgeOffset = (UIOffset) { .horizontal = 18.0f };
    _sideMenuViewController.zoomScale = 0.65f;
    self.window.rootViewController = _sideMenuViewController;
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - TWTSideMenuViewControllerDelegate

- (UIStatusBarStyle)sideMenuViewController:(TWTSideMenuViewController *)sideMenuViewController statusBarStyleForViewController:(UIViewController *)viewController
{
    if (viewController == self.menuViewController) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

@end
