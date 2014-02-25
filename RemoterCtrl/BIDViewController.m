//
//  BIDViewController.m
//  RemoterCtrl
//
//  Created by 张巧玲 on 1/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import "BIDViewController.h"
#import "UIImageView+AFNetworking.h"
#import <string.h>
#import "ILHTTPClient.h"
#import "BIDSubViewController.h"
#import "UPnPManager.h"

#define kMagic_Device   @":52525/root_XXYY.xml"
#define kMagic_Device_2   @":52525/root_XXYY_S.xml"

#define kMain_Tabbar_tag       5
#define kShow_Label_tag        9
#define kVer_Label_tag         10

static NSMutableString *m_id;





@implementation BIDViewController

-(void) decode_response:(NSString *)response Forcmd: (NSInteger)cmd
{
    char *p;
    char id[4],url[50];
    const char *str = [response UTF8String];
    memset(id, 0, sizeof(id));
    memset(url, 0, sizeof(url));
    int i;
    NSInteger result;
    
    //Get menu id
    p =strstr(str, "<id>");
    if(p)
    {
        for (int i = 4; (p[i]!=0)&&(p[i]!='<'); i++) {
            id[i-4] = p[i];
        }
    }
    
    NSString *menuid=[NSString stringWithCString:id encoding:NSUTF8StringEncoding];
    NSLog(@"Menuid=%@",menuid);
    
    [m_id setString:menuid];
    
    //Get wifi set url
    p =strstr(str, "<wifi_set_url>");
    if(p)
    {
        for (int i = 14; (p[i]!=0)&&(p[i]!='<'); i++) {
            url[i-14] = p[i];
        }
    }
    NSString *wifiurl = [NSString stringWithCString:url encoding:NSUTF8StringEncoding];
    self.configViewController.wifiSettingUrl = [wifiurl mutableCopy];
    NSLog(@"wifiSetUrl: %@",self.configViewController.wifiSettingUrl);
    
    //init result
    result = 1;
    
    //将.分隔的字符串转换成数组
	NSArray *array1 = [self.configViewController.wifiSettingUrl componentsSeparatedByString:@"."];
	//NSLog(@"array1:%@",array1);
    
    //将.分隔的字符串转换成数组
	NSArray *array2 = [MagicUrl componentsSeparatedByString:@"."];
	//NSLog(@"array2:%@",array2);
    
    if (([array1 count] < 3)||([array2 count] < 3)){
        result = 0;
    }
    else{
        NSString *astring1;
        NSString *astring2;
        for (i=0; i<3; i++) {
           astring1 = [array1 objectAtIndex:i];
           astring2 = [array2 objectAtIndex:i];
           //NSLog(@"str1:%@\nstr2:%@\n",astring1,astring2);
            
            if ([astring1 caseInsensitiveCompare:astring2] != NSOrderedSame) {
                result = 0;
                break;
            }
        }
    }
    
    //set wifi setting flag
    if(0 == result){
        self.configViewController.wifiSetFlag = [@"NO" mutableCopy];
    }
    else{
        self.configViewController.wifiSetFlag = [@"YES" mutableCopy];
    }
    NSLog(@"wifiSetFlag:%@\n",self.configViewController.wifiSetFlag);
    
}

