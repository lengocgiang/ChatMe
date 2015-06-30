//
//  ChatView.h
//  chatme
//
//  Created by Le Ngoc Giang on 6/25/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import <JSQMessages.h>

@interface ChatView : JSQMessagesViewController
<
    UIActionSheetDelegate
>

- (id)initWith:(NSString*)groupdId_;

@end
