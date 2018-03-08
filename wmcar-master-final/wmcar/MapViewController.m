//
//  MapViewController.m
//  wmcar
//
//  Created by Ada on 11/20/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "MapViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface MapViewController () <MKMapViewDelegate, WCSessionDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate> {
    CLLocationManager *locationmanager;
    bool start;
    bool display;
    __weak IBOutlet MKMapView *myMapView;
    int carCount;
    double latitude; //coordinates passed from watchOS
    double longitude;
    BOOL messagePassed; //flag for if watchOS sent info
    BOOL findCar; //if watch presses on Find my Car
    double sourceLatitude; //coordinates of current location from watchOS
    double sourceLongitude;
    BOOL resetPressed; //if button on watchOS pressed after Find The Car for Pinit
}
@end

@implementation MapViewController
MKRoute *routeDetails;
int thepin = -1;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    //check for connectivity with watch
    if ([WCSession isSupported]){
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    //settttttings
    start = YES;
    _city = YES;
    _multi = NO;
    display = NO;
    
    //map
    locationmanager = [CLLocationManager new];
    if([locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationmanager requestWhenInUseAuthorization];
    }
    [myMapView setShowsUserLocation: YES];
    [myMapView setShowsBuildings:YES];
    myMapView.delegate = self;
    locationmanager.delegate = self;
    [locationmanager startUpdatingLocation];
    self.noteModel = [Model new];
    
    //gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    panGesture.delegate = self;
    [myMapView addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pinchGesture.delegate = self;
    [myMapView addGestureRecognizer:pinchGesture];
    
    //car array
    _carArray = [NSMutableArray new];
    _modelArray = [NSMutableArray new];

    _addButton.enabled = NO;
}

- (void)customSetup
{
    _revealButtonItem.target = self.revealViewController;
    _revealButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

/////////////////bottom button
- (IBAction)setPinpoint:(id)sender {
    CLLocationCoordinate2D watchCoordinatesDest = {(latitude),(longitude)}; //coordinates of WatchOS of pinpoint
    CLLocationCoordinate2D watchCoordinatesSource = {(sourceLatitude),(sourceLongitude)}; //coordinates of current location WatchOS
    if([_set.titleLabel.text isEqualToString: @"Set Pinpoint"]){
        if(_city){
            [self performSegueWithIdentifier:@"showNote" sender:nil];
        }else{
            if (messagePassed){ //IF DESTINATION PIN SET IN WATCH
                MKPointAnnotation *pin = [MKPointAnnotation new];
                pin.coordinate = watchCoordinatesDest;
                pin.title = @"My Car";
                [_carArray addObject:pin];
                [myMapView addAnnotation:pin];
                
            }else{ // if pin set from iPhone
                MKPointAnnotation *pin = [MKPointAnnotation new];
                pin.coordinate = myMapView.centerCoordinate;
                pin.title = @"My Car";
                [_carArray addObject:pin];
                [myMapView addAnnotation:pin];
            }
            [myMapView removeAnnotation:_centerAnnotation];
            [_set setTitle:@"Find My Car" forState:UIControlStateNormal];
            if(_multi){
                _addButton.enabled = YES;
            }
        }
        
    }else if([_set.titleLabel.text isEqualToString: @"Find My Car"]){
        if(_multi){
            if(_carArray.count == 1){
                _addButton.enabled = NO;
                //navigate
                thepin = 0;
                NSLog(@"in multi mode with only one pin, requeting directions");
                MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
                MKPointAnnotation *temp = [_carArray objectAtIndex:0];
                if(_city){
                    display = YES;
                    _destination = [[CLLocation alloc] initWithLatitude:temp.coordinate.latitude longitude:temp.coordinate.longitude];
                }
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:temp.coordinate];
                [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
                [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
                [directionsRequest setTransportType: MKDirectionsTransportTypeWalking];
                MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                    if (error) {
                        NSLog(@"Error %@", error.description);
                    } else {
                        NSLog(@"no error");
                        //got the call back
                        routeDetails = response.routes.lastObject;
                        [myMapView addOverlay:routeDetails.polyline];
                    }
                }];
                [_set setTitle:@"Found" forState:UIControlStateNormal];
            }else{
                if(myMapView.selectedAnnotations.count == 0){
                    //if nothing is chosen, alert
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Please select a pin" message:@"You are in multi-pinpoint mode" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                          handler:^(UIAlertAction * action) {}];
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }else{
                    MKPointAnnotation *selected = [myMapView.selectedAnnotations objectAtIndex:0];
                    int tempcount = (int)_carArray.count;
                    for(int i = 0; i < tempcount; i++){
                        MKPointAnnotation *tempcar = [_carArray objectAtIndex:i];
                        if(tempcar.coordinate.latitude == selected.coordinate.latitude && tempcar.coordinate.longitude == selected.coordinate.longitude){
                            thepin = i;
                            break;
                        }
                    }
                    NSLog(@"in multi mode with more than one pin, requeting directions");
                    MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
                    MKPointAnnotation *temp = [_carArray objectAtIndex:thepin];
                    if(_city){
                        display = YES;
                        _destination = [[CLLocation alloc] initWithLatitude:temp.coordinate.latitude longitude:temp.coordinate.longitude];
                    }
                    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:temp.coordinate];
                    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
                    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
                    [directionsRequest setTransportType: MKDirectionsTransportTypeWalking];
                    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
                    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                        if (error) {
                            NSLog(@"Error %@", error.description);
                        } else {
                            NSLog(@"no error");
                            routeDetails = response.routes.lastObject;
                            [myMapView addOverlay:routeDetails.polyline];
                        }
                    }];
                    _addButton.enabled = NO;
                    [_set setTitle:@"Found" forState:UIControlStateNormal];
                }
            }
        }else{ //code this for iPhone and for Watch Case
            thepin = 0;
            NSLog(@"in non multi mode, requeting directions");
            _set.enabled = NO;
            MKDirectionsRequest *directionsRequest = [MKDirectionsRequest new];
            MKPointAnnotation *temp = [_carArray objectAtIndex:0];
            if(_city){
                display = YES;
                _destination = [[CLLocation alloc] initWithLatitude:temp.coordinate.latitude longitude:temp.coordinate.longitude];
            }
            [directionsRequest setTransportType:MKDirectionsTransportTypeWalking];
            //mycode
            if(messagePassed == true){ //if coordinates were sent from the watchOS
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate: watchCoordinatesDest];
                MKPlacemark *sourceplacemark = [[MKPlacemark alloc] initWithCoordinate:watchCoordinatesSource];
                [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
                [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:sourceplacemark]];
            }else{ //if not, the source and destination from app used
                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:temp.coordinate];
                [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
                [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
            }
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Error %@", error.description);
                } else {
                    NSLog(@"no error");
                    //got the call back
                    routeDetails = response.routes.lastObject;
                    [myMapView addOverlay:routeDetails.polyline];
                    NSLog(@"done");
                    _set.enabled = YES;
                }
            }];
            if (findCar){ //if the Find My Car button was pressed through watchOS
                [_set setTitle:@"Found" forState:UIControlStateNormal];
            }
            [_set setTitle:@"Found" forState:UIControlStateNormal];
        }
    }else{
        [myMapView removeOverlay:routeDetails.polyline];
        [myMapView removeAnnotation:[_carArray objectAtIndex:thepin]];
        [_carArray removeObjectAtIndex:thepin];
        thepin = -1;
        NSString *path = [ [NSBundle mainBundle] pathForResource:@"success" ofType:@"wav"];
        
        SystemSoundID theSound;
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSound);
        AudioServicesPlaySystemSound (theSound);
        messagePassed = false; //reset flag
        findCar = false; //reset flag
        if (resetPressed){
            [_set setTitle:@"Set Pinpoint" forState:UIControlStateNormal];
            // if the button was pressed through the watchOS
        }
        if(_carArray.count == 0){
            MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:myMapView.userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(myMapView.userLocation.coordinate.latitude, myMapView.userLocation.coordinate.longitude) eyeAltitude:1000];
            [myMapView setCamera:camera animated:NO];
            [myMapView addAnnotation:_centerAnnotation];
            [_set setTitle:@"Set Pinpoint" forState:UIControlStateNormal];
            _addButton.enabled = NO;
        }else{
            [_set setTitle:@"Find My Car" forState:UIControlStateNormal];
            _addButton.enabled = YES;
        }
        resetPressed = false;
        _destination = nil;
    }
}
///////////end of bottom button