//Jeanne. 2014. 02.17
-(void)searchip
{
    NSLog(@"Search again!");
    if ([MagicUrl isEqualToString:@"magicinit"])
    {
      [[[UPnPManager GetInstance] SSDP] searchSSDP];
      [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
    }
    else{
        NSLog(@"device has founded, do not need to search!");
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    //先初始化对象
    if (MagicUrl == nil) {
        MagicUrl = [[NSMutableString alloc] initWithString:@"magicinit"];
    }
    m_id = [[NSMutableString alloc] init];
    self.menuProperty = [[BIDMenuProperty alloc] init];
    //showLabel.text = @"Begin Searching...";
    
    //初始化config菜单 2014.02.12
    //==============================
    if (self.configViewController ==nil) {
        self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController" bundle:nil];
    }
    if (self.configViewController.wifiSetFlag == nil) {
        self.configViewController.wifiSetFlag = [[NSMutableString alloc] init];
    }
    if (self.configViewController.wifiSettingUrl == nil) {
        self.configViewController.wifiSettingUrl = [[NSMutableString alloc] init];
    }
    if (self.configViewController.toMagicUrl == nil) {
        self.configViewController.toMagicUrl = [[NSMutableString alloc] init];
    }
    //==============================
    
    
    //Search for UPNP First
    //===============================================
    UPnPDB* db = [[UPnPManager GetInstance] DB];
    
    mDevices = [db rootDevices]; //BasicUPnPDevice
    
    [db addObserver:(UPnPDBObserver*)self];
    
    //Optional; set User Agent
    [[[UPnPManager GetInstance] SSDP] setUserAgentProduct:@"RemoterCtrl/1.0" andOS:@"OSX"];
    
    
    //Search for UPnP Devices
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
    [[[UPnPManager GetInstance] SSDP] searchSSDP];
    //===============================================
    
    //init timer to broadcast
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
    
    
    UITabBar *Tab = (id)[self.view viewWithTag:kMain_Tabbar_tag];
    Tab.hidden = TRUE;
    
    
    
}

-(void)initMenu
{
    UITabBar *Tab = (id)[self.view viewWithTag:kMain_Tabbar_tag];
    UILabel *showLabel = (id)[self.view viewWithTag:kShow_Label_tag];
    UILabel *verLabel = (id)[self.view viewWithTag:kVer_Label_tag];

    if (!([MagicUrl isEqualToString:@"magicinit"])) {
        
        client = [ILHTTPClient clientWithBaseURL:MagicUrl
                                showingHUDInView:self.view];
        if(client.isNeedHUD == nil){
            client.isNeedHUD = [[NSMutableString alloc] initWithString:@"YES"];
        }
        
        [client getPath:@"/init"
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             NSLog(@"response: %@", response);
             [self decode_response:response Forcmd:0];
             
             self.menuProperty.menuId = [[NSMutableString alloc] initWithFormat: @"%@",m_id];
             NSLog(@"m_id=%@",m_id);
             NSLog(@"self.menuProperty.menuId = %@",self.menuProperty.menuId);
             
             
             if (self.subViewController ==nil) {
                 self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController" bundle:nil];
                 
             }
             
             if (self.subViewController.toMagicUrl == nil) {
                 self.subViewController.toMagicUrl = [[NSMutableString alloc] initWithString:MagicUrl];
             }
             
             showLabel.hidden = TRUE;
             verLabel.hidden = TRUE;
             [self addChildViewController:self.subViewController];
             [self.view insertSubview:self.subViewController.view atIndex:1];
             Tab.hidden = FALSE;
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
        
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//protocol UPnPDBObserver
-(void)UPnPDBWillUpdate:(UPnPDB*)sender{
    NSLog(@"UPnPDBWillUpdate %lu", (unsigned long)[mDevices count]);
}

-(void)UPnPDBUpdated:(UPnPDB*)sender{
    
    BasicUPnPDevice *device;
    NSLog(@"UPnPDBUpdated %lu", (unsigned long)[mDevices count]);
    unsigned long cnt = [mDevices count] ;
    unsigned long i;
    for (i=0; i < cnt; i++) {
        device = [mDevices objectAtIndex:i];
        NSLog(@"device[%lu].friendname=%@",i,device.friendlyName);
        NSLog(@"device[%lu].xmlLocation=%@",i,device.xmlLocation);
        if([device.xmlLocation rangeOfString:kMagic_Device].location !=NSNotFound) {
            NSLog(@"Found Magic device : %lu",i);
            if ([MagicUrl isEqualToString:@"magicinit"]) {
                
                MagicUrl = [[device.xmlLocation stringByReplacingOccurrencesOfString:kMagic_Device withString:@""]mutableCopy];
                NSLog(@"Magicurl=%@",MagicUrl);
                //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(initMenu) userInfo:nil repeats:NO];
                [self initMenu];
            }

            break;
        }
        else if([device.xmlLocation rangeOfString:kMagic_Device_2].location !=NSNotFound) {
            NSLog(@"Found Magic device : %lu",i);
            if ([MagicUrl isEqualToString:@"magicinit"]) {
                
                MagicUrl = [[device.xmlLocation stringByReplacingOccurrencesOfString:kMagic_Device_2 withString:@""]mutableCopy];
                NSLog(@"Magicurl=%@",MagicUrl);
                //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(initMenu) userInfo:nil repeats:NO];
                [self initMenu];
            }
            
            break;
        }
    }
    //[menuView performSelectorOnMainThread : @ selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark -Tab View Delegate Methods
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    UITabBarItem *configitem = [tabBar.items objectAtIndex:2];
    UITabBarItem *homeitem = [tabBar.items objectAtIndex:0];
    
    tabBar.selectedItem = nil;

    if (item.tag == 1) {
        NSLog(@"Home key Selected!!!\n");
        
        if (configitem.enabled == FALSE) { //it is in config menu
            NSLog(@"In config menu now, quit first!\n");

            [self.configViewController.view removeFromSuperview];
            [self.view insertSubview:self.subViewController.view atIndex:1];
            
            if([self.subViewController.menuProperty.menuId isEqualToString:@"1"])
            {
                NSLog(@"Already in Main Menu!!!\n");
                homeitem.enabled = FALSE;
            }
        }
        else{
            
            //clear Search flag
            [self.subViewController clearSearchFlag];
        
            if([self.subViewController.menuProperty.menuId isEqualToString:@"1"])
            {
                NSLog(@"Already in Main Menu!!!\n");
            }
            else
            {
                NSString *gochildMaincmd = [[NSString alloc] initWithFormat:@"/gochild?id=%d",uiMAIN_MENU];
            
                [client getPath:gochildMaincmd
                 parameters:nil
                loadingText:nil
                successText:nil
                    success:^(AFHTTPRequestOperation *operation, NSString *response)
                    {
                        NSLog(@"response: %@", response);
                        [self.subViewController decode_menu:response Forcmd:2]; //2:gochild decode
                        [self.subViewController refresh_menu];
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        NSLog(@"Error: %@", error);
                    }
                ];
            }
            
            homeitem.enabled = FALSE;
        }
        
        configitem.enabled = TRUE;
        homeitem.image = [UIImage imageNamed:@"home"];
    }
    else if(item.tag == 2){ //go to play menu
        
        NSLog(@"Playmenu key Selected!!!\n");
        
    }
    else if(item.tag == 3){ //config menu
        NSLog(@"go to config menu\n");
        if (self.configViewController ==nil) {
            self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController" bundle:nil];
        }
        
        if (self.configViewController.toMagicUrl == nil) {
            self.configViewController.toMagicUrl = [[NSMutableString alloc] initWithString:MagicUrl];
        }
        else{
            self.configViewController.toMagicUrl = [MagicUrl mutableCopy];
        }
        
        [self.subViewController.view removeFromSuperview];
        [self.view insertSubview:self.configViewController.view atIndex:1];
        
        item.enabled = FALSE;
        homeitem.enabled = TRUE;
        homeitem.image = [UIImage imageNamed:@"left"];
    }
    
}
@end
