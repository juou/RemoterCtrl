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

//#define kMagic_Device   @":52525/root_XXYY.xml"
//#define kMagic_Device_2   @":52525/root_XXYY_S.xml"
#define kMagic_AirMusic_Device  @"/irdevice.xml"

#define kMain_Tabbar_tag       5
#define kShow_Label_tag        9
#define kVer_Label_tag         10
#define klog_Label_tag         11

static NSMutableString *m_id;


@interface BIDViewController (){
    uint search_cnt; //for search count  @Jeanne.  2014.02.25
    NSString *logstring;
    BOOL searched_flag;  //for search icon.  @Jeanne. 2014.02.26
    BOOL fadein_flag;    //for fade in flag.  @Jeanne. 2014.02.26
    NSArray *devicename; //for multi devices found.  @Jeanne. 2014.02.26
    NSArray *deviceurl;  //for multi devices found.  @Jeanne. 2014.02.26
}
@end


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
    UILabel *logLabel = (id)[self.view viewWithTag:klog_Label_tag];
    NSLog(@"Search again!,%d",search_cnt);
    SSDPDBDevice_ObjC *ssdbdevice;
    int i;

/*
    if ([mDevices count]) { //there is device
        BasicUPnPDevice *device;
        int cnt;
        int i;
        cnt = [mDevices count];
        for (i=0; i < cnt; i++) {
            device = [mDevices objectAtIndex:i];
            NSLog(@"d[%d].url= %@",i,device.xmlLocation);
        }
    }
 */
    if (search_cnt > 2) { //wait 3s to get the ssdp device
        if ([mSSDPObjCDevices count]) {
            NSLog(@"ssdp device count: %d",[mSSDPObjCDevices count]);
            for (i=0; i< [mSSDPObjCDevices count]; i++) {
                ssdbdevice = [mSSDPObjCDevices objectAtIndex:i];
                NSLog(@"ssdb[%d].location:%@",i,ssdbdevice.location);
                if([ssdbdevice.location rangeOfString:kMagic_AirMusic_Device].location !=NSNotFound) {
                    NSLog(@"Found Magic device : %d",i);
                    if ([MagicUrl isEqualToString:@"magicinit"]) {
                        MagicUrl = [[ssdbdevice.location stringByReplacingOccurrencesOfString:kMagic_AirMusic_Device withString:@""]mutableCopy];
                        NSLog(@"Magicurl=%@",MagicUrl);
                        searched_flag = TRUE;  //for search icon.  @Jeanne. 2014.02.26
                    }
                    
                    break;
                }// end if
                /*
                else if([ssdbdevice.location rangeOfString:kMagic_Device].location !=NSNotFound) {
                    NSLog(@"Found Magic device : %d",i);
                    if ([MagicUrl isEqualToString:@"magicinit"]) {
                        MagicUrl = [[ssdbdevice.location stringByReplacingOccurrencesOfString:kMagic_Device withString:@""]mutableCopy];
                        NSLog(@"Magicurl=%@",MagicUrl);
                        searched_flag = TRUE;  //for search icon.  @Jeanne. 2014.02.26
                    }
                    
                    break;
                }// end if
                else if([ssdbdevice.location rangeOfString:kMagic_Device_2].location !=NSNotFound) {
                    NSLog(@"Found Magic device : %d",i);
                    if ([MagicUrl isEqualToString:@"magicinit"]) {
                        MagicUrl = [[ssdbdevice.location stringByReplacingOccurrencesOfString:kMagic_Device_2 withString:@""]mutableCopy];
                        NSLog(@"Magicurl=%@",MagicUrl);
                        searched_flag = TRUE;  //for search icon.  @Jeanne. 2014.02.26
                    }
                    
                    break;
                }// end if
                 */
                
                
            } //end for
        }
    }

    
    
    
    if (!searched_flag) { //not searched yet
        search_cnt++; //for search count  @Jeanne.  2014.02.25
        logLabel.text = [NSString stringWithFormat:@"search cnt: %d",search_cnt];
        if (logstring != nil) {
            logLabel.text = logstring;
        }
        //logLabel.text = [NSString stringWithFormat:@"search cnt: %d",search_cnt];
        [[[UPnPManager GetInstance] SSDP] searchSSDP];
        [[[UPnPManager GetInstance] SSDP] searchSSDP];
        [[[UPnPManager GetInstance] SSDP] searchSSDP];
        //[[[UPnPManager GetInstance] SSDP] searchSSDP];
        //[[[UPnPManager GetInstance] SSDP] searchSSDP];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
        
    }
    else{ //searched
        if (fadein_flag) {
            NSLog(@"fade out first!\n");
            [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:@"Device searched!"];
            fadein_flag =FALSE;
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
        }
        else{
            NSLog(@"Searched device, goto list!");
            [self initMenu];

        }
    }
}

