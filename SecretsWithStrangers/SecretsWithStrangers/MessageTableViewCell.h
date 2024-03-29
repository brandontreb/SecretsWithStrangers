//
//  MessageTableViewCell.h
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/11/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatMessage;

@interface MessageTableViewCell : UITableViewCell
@property(nonatomic, strong) ChatMessage *message;
@end
