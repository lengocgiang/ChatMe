//
//  common.m
//  chatme
//
//  Created by Le Ngoc Giang on 8/18/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "common.h"
#import "NavigationController.h"
#import "WelcomeView.h"
void LoginUser(id target)
{
    NavigationController *navigationController = [[NavigationController alloc]initWithRootViewController:[[WelcomeView alloc]init]];
    [target presentViewController:navigationController animated:YES completion:nil];
}
