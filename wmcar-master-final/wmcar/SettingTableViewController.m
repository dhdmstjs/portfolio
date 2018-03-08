//
//  SettingTableViewController.m
//  wmcar
//
//  Created by Ada on 11/21/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "SettingTableViewController.h"
#import "SWRevealViewController.h"
#import "MapViewController.h"

@interface SettingTableViewController ()

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MapViewController *front = [self.revealViewController.frontViewController.childViewControllers objectAtIndex:0];
    [_cityswitch setOn:front.city];
    [_multiswitch setOn: front.multi];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)changecity:(id)sender {
    MapViewController *front = [self.revealViewController.frontViewController.childViewControllers objectAtIndex:0];
    if([front.carArray count] == 0){
        front.city = !front.city;
    }else{
        [_cityswitch setOn:front.city];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please clear your pin" message:@"clear your pin before changing mode" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
- (IBAction)changemulti:(id)sender {
    MapViewController *front = [self.revealViewController.frontViewController.childViewControllers objectAtIndex:0];
    if([front.carArray count] == 0){
        front.multi = !front.multi;
    }else{
        [_multiswitch setOn:front.multi];
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please clear your pin" message:@"clear your pin before changing mode" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 
    if ( [sender isKindOfClass:[UITableViewCell class]] )
    {
        SWRevealViewControllerSegueSetController *swSegue = (SWRevealViewControllerSegueSetController*) segue;
        swSegue.perform
        
    }
    
}
*/
@end
