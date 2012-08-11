//
//  DetailViewController.h
//  SecretsWithStrangers
//
//  Created by Brandon Trebitowski on 8/11/12.
//  Copyright (c) 2012 Brandon Trebitowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
