//
//  PFUser+Util.h
//  chatme
//
//  Created by Le Ngoc Giang on 6/30/15.
//  Copyright (c) 2015 giangle. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (Util)

- (NSString *)fullname;

- (BOOL)isEqualTo:(PFUser *)user;


@end
