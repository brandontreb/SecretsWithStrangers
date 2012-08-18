//
//  ChatViewController.m
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/11/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import "ChatViewController.h"
#import "Message.h"
#import "MessageTableViewCell.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
@property(nonatomic, strong) NSMutableArray *messages;
@property(nonatomic, weak) IBOutlet UIImageView *toolbarView;
@property(nonatomic, weak) IBOutlet UITextField *textField;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;
@property(nonatomic) BOOL showKeyboard;
- (IBAction)sendButtonPressed:(id)sender;
@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _messages = [@[] mutableCopy];

    // Test messages
    /*for(int x = 0; x < 18;x++)
    {
        Message *m = [[Message alloc] init];
        m.text = [NSString stringWithFormat:@"My Secret: I farted in church and pointed to my wife. it was very funny and this should take up multiple lines." ];
        m.messageSenderType = x % 2;
        
        NSDate *myDate = [NSDate date];
        m.time = [formatter stringFromDate:myDate];
        
        [self.messages addObject:m];
    }*/
    
    // Custom back button
    
    UIImage *image = [UIImage imageNamed:@"secrets-button.png"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 62, 30);
    [button setBackgroundImage:image forState:UIControlStateNormal];
    
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = connectButton;
    
    self.toolbarView.image = [UIImage imageNamed:@"Toolbar-Bottom.png"];
    self.title = @"Stranger";
    [self registerKeyboardNotifications];
    
    NSLocale *locale = [NSLocale currentLocale];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"hh:mma" options:0 locale:locale];
    [self.dateFormatter setDateFormat:dateFormat];
    [self.dateFormatter setLocale:locale];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.messages addObject:self.secret];
}

- (void) back:(id) sender
{
    [self unregisterKeyboardNotifications];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)registerKeyboardNotifications {
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect kbFrameBeginFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect kbFrameEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    NSLog(@"\nShow:Frame Begin = %@\nFrame End = %@\nAnimation Duration = %f\nAnimation Curve = %i",
          NSStringFromCGRect(kbFrameBeginFrame), NSStringFromCGRect(kbFrameEndFrame), animDuration, animCurve);
    
    _showKeyboard = YES;
    [self adjustUIForKeyboard:kbFrameEndFrame.size animDuration:animDuration];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGRect kbFrameBeginFrame = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect kbFrameEndFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animCurve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    NSLog(@"\nHide:Frame Begin = %@\nFrame End = %@\nAnimation Duration = %f\nAnimation Curve = %i",
          NSStringFromCGRect(kbFrameBeginFrame), NSStringFromCGRect(kbFrameEndFrame), animDuration, animCurve);
    
    _showKeyboard = NO;
    [self adjustUIForKeyboard:kbFrameEndFrame.size animDuration:animDuration];
}

/**
 * Adjust the UI elements so that views are visible when keyboard is visible or hidden
 */
- (void)adjustUIForKeyboard:(CGSize)keyboardSize animDuration:(NSTimeInterval)duration {        
    
    [UIView animateWithDuration:duration
                     animations:^(void) {
                         // When keyboard is showing we adjust up and vice versa for a hidden keyboard
                         if (_showKeyboard) {
                             // Set your view's frame values
                             CGRect toolbarFrame = self.toolbarView.frame;
                             toolbarFrame.origin.y = keyboardSize.height-60;
                             self.toolbarView.frame = toolbarFrame;
                             
                             CGRect tableFrame = self.tableView.frame;
                             tableFrame.size.height = 480 - 44 - 44 - 20 - keyboardSize.height;
                             self.tableView.frame = tableFrame;
                             
                         } else {
                             // Set your view's frame values
                             CGRect toolbarFrame = self.toolbarView.frame;
                             toolbarFrame.origin.y = 480 - 44 - 44 - 20;
                             self.toolbarView.frame = toolbarFrame;
                             
                             CGRect tableFrame = self.tableView.frame;
                             tableFrame.size.height = 480 - 44 - 44 - 20;
                             self.tableView.frame = tableFrame;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self scrollToBottom];
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MessageTableViewCell *cell = (MessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	Message *message = self.messages[indexPath.row];
    cell.message = message;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *body = [[self.messages objectAtIndex:indexPath.row] text];
	CGSize size = [body sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:CGSizeMake(240.0, 480.0) lineBreakMode:UILineBreakModeWordWrap];
    
    float minHeight = ([@"word" sizeWithFont:[UIFont systemFontOfSize:14]]).height;    
	return ((size.height > minHeight) ? size.height : minHeight) + 24;
}

- (IBAction)sendButtonPressed:(id)sender
{
    if([self.textField.text isEqualToString:@""])
    {
        NSLog(@"RETURN");
        return;
    }        
    
    // Create message
    Message *message = [[Message alloc] init];
    message.text = self.textField.text;
    message.messageSenderType = kMessageSenderTypeMe;
    message.time = [self.dateFormatter stringFromDate:[NSDate date]];
    [self.messages addObject:message];
    [self.tableView reloadData];    
    [self.textField setText:@""];
    
    [self.network sendMessage:message];
    [self scrollToBottom];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self sendButtonPressed:self];
    return YES;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Network Delegate

- (void) network:(Network *)network socketConnectedWithStatus:(NetworkStatus)networkStatus
{
    NSLog(@"Connected with status %d", networkStatus);
    if(networkStatus == kNetworkStatusInLobby)
    {
        
    }
    else if(networkStatus == kNetworkStatusInRoom)
    {
        
    }
}

- (void) network:(Network *)network socketDisconnectedWithStatus:(NetworkStatus)networkStatus
{
    NSLog(@"Disconnected with status %d", networkStatus);
    if(networkStatus == kNetworkStatusConnectionError)
    {
        
    }
    else if(networkStatus == kNetworkStatusWaitingForRoom)
    {
        
    }
    else
    {
        
    }    
}

- (void) network:(Network *)network messageRecieved:(Message *)message
{
    message.time = [self.dateFormatter stringFromDate:[NSDate date]];
    [self.messages addObject:message];
    [self.tableView reloadData];
    [self scrollToBottom];
}

- (void) scrollToBottom
{
    if([self.messages count] < 1) return;
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: [self.messages count]-1 inSection: 0];
    [self.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
}

@end
