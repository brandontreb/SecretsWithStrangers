//
//  Network.h
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/15/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum NetworkStatus
{
    kNetworkStatusDisconnected,
    kNetworkStatusConnectionError,
    kNetworkStatusInLobby,
    kNetworkStatusWaitingForRoom,
    kNetworkStatusInRoom,
    kNetworkStatusBeginChat,
    kNetworkStatusRoomFull,
    kNetworkStatusStrangerNotFound,
    kNetworkStatusStrangerDisconnected
} NetworkStatus;

@class Network;
@class ChatMessage;

@protocol NetworkDelegate <NSObject>
- (void) network:(Network *)network socketConnectedWithStatus:(NetworkStatus) networkStatus;
- (void) network:(Network *)network socketDisconnectedWithStatus:(NetworkStatus) networkStatus;
- (void) network:(Network *)network messageRecieved:(ChatMessage *)message;
@end

@interface Network : NSObject
@property(nonatomic) NetworkStatus networkStatus;
@property(nonatomic, strong) id<NetworkDelegate> delegate;
- (id) initWithAddress:(NSString *) address port:(NSInteger) port;
- (void) connect;
- (void) disconnect;
- (void) sendMessage:(ChatMessage *) message;
@end
