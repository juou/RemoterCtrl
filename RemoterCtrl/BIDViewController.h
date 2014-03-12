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

@interface BIDViewController : UIViewController <UPnPDBObserver,UITabBarDelegate,UITableViewDataSource,UITableViewDelegate>
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

//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender;
-(void)UPnPDBUpdated:(UPnPDB*)sender;
-(void)initMenu;
-(void) decode_response:(NSString *)response Forcmd: (NSInteger)cmd Forpos:(NSInteger)pos;
-(void)searchip;
-(void)Rescandevice;

@end
