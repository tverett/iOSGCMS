//
//  ViewController.h
//  cgms
//
//  Created by Donald Browne on 11/1/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFduinoDelegate.h"
#import "RFduino.h"

@interface AppViewController : UIViewController<RFduinoDelegate>
@property (weak, nonatomic) IBOutlet UITextField *glucose;
@property (weak, nonatomic) IBOutlet UIButton *getGlucose;

@property(nonatomic, strong) RFduino *rfduino;
// Properties for your Object controls
//
-(void)sendByte:(uint8_t)byte;
@end

