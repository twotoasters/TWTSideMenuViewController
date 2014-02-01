//
//  TWTMainViewController.m
//  TWTSideMenuViewController-Sample
//
//  Created by Josh Johnson on 8/14/13.
//  Copyright (c) 2013 Two Toasters. All rights reserved.
//

#import "TWTMainViewController.h"
#import "TWTSideMenuViewController.h"

static NSString * const kTableViewCellIdentifier = @"com.twotoasters.sampleCell";

@interface TWTMainViewController ()

@end

@implementation TWTMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.title = @"My View";
    self.view.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *openItem = [[UIBarButtonItem alloc] initWithTitle:@"Open" style:UIBarButtonItemStylePlain target:self action:@selector(openButtonPressed)];
    self.navigationItem.leftBarButtonItem = openItem;
    
    UIBarButtonItem *testItem = [[UIBarButtonItem alloc] initWithTitle:@"Show Modal" style:UIBarButtonItemStylePlain target:self action:@selector(testButtonAction)];
    self.navigationItem.rightBarButtonItem = testItem;
   
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewCellIdentifier];
}

- (void)testButtonAction
{
    // Test with presenting a modal view controller when in the context of a menuviewcontroller
    UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    viewController.view.backgroundColor = [UIColor redColor];
    [self presentViewController:viewController animated:YES completion:^{
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [viewController dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

- (void)openButtonPressed
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.text = [NSString stringWithFormat:@"Row %li", indexPath.row + 1];
}

@end
