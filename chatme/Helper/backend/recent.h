//
//  recent.h
//  chatme
//
//  Created by Le Ngoc Giang on 6/30/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

@import Parse;

void        ClearRecentCounter      (NSString *groupID);
void        UpdateRecentCounter     (NSString *groupId, NSInteger amount, NSString *lastMessage);