//overlay the route details
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    routeLineRenderer.strokeColor = [UIColor redColor];
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

// + for multi pinpoint
- (IBAction)addPinpoint:(id)sender {
    [_set setTitle:@"Set Pinpoint" forState:UIControlStateNormal];
    [myMapView addAnnotation:_centerAnnotation];
    _addButton.enabled = NO;
}

//zoom in to current location, update user location
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:userLocation.coordinate fromEyeCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude) eyeAltitude:1000];
    [mapView setCamera:camera animated:NO];
    
    if([_set.titleLabel.text isEqualToString: @"Set Pinpoint"] && start){
        MKPointAnnotation *temp = [MKPointAnnotation new];
        temp.coordinate = myMapView.centerCoordinate;
        [myMapView addAnnotation:temp];
        _centerAnnotation = temp;
        start = NO;
    }
    if([_set.titleLabel.text isEqualToString: @"Found"] && _city){
        if([_destination distanceFromLocation:userLocation.location] < 100 && display){
            NSLog(@"distance less than 100m");
            //show the image if implemented
            [self performSegueWithIdentifier:@"displayNote" sender:nil];
        }
    }
}


//move the pin
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    _centerAnnotation.coordinate = mapView.centerCoordinate;
    _centerAnnotation.subtitle = [NSString stringWithFormat:@"%f, %f", _centerAnnotation.coordinate.latitude, _centerAnnotation.coordinate.longitude];
}

