//
//  ViewController.m
//  cgms
//
//  Created by Donald Browne on 11/1/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppViewController.h"
#import <PebbleKit/PebbleKit.h>

@interface AppViewController ()

@end

@implementation AppViewController
@synthesize rfduino;

static int GLUCOSE=0x01;
static int GLUCOSE_FILT=0x02;
static int RAWCOUNT=0x03;
static int RAWCOUNT_FILT=0x04;
static int SLOPE=0x05;
static int INTERCEPT=0x06;
static int BTLE_BATTERY=0x07;
static int BTLE_RSSI=0x08;
static int TRANSMITTER_ID=0x09;
static int TRANSMITTER_BATTERY=0x0A;
static int TRANSMITTER_RSSI=0x0B;
static int SECONDS_SINCE_READING=0x0C;
static int CAL_GLUCOSE=0x0D;
static int NEW_SENSOR=0x0E;
static int TRANSMITTER_FULL_PACKET=0x0F;
static int RESET=0x10;

PBWatch *_targetWatch;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    rfduino.delegate = self;
    
    self.glucose.text = @"0";
    [self sendByte:GLUCOSE];
    
    //setup timer to check request glucose from rfduino every minute
    [NSTimer scheduledTimerWithTimeInterval:60 target:(self) selector:@selector(requestGlucose) userInfo:nil repeats:YES];
    
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    // Initialize with the last connected watch:
    //[self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
}
//
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendByte:(uint8_t)byte
{
    uint8_t tx[1] = { byte };
    NSData *data = [NSData dataWithBytes:(void*)&tx length:1];
    [rfduino send:data];
}

- (IBAction)handleButtonClick:(id)sender {
    NSLog(@"Handle Button Click");
    [self sendByte:GLUCOSE];
}

-(void)requestGlucose
{
    [self sendByte:GLUCOSE];
}



- (void)didReceive:(NSData *)data
{
    NSLog(@"RecievedData");
    
    const uint8_t *value = [data bytes];
    int len = [data length];
    
    
    NSLog(@"Length = %x", len);
   
    NSLog(@"value = %i", value[0]);
    NSLog(@"value = %i", value[1]);
    NSLog(@"value = %i", value[2]);
    NSLog(@"value = %i", value[3]);    //if (value[0])
    
    if(value[0]==GLUCOSE){
        int number = value[1] | value[2] << 8;
        NSString* gluc = [NSString stringWithFormat:@"%i", number];
        self.glucose.text=gluc;
        
        //pebble
        // Initialize with the last connected watch:
        [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
        
        // Send data to watch:
        // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definitions on the watch's end:
        
        // NSURLConnection's completionHandler is called on the background thread.
        // Prepare a block to show an alert on the main thread:
        __block NSString *message = @"";
        void (^showAlert)(void) = ^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        };
        
        //NSNumber *iconKey = @(0); // This is our custom-defined key for the icon ID, which is of type uint8_t.
        NSNumber *glucoseKey = @(1); // This is our custom-defined key for the glucose string.
        NSDictionary *update = @{ glucoseKey:[NSString stringWithFormat:@"%d", number] };
        [_targetWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
            message = error ? [error localizedDescription] : @"Update sent!";
            //showAlert();
        }];
    }
    
}



//pebble
- (void)setTargetWatch:(PBWatch*)watch {
    _targetWatch = watch;
    
    // NOTE:
    // For demonstration purposes, we start communicating with the watch immediately upon connection,
    // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
    // Real world apps should communicate only if the user is actively using the app, because there
    // is one communication session that is shared between all 3rd party iOS apps.
    
    // Test if the Pebble's firmware supports AppMessages / Weather:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            // Configure our communications channel to target the weather app:
            // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definition on the watch's end:
            uint8_t bytes[] = {0x7f, 0x7a, 0x38, 0x90, 0x1a, 0x1c, 0x43, 0xa3, 0xad, 0xF1, 0x21, 0x44, 0x9e, 0x4f, 0x35, 0x2d};
            
            //7f 7a 38 90-1a 1c-43 a3-ad f1-21 44 9e 4f 35 2d
            
            NSData *uuid = [NSData dataWithBytes:bytes length:sizeof(bytes)];
            [[PBPebbleCentral defaultCentral] setAppUUID:uuid];
            
            NSLog(@"Connected to Pebble");
           // NSString *message = [NSString stringWithFormat:@"Yay! %@ supports AppMessages :D", [watch name]];
           // [[[UIAlertView alloc] initWithTitle:@"Connected!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            
            NSString *message = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

/*
 *  PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"DisConnected from Pebble");
    //[[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    //if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
     //   [self setTargetWatch:nil];
   // }
}



@end
