//
//  ChatViewController.h
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/11/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Network.h"

@class Message;

@interface ChatViewController : UIViewController<NetworkDelegate>
@property(nonatomic, strong) Network *network;
@property(nonatomic, strong) Message *secret;
@end
