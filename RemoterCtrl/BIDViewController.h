//
//  BIDViewController.h
//  RemoterCtrl
//
//  Created by 张巧玲 on 1/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDMenuProperty.h"
#import "BIDSubViewController.h"
#import "BIDConfigViewController.h"
#import "BIDPlayViewController.h"
#import "UPnPDB.h"
#import "ILHTTPClient.h"
#import "BIDUIDevice.h"

@interface BIDViewController : UIViewController <UPnPDBObserver,UITabBarDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray *mDevices; //BasicUPnPDevice*
    ILHTTPClient *client;   // http client
    NSMutableString *MagicUrl;
    NSMutableArray *mSSDPObjCDevices;  //basic ssdp device
    NSString *RESCAN;
}


@property (strong, nonatomic) BIDMenuProperty *menuProperty;
@property (strong, nonatomic) BIDSubViewController *subViewController;
@property (strong, nonatomic) BIDConfigViewController *configViewController;
@property (copy, nonatomic) NSMutableString *wifiSettingUrl;
@property (copy, nonatomic) NSMutableString *CuriosDevice; //Add for support multi ios device.  @Jeanne. 2014.03.21
@property (strong, nonatomic) NSMutableDictionary *strs;  //Add for multi languages.  @Jeanne.  2014.03.13
@property (copy, nonatomic) NSArray *supportlanguages; //Add for multi languages.  @Jeanne.  2014.03.13
@property (copy, nonatomic) NSMutableString *IsinDemomode;//Add for demo mode.  @Jeanne. 2014.04.04

//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender;
-(void)UPnPDBUpdated:(UPnPDB*)sender;
-(void)initMenu;
-(void)initlanguage;
-(void)initProperties;
-(void) decode_response:(NSString *)response Forcmd: (NSInteger)cmd Forpos:(NSInteger)pos;
-(void)searchip;
-(void)Rescandevice;
//-(void)passSelf:(id)sender;  //test control parent.  @Jeanne
@end
