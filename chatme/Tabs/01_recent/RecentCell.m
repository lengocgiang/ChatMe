//
//  RecentCell.m
//  chatme
//
//  Created by Le Ngoc Giang on 6/25/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import "RecentCell.h"
#import "AppConstant.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>

#import "converted.h"


@interface RecentCell()
{
    PFObject *recent;
}

@property (weak, nonatomic) IBOutlet PFImageView *imageUser;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelLastMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelElapsed;
@property (weak, nonatomic) IBOutlet UILabel *labelCounter;

@end

@implementation RecentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindData:(PFObject *)recent_
{
    recent = recent_;
    
    PFUser *lastUser = recent[PF_RECENT_LASTUSER];
    [self.imageUser setFile:lastUser[PF_USER_PICTURE]];
    [self.imageUser loadInBackground];
    
    self.labelDescription.text = recent[PF_RECENT_DESCRIPTION];
    self.labelLastMessage.text = recent[PF_RECENT_LASTMESSAGE];
    
    NSTimeInterval seconds = [[NSDate date]timeIntervalSinceDate:recent[PF_RECENT_UPDATEDACTION]];
    self.labelElapsed.text = TimeElapsed(seconds);
    
    int counter = [recent[PF_RECENT_COUNTER]intValue];
    self.labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new",counter];
    
}

@end
