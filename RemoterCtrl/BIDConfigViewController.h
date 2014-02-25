//
//  BIDConfigViewController.h
//  RemoterCtrl
//
//  Created by 张巧玲 on 2/10/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDSubViewController.h"

@interface BIDConfigViewController : UIViewController <UIAlertViewDelegate>

@property (copy, nonatomic) NSMutableString *wifiSetFlag;
@property (copy, nonatomic) NSMutableString *wifiSettingUrl;
@property (copy, nonatomic) NSMutableString *toMagicUrl;

-(IBAction)AboutButtonPressed;
-(IBAction)WifiButtonPressed;
-(IBAction)SWupdateButtonPressed;
-(void) SWUpdate;
@end
