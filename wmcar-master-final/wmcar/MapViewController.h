//
//  MapViewController.h
//  wmcar
//
//  Created by Ada on 11/20/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SWRevealViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Model.h"
#import "NoteViewController.h"
#import "SettingTableViewController.h"
#import "DisplayViewController.h"

@interface MapViewController : UIViewController 
@property (nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *set;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, assign) Boolean city;
@property (nonatomic, assign) Boolean multi;
@property (strong, nonatomic) Model *noteModel;
@property (nonatomic, retain) MKPointAnnotation *centerAnnotation;
@property (strong, nonatomic) NSMutableArray *carArray;
@property (strong, nonatomic) NSMutableArray *modelArray;
@property (strong, nonatomic) CLLocation *destination;

//implement the destination when the user chooses a pin in city mode
//release it when pressed FOUND



@end
