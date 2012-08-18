//
//  MasterViewController.m
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/11/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "MasterViewController.h"
#import "ChatViewController.h"
#import "Network.h"
#import "ChatMessage.h"
#import <MessageUI/MessageUI.h>

static NSString *kServerAddress = @"192.168.1.149";
static NSInteger kServerPort = 1956;

@interface MasterViewController () <NetworkDelegate,MFMailComposeViewControllerDelegate>
@property(nonatomic,weak) IBOutlet UIImageView *frontBackgroundImageView;
@property(nonatomic,weak) IBOutlet UITextView *secretTextView;
@property(nonatomic,weak) IBOutlet UILabel *statusLabel;
@property(nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) Network *network;
@property(nonatomic, strong) UIBarButtonItem *connectButton;
@property(nonatomic, strong) UIBarButtonItem *feedbackButton;
@property(nonatomic, strong) NSTimer *timeoutTimer;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Left feedback button
    UIImage *fimage = [UIImage imageNamed:@"feedback-button.png"];
    UIButton* fbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    fbutton.frame = CGRectMake(0, 0, 75, 30);
    [fbutton setBackgroundImage:fimage forState:UIControlStateNormal];
    
    self.feedbackButton = [[UIBarButtonItem alloc] initWithCustomView:fbutton];
    [self.feedbackButton setTarget:self];
    [self.feedbackButton setAction:@selector(feedback:)];
    [fbutton addTarget:self action:@selector(feedback:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = self.feedbackButton;
    
    // Right connect button
    UIImage *image = [UIImage imageNamed:@"connect-button.png"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 75, 30);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    self.connectButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.connectButton setTarget:self];
    [self.connectButton setAction:@selector(connect:)];
    [button addTarget:self action:@selector(connect:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = self.connectButton;
    
    
    //UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonSystemItemAdd target:self action:@selector(connect:)];
    //self.navigationItem.rightBarButtonItem = item;
    
    UINavigationBar *toolbar = self.navigationController.navigationBar;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 4.9) {
        
        //iOS 5
        UIImage *toolBarIMG = [UIImage imageNamed: @"Toolbar.png"];
        
        if ([toolbar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            [toolbar setBackgroundImage:toolBarIMG forBarMetrics:UIBarMetricsDefault];
        }
        
    } else {  
        //iOS 4
        [toolbar addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Toolbar.png"]]];
    }
    
    self.frontBackgroundImageView.image = [UIImage imageNamed:@"Front-Background.png"];
    
    self.title = @"Secrets";
    
    self.network = [[Network alloc] initWithAddress:kServerAddress port:kServerPort];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.statusLabel.hidden = NO;
    self.statusLabel.text = @"Disconnected";
    self.connectButton.enabled = YES;
    self.network.delegate = self;
    [self.network disconnect];
    [self.secretTextView becomeFirstResponder];
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }*/
}

- (void) feedback:(id) sender
{
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    mailViewController.mailComposeDelegate = self;
    [mailViewController setSubject:@"Secrets With Strangers Feedback"];
    [mailViewController setToRecipients:@[@"secretswithstrangers@gmail.com"]];
    [self presentModalViewController:mailViewController animated:YES];
}

- (void)connect:(id) sender
{
    if([self.secretTextView.text length] < 8)
    {
        self.statusLabel.text = @"Please enter a secret to continue!";
        self.statusLabel.hidden = NO;
        return;
    }    
    
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(timeout:) userInfo:nil repeats:NO];
    
    self.connectButton.enabled = NO;
    [self.secretTextView resignFirstResponder];
    [self.activityIndicator startAnimating];
    self.statusLabel.text = @"Finding Stranger...";
    self.statusLabel.hidden = NO;
    
    [self.network connect];
}

- (void) timeout:(NSTimer *) timer
{
    self.connectButton.enabled = YES;
    self.network.networkStatus = kNetworkStatusStrangerNotFound;
    [self.network disconnect];
    [self.secretTextView becomeFirstResponder];
    [self.activityIndicator stopAnimating];
}

#pragma mark - Network Delegate

- (void) network:(Network *)network socketConnectedWithStatus:(NetworkStatus)networkStatus
{
    if(networkStatus == kNetworkStatusInLobby)
    {
        NSLog(@"lobby");
        self.statusLabel.text = @"Finding stranger...";
    }
    else if(networkStatus == kNetworkStatusInRoom)
    {
        NSLog(@"in room");
        self.statusLabel.text = @"Waiting for stranger...";
    }
    else if(networkStatus == kNetworkStatusBeginChat)
    {
        [self.timeoutTimer invalidate];
        // Build secret message
        NSString *secret = self.secretTextView.text;
        ChatMessage *message = [[ChatMessage alloc] init];
        message.isSecret = YES;
        message.text = secret;
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"hh:mma" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        message.time = [formatter stringFromDate:[NSDate date]];
        
        // Push chat view
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        ChatViewController *cvc = [storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
        cvc.network = self.network;
        cvc.secret = message;
        self.network.delegate = cvc;
        [self.navigationController pushViewController:cvc animated:YES];
        
        // Send secret
        [self.network sendMessage:message];        
    }
}

- (void) network:(Network *)network socketDisconnectedWithStatus:(NetworkStatus)networkStatus
{
    NSLog(@"Disconnected with status %d", networkStatus);
    if(networkStatus == kNetworkStatusConnectionError)
    {
        self.connectButton.enabled = YES;
        [self.activityIndicator stopAnimating];
        self.statusLabel.text = @"Unable to connect to the server.";
    }
    else if(networkStatus == kNetworkStatusWaitingForRoom)
    {
        self.statusLabel.text = @"Waiting for stranger...";
    }
    else if(networkStatus == kNetworkStatusStrangerNotFound)
    {
        self.statusLabel.text = @"Unable to find strager, try again.";
        self.network.networkStatus = kNetworkStatusDisconnected;
    }
    else
    {
        self.connectButton.enabled = YES;
        [self.activityIndicator stopAnimating];
        self.statusLabel.text = @"Disconnected.";
    }
}

- (void) network:(Network *)network messageRecieved:(ChatMessage *)message
{
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
