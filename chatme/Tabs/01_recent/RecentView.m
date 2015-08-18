//
//  RecentView.m
//  chatme
//
//  Created by Le Ngoc Giang on 6/25/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "RecentView.h"
#import "AppConstant.h"
#import "common.h"
#import "recent.h"

#import "RecentCell.h"
#import "ChatView.h"

@interface RecentView ()
{
    NSMutableArray *recents;
}

@end

@implementation RecentView
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_recent"]];
        [self.tabBarItem setTitle:@"Recent"];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:self];
    }
    return self;
}
#pragma mark - View Controller
- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([PFUser currentUser] != nil)
    {
        // [self loadRecent]
    }
    else LoginUser(self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User actions
- (void)actionCleanup
{
    [recents removeAllObjects];
    [self.tableView reloadData];
}

- (void)actionChat:(NSString *)groudID
{
    /*
        ChatView *chatView = [ChatView alloc]initWithGroup:groupID];
        chatView.
        [self.navigationController pushViewController:chatView animated:YES]
     */
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recents count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentCell *cell = (RecentCell*)[tableView dequeueReusableCellWithIdentifier:@"RecentCell"];

    [cell bindData:recents[indexPath.row]];
     
     return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFObject *recent = recents[indexPath.row];
    
    [self actionChat:recent[PF_RECENT_GROUPID]];
}

@end