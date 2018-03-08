//
//  InterfaceController.m
//  wmcarWK Extension
//
//  Created by Daniela Oh on 12/12/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "InterfaceController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKFoundation.h>
#import <MapKit/MKPlacemark.h>

@interface InterfaceController()<CLLocationManagerDelegate>{
    __unsafe_unretained IBOutlet WKInterfaceMap *myMapView;
    CLLocationManager *locationmanager;
    CLLocation *location_1;
    CLLocationCoordinate2D coordinate_1;
    CLLocationCoordinate2D mapLocation_1;
    int count; //set count for number of times button pressed.
}
@end


@implementation InterfaceController


- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    // Configure interface objects here.
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    CLLocation *location = [self.locationManager location];
    location_1 = location;
    CLLocationCoordinate2D coordinate = [location coordinate];
    coordinate_1 = coordinate; //latitude longitude coordinates current location -> destination
    
    CLLocationCoordinate2D mapLocation = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
    mapLocation_1 = mapLocation;
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(.1, .1);
    [self->myMapView setRegion:(MKCoordinateRegionMake(mapLocation, coordinateSpan))];
    
    count = 0; //when app is opened set count to 0
    
    //check if watchConnectivity works
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        NSLog(@"WCSession is supported");
    }
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate: CLLocationCoordinate2DMake(coordinate_1.longitude, coordinate_1.longitude)];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem openInMapsWithLaunchOptions:nil];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}


- (IBAction)setPinpoint {
    count +=1;
    if (count ==1){ //set the pinpoint and send coordinates to App
        [_set setTitle: @"Find My Car"];
        [self->myMapView addAnnotation:mapLocation_1 withPinColor: WKInterfaceMapPinColorPurple];
        NSString *latitude = [NSString stringWithFormat:@"%f", coordinate_1.latitude];
        NSString *longitude = [NSString stringWithFormat:@"%f", coordinate_1.longitude];
        NSDictionary *theCoordinates = [[NSDictionary alloc] initWithObjects:@[latitude, longitude] forKeys:@[@"latitude", @"longitude"]];
        [[WCSession defaultSession] sendMessage:theCoordinates replyHandler:^(NSDictionary *reply){
            NSLog(@"Positive");
        }
                                   errorHandler:^(NSError *error){
                                       NSLog(@"Negative");
                                   }];
        
    }
    if (count == 2){ //find car from current location to destination
        CLLocation *currentLocation = [self.locationManager location];
        CLLocationCoordinate2D currentCoordinates = [currentLocation coordinate];
        
        NSString *currentLatitude = [NSString stringWithFormat:@"%f", currentCoordinates.latitude];
        NSString *currentLongitude = [NSString stringWithFormat:@"%f", currentCoordinates.longitude];
        NSString *pressed = @"PRESSED";
        NSDictionary *buttonPressed = [[NSDictionary alloc] initWithObjects:@[pressed, currentLatitude, currentLongitude] forKeys:@[@"findTheCar", @"currentLatitude", @"currentLongitude"]];
        [[WCSession defaultSession] sendMessage:buttonPressed replyHandler:^(NSDictionary *reply){
            NSLog(@"Positive");
        }
                                   errorHandler:^(NSError *error){
                                       NSLog(@"Negative");
                                   }];
        
        [_set setTitle: @"Found"];
        
    }
    if(count == 3){ //reset button
        count = 0;
        NSString *pressedReset = @"PRESSEDRESET";
        NSDictionary *resetPressed = [[NSDictionary alloc] initWithObjects:@[pressedReset] forKeys:@[@"PRESSEDRESET"]];
        [[WCSession defaultSession] sendMessage:resetPressed replyHandler:^(NSDictionary *reply){
            NSLog(@"Positive");
        }
                                   errorHandler:^(NSError *error){
                                       NSLog(@"Negative");
                                   }];
        
        [_set setTitle:@"Pin It"];
        
    }
    
    
}

//

//    CLLocationCoordinate2D watchCoordinatesDest = {(latitude),(longitude)}; //coordinates of WatchOS of pinpoint

@end



