//
//  recent.m
//  chatme
//
//  Created by Le Ngoc Giang on 6/30/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "recent.h"
#import "AppConstant.h"
#import "PFUser+Util.h"

@import Parse;

void ClearRecentCounter     (NSString *groupID)
{
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_GROUPID equalTo:groupID];
    [query whereKey:PF_RECENT_USER equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error == nil)
        {
            for (PFObject *recent in objects)
            {
                recent[PF_RECENT_COUNTER] = @0;
                [recent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error != nil) NSLog(@"ClearRecentCounter save error.");
                }];
            }
        }
        else NSLog(@"ClearRecentCounter query error.");
    }];
}

void UpdateRecentCounter(NSString *groupId, NSInteger amount, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFQuery *query = [PFQuery queryWithClassName:PF_RECENT_CLASS_NAME];
    [query whereKey:PF_RECENT_GROUPID equalTo:groupId];
    [query includeKey:PF_RECENT_USER];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             for (PFObject *recent in objects)
             {
                 if ([recent[PF_RECENT_USER] isEqualTo:[PFUser currentUser]] == NO)
                     [recent incrementKey:PF_RECENT_COUNTER byAmount:[NSNumber numberWithInteger:amount]];
                 //---------------------------------------------------------------------------------------------------------------------------------
                 recent[PF_RECENT_LASTUSER] = [PFUser currentUser];
                 recent[PF_RECENT_LASTMESSAGE] = lastMessage;
                 recent[PF_RECENT_UPDATEDACTION] = [NSDate date];
                 [recent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                  {
                      if (error != nil) NSLog(@"UpdateRecentCounter save error.");
                  }];
             }
         }
         else NSLog(@"UpdateRecentCounter query error.");
     }];
}