//note view
-(IBAction)saveNote:(UIStoryboardSegue *) segue {
    MKPointAnnotation *pin = [MKPointAnnotation new];
    pin.coordinate = myMapView.centerCoordinate;
    pin.title = _noteModel.thisCar;
    pin.subtitle = [NSString stringWithFormat:@"%@, %@", _noteModel.thisFloor, _noteModel.thisNumber];
    [_carArray addObject:pin];
    [myMapView addAnnotation:pin];
    [myMapView removeAnnotation:_centerAnnotation];
    [_set setTitle:@"Find My Car" forState:UIControlStateNormal];
    if(_multi){
        _addButton.enabled = YES;
    }
    Model *temp = _noteModel;
    [_modelArray addObject: temp];
}

-(IBAction)cancelNote:(UIStoryboardSegue *) segue {
}

-(IBAction)backtomap:(UIStoryboardSegue *) segue {
    display = NO;
}
//gesture
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    _centerAnnotation.coordinate = myMapView.centerCoordinate;
    _centerAnnotation.subtitle = [NSString stringWithFormat:@"%f, %f", _centerAnnotation.coordinate.latitude, _centerAnnotation.coordinate.longitude];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showNote"]){
        NoteViewController *noteVC = segue.destinationViewController;
        noteVC.model = self.noteModel;
    }
    
    if([segue.identifier isEqualToString:@"displayNote"]){
        DisplayViewController *VC = segue.destinationViewController;
        Model *newcar = [_modelArray objectAtIndex: thepin];
        VC.car = newcar;
    }
}

//direction
//-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
//    // If it's the user location, just return nil.
//    if ([annotation isKindOfClass:[MKUserLocation class]])
//        return nil;
//    // Handle any custom annotations.
//    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
//        // Try to dequeue an existing pin view first.
//        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[myMapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
//        if (!pinView)
//        {
//            // If an existing pin view was not available, create one.
//            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
//            pinView.canShowCallout = YES;
//        } else {
//            pinView.annotation = annotation;
//        }
//        return pinView;
//    }
//    return nil;
//}

//connectivity

- (void)session:(nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary *)message replyHandler:(nonnull void (^)(NSDictionary * __nonnull))replyHandler {
    NSString *latitudePassed = [message objectForKey:@"latitude"];
    NSString *longitudePasses = [message objectForKey:@"longitude"];
    
    latitude = [latitudePassed doubleValue]; //set to global variable
    longitude = [longitudePasses doubleValue];
    if([latitudePassed doubleValue] == latitude){
        messagePassed = true;
    }
    
    NSString *pressedPassed = [message objectForKey:@"findTheCar"];
    if([pressedPassed  isEqual: @"PRESSED"]){
        findCar = true;
    }
    
    NSString *sourceLatitudePassed = [message objectForKey:@"currentLatitude"];
    NSString *sourceLongitudePassed = [message objectForKey:@"currentLongitude"];
    
    sourceLatitude = [sourceLatitudePassed doubleValue];
    sourceLongitude = [sourceLongitudePassed doubleValue];
    
    NSString *resetTheButton = [message objectForKey:@"PRESSEDRESET"];
    if([resetTheButton isEqualToString:@"PRESSEDRESET"]){
        resetPressed = true;
    }
    if (messagePassed == true && findCar == true){
        [self setPinpoint:nil]; //is this correct?
    }
}

@end
