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

@interface BIDViewController : UIViewController <UPnPDBObserver,UITabBarDelegate>
{
    NSArray *mDevices; //BasicUPnPDevice*
    ILHTTPClient *client;   // http client
    NSMutableString *MagicUrl;
}


@property (strong, nonatomic) BIDMenuProperty *menuProperty;
@property (strong, nonatomic) BIDSubViewController *subViewController;
@property (strong, nonatomic) BIDConfigViewController *configViewController;

//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender;
-(void)UPnPDBUpdated:(UPnPDB*)sender;
-(void)initMenu;
-(void)decode_response:(NSString *)response Forcmd: (NSInteger)cmd;
-(void)searchip;


@end
