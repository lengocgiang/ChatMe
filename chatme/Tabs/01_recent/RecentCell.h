//
//  RecentCell.h
//  chatme
//
//  Created by Le Ngoc Giang on 6/25/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Parse;

@interface RecentCell : UITableViewCell
- (void)bindData:(PFObject *)recent_;
@end
