//
//  InterfaceController.h
//  wmcarWK Extension
//
//  Created by Ada on 12/12/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (strong, nonatomic) IBOutlet WKInterfaceButton *set;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *destination;
@end
