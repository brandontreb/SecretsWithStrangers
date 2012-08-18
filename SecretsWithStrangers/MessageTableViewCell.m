//
//  MessageTableViewCell.m
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/11/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "Message.h"

@interface MessageTableViewCell()
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *messageLabel;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@end

@implementation MessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if(self.message.messageSenderType == kMessageSenderTypeMe)
    {
        self.nameLabel.text = @"me";
        self.nameLabel.textColor = [UIColor darkGrayColor];
    }
    else
    {
        self.nameLabel.text = @"stranger";
        self.nameLabel.textColor = [UIColor colorWithRed:.15 green:.3 blue:.51 alpha:1.0];
    }
    
    NSString *text = self.message.text;
    NSMutableString *spaces = [NSMutableString string];
    int spaceCount = [self.nameLabel.text isEqualToString:@"me"] ? 6 : 15;
    for(int i = 0; i < spaceCount; i++)
    {
        [spaces appendString:@" "];
    }
    
    // Name
    text = [NSString stringWithFormat:@"%@%@",spaces,text];
    CGSize nameSize = [self.nameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0]];
    CGRect nameFrame = self.nameLabel.frame;
    nameFrame.size = nameSize;
    self.nameLabel.frame = nameFrame;
    
    // Message
    CGRect messageFrame = self.messageLabel.frame;
    messageFrame.origin.x = nameFrame.origin.x;
    CGSize messageSize = [self.message.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(240, 10000) lineBreakMode:UILineBreakModeWordWrap];

    messageFrame.size = messageSize;
    float minWidth = 320 - 40 - nameFrame.size.width;
    float minHeight = ([@"word" sizeWithFont:[UIFont systemFontOfSize:14]]).height;
    if(messageFrame.size.width < minWidth)
    {
        messageFrame.size.width = minWidth;
    }
    
    if (messageFrame.size.height < minHeight) {
        messageFrame.size.height = minHeight;
    }
    
    self.messageLabel.text = text;
    self.messageLabel.frame = messageFrame;
    
    // Time
    CGRect timeFrame = self.timeLabel.frame;
    timeFrame.origin.y = messageFrame.origin.y + messageFrame.size.height;
    self.timeLabel.frame = timeFrame;
    self.timeLabel.text = self.message.time;
    
    /*NSString *text = _message.text;
	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(200.0f, 480.0f) lineBreakMode:UILineBreakModeWordWrap];   
	UIImage *balloon = nil;
    
    if (self.message.messageSenderType == kMessageSenderTypeMe)
    {
        balloon = [[UIImage imageNamed:@"grey.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:15];
        self.label.frame = CGRectMake(16, 8, size.width + 5, size.height);
        self.imageView.frame = CGRectMake(0.0, 2.0, size.width + 28, size.height + 15);

    }
    else
    {
        balloon = [[UIImage imageNamed:@"blue.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        self.imageView.frame = CGRectMake(320.0f - (size.width + 28.0f), 2.0f, size.width + 28.0f, size.height + 15.0f);
        self.label.frame = CGRectMake(307.0f - (size.width + 5.0f), 8.0f, size.width + 5.0f, size.height);
    }
    
	self.imageView.image = balloon;
    self.label.text = self.message.text;
     */
}

@end
