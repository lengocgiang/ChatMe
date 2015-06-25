//
//  AppDelegate.h
//  chatme
//
//  Created by Le Ngoc Giang on 6/25/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NavigationController.h"

#import "RecentView.h"
#import "GroupView.h"
#import "PeopleView.h"
#import "SettingView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) RecentView    *recentView;
@property (strong, nonatomic) GroupView     *groupView;
@property (strong, nonatomic) PeopleView    *peopleView;
@property (strong, nonatomic) SettingView   *settingView;
@end

