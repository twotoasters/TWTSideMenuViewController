//
//  TWTSideMenuViewControllerTests.m
//  TWTSideMenuViewControllerTests
//
//  Created by Josh Johnson on 1/17/14.
//  Copyright (c) 2014 Two Toasters. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TWTSideMenuViewController.h"

@interface TWTSideMenuViewControllerTests : XCTestCase

@end

@implementation TWTSideMenuViewControllerTests

- (void)testSideMenuViewSetup
{
    // Admittedly this is a weak test. Mostly just getting the tests setup
    TWTSideMenuViewController *sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:[[UIViewController alloc] init] mainViewController:[[UIViewController alloc] init]];
    
    XCTAssertTrue(sideMenuViewController.childViewControllers.count > 0, @"Side menu view does not have childer view controllers");
}

@end
