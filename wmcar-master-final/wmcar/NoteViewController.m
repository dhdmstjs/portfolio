//
//  NoteViewController.m
//  wmcar
//
//  Created by Ada on 11/26/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    display.image = [UIImage imageNamed:@"noimage.png"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButton:(id)sender {
}
- (IBAction)cancelButton:(id)sender {
}

- (IBAction)addPhoto:(id)sender {
    pick = [UIImagePickerController new];
    pick.delegate = self;
    [pick setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:pick animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [display setImage:image];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"saveNote"]){
        _model.thisCar = _carField.text;
        _model.thisNumber = _numField.text;
        _model.thisFloor = _floorField.text;
        _model.thisImage = image;
    }
}

- (IBAction)takePhoto:(id)sender {
    picker = [UIImagePickerController new];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
    
}
@end
