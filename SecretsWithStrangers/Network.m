//
//  Network.m
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/15/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "Network.h"
#import "GCDAsyncSocket.h"
#import "MessageReader.h"
#import "NetworkMessageWriter.h"
#import "ChatMessage.h"

@interface Network ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSString *lobbyAddress;
@property (nonatomic, strong) NSString *chatServerAddress;
@property (nonatomic) NSInteger chatServerPort;
@property (nonatomic) NSInteger lobbyPort;
@property (nonatomic) NSInteger userID;
@property (nonatomic, strong) NSString *room;

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSMutableDictionary *clients;
@end

@implementation Network

- (id) initWithAddress:(NSString *) address port:(NSInteger) port
{
    self = [super init];
    if (self) {
        self.lobbyAddress = address;
        self.lobbyPort = port;
        self.clients = [@[] mutableCopy];
        self.userID = (arc4random() % NSIntegerMax) + 1;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    }
    return self;
}

- (void) connect
{
    self.networkStatus = kNetworkStatusDisconnected;
    NSLog(@"connecting to %@ %d",self.lobbyAddress, self.lobbyPort);
    NSError *error = nil;
    
    if (![self.socket connectToHost:self.lobbyAddress onPort:self.lobbyPort error:&error])
    {
        NSLog(@"Error connecting: %@",error);
        [self.delegate network:self socketDisconnectedWithStatus:kNetworkStatusConnectionError];
    }
    else
    {
        NSLog(@"Fired up socket");
    }
}

- (void) disconnect
{    
    self.room = @"Lobby";
    self.chatServerAddress = nil;
    self.chatServerPort = 0;
    if([self.socket isConnected])
    {
        [self.socket disconnect];
    }      
}

- (void)sendPlayerConnected {
    
    NetworkMessageWriter * writer = [[NetworkMessageWriter alloc] init];
    [writer writeByte:0];
    [writer writeInt:self.userID];
    NSString *room = self.room ? self.room : @"Lobby";
    [writer writeString:room];
    [writer writeLength];
    
    /*NSUInteger len = [writer.data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [writer.data bytes], len);
    
    for(int i = 0; i < len; i++)
    {
        printf("%d\n",byteData[i]);
    }
    
    NSLog(@"message len %d",[writer.data length]);
    */
    [self.socket writeData:writer.data withTimeout:5 tag:1];
}

- (void) sendMessage:(ChatMessage *) message
{
    NetworkMessageWriter * writer = [[NetworkMessageWriter alloc] init];
    [writer writeByte:2];
    [writer writeByte:message.isSecret];
    [writer writeString:message.text];
    [writer writeLength];
    [self.socket writeData:writer.data withTimeout:5 tag:1];
}

#pragma mark - GCDAsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if(self.networkStatus == kNetworkStatusDisconnected)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate network:self socketConnectedWithStatus:kNetworkStatusInLobby];
        });
        [self sendPlayerConnected];
    }
    else if(self.networkStatus == kNetworkStatusWaitingForRoom)
    {
        self.networkStatus = kNetworkStatusInRoom;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate network:self socketConnectedWithStatus:kNetworkStatusInRoom];
        });
        [self sendPlayerConnected];
    }
    
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    // NOOP
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData * message = [data subdataWithRange:NSMakeRange(4, [data length]-5)];
    [self processMessage:message];    
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    if(!err && self.networkStatus == kNetworkStatusWaitingForRoom)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate network:self socketDisconnectedWithStatus:kNetworkStatusWaitingForRoom];
            
            [self.socket disconnect];
            
            NSError *error = nil;
            if (![self.socket connectToHost:self.chatServerAddress onPort:self.chatServerPort error:&error])
            {
                [self.delegate network:self socketDisconnectedWithStatus:kNetworkStatusConnectionError];
            }
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!err)
            {
                [self.delegate network:self socketDisconnectedWithStatus:self.networkStatus];
            }
            else
            {
                [self.delegate network:self socketDisconnectedWithStatus:kNetworkStatusConnectionError];
            }
        });
    }
}

// Replace processMessage with the following
- (void)processMessage:(NSData *)data {
    MessageReader * reader = [[MessageReader alloc] initWithData:data];
    
    NSUInteger len = [reader.data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [reader.data bytes], len);
    
    for(int i = 0; i < len; i++)
    {
        printf("%d\n",byteData[i]);
    }
    
    unsigned char msgType = [reader readByte];
    if (msgType == 2) { // chat
        NSInteger isSecret = [reader readByte];
        NSString *message = [reader readString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"recieved message(%d) %@",isSecret,message);
            ChatMessage *m = [[ChatMessage alloc] init];
            m.isSecret = isSecret;
            m.messageSenderType = kMessageSenderTypeStranger;
            m.text = message;
            [self.delegate network:self messageRecieved:m];
        });
    }
    else if(msgType == 1) // Player diconnected
    {
        self.networkStatus = kNetworkStatusStrangerDisconnected;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self disconnect];
        });
    }
    else if(msgType == 6) // Chat start
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Start chat");
            [self.delegate network:self socketConnectedWithStatus:kNetworkStatusBeginChat];
        });
    }
    else if(msgType == 5) // room connect
    {                
        self.chatServerPort = [reader readInt];
        self.chatServerAddress = [reader readString];
        self.room = [reader readString];
        NSLog(@"connecting to room %@:%d/%@",self.chatServerAddress,self.chatServerPort,self.room);
        self.networkStatus = kNetworkStatusWaitingForRoom;
        [self.socket disconnect];        
    }
}

@end
