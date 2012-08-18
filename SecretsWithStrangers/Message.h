//
//  Message.h
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/11/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MessageSenderType{
    kMessageSenderTypeMe,
    kMessageSenderTypeStranger
} MessageSenderType;

@interface Message : NSObject
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSString *time;
@property(nonatomic) MessageSenderType messageSenderType;
@property(nonatomic) BOOL isSecret;
@end