- (void)viewDidLoad
{
    UILabel *logLabel = (id)[self.view viewWithTag:klog_Label_tag];
    UILabel *showLabel = (id)[self.view viewWithTag:kShow_Label_tag];
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    
    //for multi devices found.  @Jeanne. 2014.02.26
    //------------------------------------------
    if (devicename == nil) {
        devicename = [[NSArray alloc] init];
    }
    if (deviceurl == nil) {
        deviceurl = [[NSArray alloc] init];
    }
    //------------------------------------------
    
    //for log.  @Jeanne. 2014.02.25
    //自动折行设置
    logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    logLabel.numberOfLines = 0;
    logLabel.textAlignment = NSTextAlignmentLeft;
    [logLabel setText:@"test"];
    search_cnt = 0; //for search count  @Jeanne.  2014.02.25
    searched_flag = FALSE;  //for search icon.  @Jeanne. 2014.02.26
    showLabel.hidden = TRUE;  //for fade effect.  @Jeanne. 2014.2.26
    
    //先初始化对象
    if (MagicUrl == nil) {
        MagicUrl = [[NSMutableString alloc] initWithString:@"magicinit"];
    }
    m_id = [[NSMutableString alloc] init];
    self.menuProperty = [[BIDMenuProperty alloc] init];
    
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
    search_cnt = 1; //for search count  @Jeanne.  2014.02.25
    //===============================================
    
    mSSDPObjCDevices = [[UPnPManager GetInstance] SSDP].SSDPObjCDevices;  //Get ssdp device.  @Jeanne. 2014.02.27

    
    //init timer to broadcast
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
    
    
    UITabBar *Tab = (id)[self.view viewWithTag:kMain_Tabbar_tag];
    Tab.hidden = TRUE;
    
    [MBProgressHUD fadeInHUDInView:self.view withText:@"Search for device..."];
    fadein_flag = TRUE;    //for fade in flag.  @Jeanne. 2014.02.26
    
}

-(void)initMenu
{
    UITabBar *Tab = (id)[self.view viewWithTag:kMain_Tabbar_tag];
    UILabel *showLabel = (id)[self.view viewWithTag:kShow_Label_tag];
    UILabel *verLabel = (id)[self.view viewWithTag:kVer_Label_tag];
    UILabel *logLabel = (id)[self.view viewWithTag:klog_Label_tag];
    

    if (!([MagicUrl isEqualToString:@"magicinit"]))
    {//if (found magic device) begin
        
        client = [ILHTTPClient clientWithBaseURL:MagicUrl showingHUDInView:self.view];
        if(client.isNeedHUD == nil){
            client.isNeedHUD = [[NSMutableString alloc] initWithString:@"YES"];
        }
        //client.isNeedHUD = [@"NO" mutableCopy];//2014.02.26
        
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
             logLabel.hidden = TRUE;
             [self addChildViewController:self.subViewController];
             [self.view insertSubview:self.subViewController.view atIndex:1];
             Tab.hidden = FALSE;
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
        
        //client.isNeedHUD = [@"YES" mutableCopy];//2014.02.26
        
    } //if (found magic device) end

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
/*

    BasicUPnPDevice *device;
    unsigned long cnt = [mDevices count] ;
    unsigned long i;
    NSString *oldstr;

    NSLog(@"UPnPDBUpdated %lu", (unsigned long)[mDevices count]);

    logstring = @"";
    for (i=0; i < cnt; i++) {
        device = [mDevices objectAtIndex:i];
        oldstr = logstring;
        logstring = [NSString stringWithFormat:@"%@d[%lu].name=%@,",oldstr,i,device.friendlyName];
    }
    
    

    
    for (i=0; i < cnt; i++) {
        device = [mDevices objectAtIndex:i];
        NSLog(@"device[%lu].friendname=%@",i,device.friendlyName);
        NSLog(@"device[%lu].xmlLocation=%@",i,device.xmlLocation);
        
        if([device.xmlLocation rangeOfString:kMagic_Device].location !=NSNotFound) {
            NSLog(@"Found Magic device : %lu",i);
            if ([MagicUrl isEqualToString:@"magicinit"]) {
                MagicUrl = [[device.xmlLocation stringByReplacingOccurrencesOfString:kMagic_Device withString:@""]mutableCopy];
                NSLog(@"Magicurl=%@",MagicUrl);
                searched_flag = TRUE;  //for search icon.  @Jeanne. 2014.02.26
            }

            break;
        }
    
        else if([device.xmlLocation rangeOfString:kMagic_Device_2].location !=NSNotFound) {
            NSLog(@"Found Magic device : %lu",i);
            if ([MagicUrl isEqualToString:@"magicinit"]) {
                
                MagicUrl = [[device.xmlLocation stringByReplacingOccurrencesOfString:kMagic_Device_2 withString:@""]mutableCopy];
                NSLog(@"Magicurl=%@",MagicUrl);
                searched_flag = TRUE;  //for search icon.  @Jeanne. 2014.02.26
            }
            
            break;
        }
    }
 */
    
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
        homeitem.image = [UIImage imageNamed:@"left_tab"];
    }
    
}
@end
