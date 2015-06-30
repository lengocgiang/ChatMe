//
//  ChatView.m
//  chatme
//
//  Created by Le Ngoc Giang on 6/25/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "ChatView.h"
@import Parse;

#import "AppConstant.h"
#import "recent.h"
#import "push.h"

@interface ChatView ()
{
    NSTimer     *timer;
    BOOL        isLoading;
    BOOL        initialized;
    
    NSString    *groupID;
    
    NSMutableArray      *users;
    NSMutableArray      *messages;
    NSMutableDictionary *avatars;
    
    JSQMessagesBubbleImage  *bubbleImageOutgoing;
    JSQMessagesBubbleImage  *bubbleImageIncoming;
    JSQMessagesAvatarImage  *avatarImageBlank;
}

@end

@implementation ChatView

- (id)initWith:(NSString *)groupdId_
{
    self = [super init];
    if (self)
    {
        groupID = groupdId_;
    }
    
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Chat";

    // init
    users       = [NSMutableArray new];
    messages    = [NSMutableArray new];
    avatars     = [NSMutableDictionary new];
    
    // get current user
    PFUser *user = [PFUser currentUser];
    self.senderId = user.objectId;
    self.senderDisplayName = user[PF_USER_FULLNAME];
    
    // setup color bubble image outgoing/incoming
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc]init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:COLOR_OUTGOING];
    bubbleImageIncoming = [bubbleFactory outgoingMessagesBubbleImageWithColor:COLOR_INCOMING];
    
    avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:3.0];
    
    isLoading = NO;
    initialized = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    ClearRecentCounter(groupID);
    [timer invalidate];
}

#pragma mark - Backend methods

- (void)loadMessages
{
    if (isLoading == NO)
    {
        isLoading = YES;
        
        JSQMessage *message_last = [messages lastObject];
        
        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
        
        [query whereKey:PF_MESSAGE_GROUPID equalTo:groupID];
        
        if (message_last != nil) [query whereKey:PF_MESSAGE_CREATEDAT greaterThan:message_last.date];
        
        [query includeKey:PF_MESSAGE_USER];
        [query orderByDescending:PF_MESSAGE_USER];
        [query setLimit:50];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error == nil)
            {
                BOOL incoming = NO;
                self.automaticallyScrollsToMostRecentMessage = NO;
                for (PFObject *object in [objects reverseObjectEnumerator])
                {
                    JSQMessage *message = [self addMessage:object];
                    if ([self incoming:message]) incoming = YES;
                }
                if ([objects count] != 0)
                {
                    if (initialized && incoming)
                        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                    [self finishReceivingMessage];
                    [self scrollToBottomAnimated:NO];
                }
                self.automaticallyScrollsToMostRecentMessage = YES;
                initialized = YES;
                
            }
            else
            {
                isLoading = NO;
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network error"
                                                                message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (JSQMessage *)addMessage:(PFObject *)object
{
    JSQMessage *message = nil;
    
    PFUser *user = object[PF_MESSAGE_USER];
    NSString *name = user[PF_USER_FULLNAME];
    
    
    PFFile *fileVideo   = object[PF_MESSAGE_VIDEO];
    PFFile *filePicture = object[PF_MESSAGE_PICTURE];
    
    
    if ((filePicture == nil) && (fileVideo == nil))
    {
        message = [[JSQMessage alloc]initWithSenderId:user.objectId
                                     senderDisplayName:name date:object.createdAt text:object[PF_MESSAGE_TEXT]];
    }
    
    if (fileVideo != nil)
    {
        JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc]initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc]initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
    }
    
    if (filePicture != nil)
    {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc]initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc]initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
        
        [filePicture getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error == nil)
            {
                mediaItem.image = [UIImage imageWithData:data];
                [self.collectionView reloadData];
            }
        }];
    }
    
    [users addObject:user];
    [messages addObject:message];
    
    
    return message;
}

- (void)loadAvatar:(PFUser *)user
{
    PFFile *file = user[PF_USER_THUMBNAIL];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error)
        {
            avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:data] diameter:30.0];
            [self.collectionView reloadData];
        }
    }];
}

- (void)sendMessage:(NSString *)text video:(NSURL *)video picture:(UIImage *)picture
{
    PFFile *fileVideo   = nil;
    PFFile *filePicture = nil;
    
    if (video != nil)
    {
        text = @"[Video message]";
        fileVideo = [PFFile fileWithName:@"video.mp4" contentsAtPath:video.path];
        [fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil){UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network error." message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    
    if (picture != nil)
    {
        text = @"[Text message]";
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error != nil){UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network error." message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
    
    PFObject *object = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
    object[PF_MESSAGE_USER]     = [PFUser currentUser];
    object[PF_MESSAGE_GROUPID]  = groupID;
    object[PF_MESSAGE_TEXT]     = text;
    
    if (video != nil) object[PF_MESSAGE_VIDEO] = fileVideo;
    if (picture != nil) object[PF_MESSAGE_PICTURE] = filePicture;
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            [self loadMessages];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    SendPushNotification(groupID, text);
    UpdateRecentCounter(groupID, 1, text);
    
    [self finishSendingMessage];
    
}

#pragma mark - JSQMessagesViewController methods override
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    [self sendMessage:text video:nil picture:nil];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Notice"
                                                   message:@"didPressAccessoryButton" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - JSQMessages Collection View data source

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self outgoing:messages[indexPath.item]])
    {
        return  bubbleImageOutgoing;
    }
    return bubbleImageIncoming;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = users[indexPath.item];
    if (avatars[user.objectId] == nil)
    {
        [self loadAvatar:user];
        return avatarImageBlank;
    }
    else return avatars[user.objectId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    else return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return nil;
            }
        }
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    else return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    if ([self outgoing:messages[indexPath.item]])
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.textView.textColor = [UIColor blackColor];
    }
    return cell;

}

#pragma mark - Helper methods
- (BOOL)incoming:(JSQMessage *)message
{
    return ([message.senderId isEqualToString:self.senderId] == NO);
}

- (BOOL)outgoing:(JSQMessage *)message
{
    return ([message.senderId isEqualToString:self.senderId] == YES);
}
@end
