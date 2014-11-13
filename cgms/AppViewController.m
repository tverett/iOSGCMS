//
//  ViewController.m
//  cgms
//
//  Created by Donald Browne on 11/1/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppViewController.h"


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    rfduino.delegate = self;
    
    self.glucose.text = @"0";
    [self sendByte:GLUCOSE];
    [NSTimer scheduledTimerWithTimeInterval:60 target:(self) selector:@selector(send) userInfo:nil repeats:YES];
}

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
    //self.glucose.text = @"666";
    //71 is G for glucose
    [self sendByte:GLUCOSE];
    
    //[NSTimer scheduledTimerWithTimeInterval:60 target:(self) selector:@selector(send) userInfo:nil repeats:YES];
    
}

-(void)send
{
    [self sendByte:GLUCOSE];
    //[timer invalidate];
}


- (void)didReceive:(NSData *)data
{
    NSLog(@"RecievedData");
    
    const uint8_t *value = [data bytes];
    int len = [data length];
    
    
    NSLog(@"value = %x", len);
    
    //if first char is a G
    
    
    NSLog(@"value = %i", value[0]);
    NSLog(@"value = %i", value[1]);
    NSLog(@"value = %i", value[2]);
    NSLog(@"value = %i", value[3]);    //if (value[0])
    
    if(value[0]==GLUCOSE){
        int number = value[1] | value[2] << 8;
        NSString* gluc = [NSString stringWithFormat:@"%i", number];
        self.glucose.text=gluc;
    }
    
    
    //    [image1 setImage:on];
    //else
    //    [image1 setImage:off];
}



@end
