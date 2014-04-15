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
@property (copy, nonatomic) NSMutableString *dlna_name;
@property (weak, nonatomic) IBOutlet UITextField *rename_field;
@property (strong, nonatomic) NSMutableDictionary *strs;  //Add for multi languages.  @Jeanne.  2014.03.13
@property (copy, nonatomic) NSMutableString *IsinDemomode;//Add for demo mode.  @Jeanne. 2014.04.04

-(IBAction)AboutButtonPressed;
//-(IBAction)WifiButtonPressed;  //move to tab menu.  @Jeanne. 2014.03.03
-(IBAction)SWupdateButtonPressed;
-(IBAction)SaveButtonPressed;
-(IBAction)CancelButtonPressed;
-(IBAction)dlnaRenameButtonPressed;
-(IBAction)textFieldDoneEditing:(id)sender;
-(IBAction)RescanPressed;
-(void) SWUpdate;
-(void) decodedlna_response:(NSString *)response;
@end
