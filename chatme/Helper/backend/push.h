//
//  push.h
//  chatme
//
//  Created by Le Ngoc Giang on 6/30/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

@import Parse;

void        ParsePushUserAssign     (void);
void        ParsePushUserResign     (void);

void        SendPushNotification    (NSString *groupID,NSString *text);

