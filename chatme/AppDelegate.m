//
//  AppDelegate.m
//  chatme
//
//  Created by Le Ngoc Giang on 6/25/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "AppDelegate.h"
#import "AppConstant.h"

@import Parse;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self configParse];
    
    [self registerNotification:application];
    
    // Init views in tabbar
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.recentView     = [[RecentView alloc]init];
    self.groupView      = [[GroupView alloc]init];
    self.peopleView     = [[PeopleView alloc]init];
    self.settingView    = [[SettingView alloc]init];
    
    NavigationController *navVC1 = [[NavigationController alloc]initWithRootViewController:self.recentView];
    NavigationController *navVC2 = [[NavigationController alloc]initWithRootViewController:self.groupView];
    NavigationController *navVC3 = [[NavigationController alloc]initWithRootViewController:self.peopleView];
    NavigationController *navVC4 = [[NavigationController alloc]initWithRootViewController:self.settingView];
    
    self.tabBarController = [[UITabBarController alloc]init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:navVC1,navVC2,navVC3,navVC4, nil];
    self.tabBarController.selectedIndex = DEFAULT_TAB;
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Push notification methods
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

#pragma mark - Setup
- (void)configParse
{
    [Parse setApplicationId:@"QEzswA5os0g8MGunQvgreQDBFkUAH7CUMNcEcIJK"
                  clientKey:@"4mqc7AvPYndUTayQ2avbQhRouXOTsTsmA1Aj8zu1"];
}
- (void)registerNotification:(UIApplication*)application
{
    // Register Apple Notification
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}
@end
