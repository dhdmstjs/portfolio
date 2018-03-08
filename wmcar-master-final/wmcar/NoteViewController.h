//
//  NoteViewController.h
//  wmcar
//
//  Created by Ada on 11/26/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Model.h"

@interface NoteViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *picker;
    UIImagePickerController *pick;
    UIImage *image;
    IBOutlet UIImageView *display;
}
- (IBAction)takePhoto:(id)sender;
- (IBAction)addPhoto:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *carField;
@property (strong, nonatomic) Model *model;
@property (weak, nonatomic) IBOutlet UITextField *floorField;
@property (weak, nonatomic) IBOutlet UITextField *numField;


@end
