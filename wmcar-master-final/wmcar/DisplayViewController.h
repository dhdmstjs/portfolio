//
//  DisplayViewController.h
//  wmcar
//
//  Created by Ada on 12/20/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface DisplayViewController : UIViewController

@property (strong, nonatomic) Model *car;
@property (strong, nonatomic) IBOutlet UILabel *floor;
@property (strong, nonatomic) IBOutlet UILabel *carname;
@property (strong, nonatomic) IBOutlet UILabel *num;
@property (strong, nonatomic) IBOutlet UIImageView *image;

@end
