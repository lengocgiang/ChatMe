//
//  push.m
//  chatme
//
//  Created by Le Ngoc Giang on 6/30/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "push.h"
#import "AppConstant.h"



void SendPushNotification       (NSString *groupID, NSString *text)
{
    PFUser      *user = [PFUser currentUser];
    NSString    *message = [NSString stringWithFormat:@"%@: %@",user[PF_USER_FULLNAME],text];
    
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_GROUPID equalTo:groupID];
    [query whereKey:PF_RECENT_USER equalTo:user];
    [query includeKey:PF_RECENT_USER];
    [query setLimit:100];
    
    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER matchesKey:PF_RECENT_USER inQuery:query];
    
    PFPush *push = [[PFPush alloc]init];
    [push setQuery:queryInstallation];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"SendPushNotification send error %@",error.localizedDescription);
        }
    }];
}
