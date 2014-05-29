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
#import "BIDUIDevice.h"

//#define kMagic_Device   @":52525/root_XXYY.xml"
//#define kMagic_Device_2   @":52525/root_XXYY_S.xml"
#define kMagic_AirMusic_Device  @"/irdevice.xml"

#define kMain_Tabbar_tag       101
#define kMain_2_Tabbar_tag     100
//#define kShow_Label_tag        9
#define kVer_Label_tag         10
#define klog_Label_tag         11
#define kurl_TableView_tag     102

static NSString *CellIdentifier = @"Cell";

static NSMutableString *m_id;


@interface BIDViewController (){
    uint search_cnt; //for search count  @Jeanne.  2014.02.25
    NSString *logstring;
    Byte searched_flag;  //for search icon.  @Jeanne. 2014.02.26
    BOOL fadein_flag;    //for fade in flag.  @Jeanne. 2014.02.26
    NSMutableDictionary *devicenames; //for multi devices found.  @Jeanne. 2014.02.26
    NSMutableArray *deviceurls;  //for multi devices found.  @Jeanne. 2014.02.26
}
@end


@implementation BIDViewController


//0: decode init
//1: decode friendly name
-(void) decode_response:(NSString *)response Forcmd: (NSInteger)cmd Forpos:(NSInteger)pos
{
    char *p;
    char id[4],url[50],name[50];
    const char *str = [response UTF8String];
    memset(id, 0, sizeof(id));
    memset(url, 0, sizeof(url));
    memset(name, 0, sizeof(name));
    int i;
    NSInteger result;
    
    if (cmd == 0)
    {  //0: decode init
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
        self.wifiSettingUrl = [wifiurl mutableCopy]; //Jeanne. 2014.03.04
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
    else if(cmd == 1)
    {//decode friendly name
        //Get friendly name
        p =strstr(str, "<friendlyName>");
        if(p)
        {
            for (int i = 14; (p[i]!=0)&&(p[i]!='<'); i++) {
                name[i-14] = p[i];
            }
        }
        
        NSString *fname=[NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        NSString *keypos = [NSString stringWithFormat:@"%ld",(long)pos];
        NSLog(@"fname=%@",fname);
        
        [devicenames setObject:fname forKey:keypos];
    }
}

//Jeanne. 2014. 02.17
-(void)searchip
{
    UILabel *logLabel = (id)[self.view viewWithTag:klog_Label_tag];
    UITableView *urlTable = (id)[self.view viewWithTag:kurl_TableView_tag];
    NSLog(@"Search again!,%d",search_cnt);
    SSDPDBDevice_ObjC *ssdbdevice;
    NSString *deviceurl;
    int i;
 
    if (!searched_flag) {
        if (search_cnt > 2) { //wait 3s to get the ssdp device
            if ([mSSDPObjCDevices count]) {
                NSLog(@"ssdp device count: %lu",(unsigned long)[mSSDPObjCDevices count]);
                for (i=0; i< [mSSDPObjCDevices count]; i++) {
                    ssdbdevice = [mSSDPObjCDevices objectAtIndex:i];
                    NSLog(@"ssdb[%d].location:%@",i,ssdbdevice.location);
                    if([ssdbdevice.location rangeOfString:kMagic_AirMusic_Device].location !=NSNotFound) {
                        NSLog(@"Found Magic device : %d",i);
                        deviceurl = [ssdbdevice.location stringByReplacingOccurrencesOfString:kMagic_AirMusic_Device withString:@""];
                        [deviceurls addObject:deviceurl];
                        //[deviceurls addObject:deviceurl]; //test
                        searched_flag = 1;  //for search icon.  @Jeanne. 2014.02.26
                        
                        //Add for demo mode.  @Jeanne. 2014.04.08
                        self.IsinDemomode = [@"NO" mutableCopy];
                        
                    }// end if
                    
                } //end for
            }//end if ([mSSDPObjCDevices count])
        }//end if (search_cnt > 2)
        
    }

    
    if (!searched_flag) { //not searched yet
        search_cnt++; //for search count  @Jeanne.  2014.02.25
        logLabel.text = [NSString stringWithFormat:@"search cnt: %d",search_cnt];
        if (logstring != nil) {
            logLabel.text = logstring;
        }
        
        if(search_cnt > 5)
        {//Show Not found alert, and select to goto demo mode.  @Jeanne. 2014.04.04
            NSString *NotFoundStr = [self.strs valueForKey:@"NODEVICE_REMIND"];
            NSString *RescanStr = [self.strs valueForKey:@"RESCAN_ONLY"];
            NSString *DemoStr = [self.strs valueForKey:@"DEMO"];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:NotFoundStr
                                  delegate:self
                                  cancelButtonTitle:RescanStr
                                  otherButtonTitles:DemoStr, nil];
            
            [alert show];
            
        }
        else{
            NSLog(@"Searching ...");
           //logLabel.text = [NSString stringWithFormat:@"search cnt: %d",search_cnt];
           [[[UPnPManager GetInstance] SSDP] searchSSDP];
           [[[UPnPManager GetInstance] SSDP] searchSSDP];
           [[[UPnPManager GetInstance] SSDP] searchSSDP];
        
           [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
        }
        
    }
    else{ //searched
        if (fadein_flag) {
            NSLog(@"fade out first!\n");
            //[MBProgressHUD fadeOutHUDInView:self.view withSuccessText:@"Device searched!"];
            [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
            fadein_flag =FALSE;
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
        }
        else{

            if ([deviceurls count] > 1) {
                if (1 == searched_flag) {
                    NSLog(@"Search multi devices, select which on first!\n");
                    //Get friendly name first.
                    //========================================
                    for (i=0; i < [deviceurls count]; i++) {
                        deviceurl = [deviceurls objectAtIndex:i];
                        NSLog(@"Get Friendly name from(%d): %@",i,deviceurl);
                        
                        client = [ILHTTPClient clientWithBaseURL:deviceurl showingHUDInView:self.view];
                        client.isNeedHUD = [@"NO" mutableCopy];//2014.02.26
                        [client getPath:kMagic_AirMusic_Device
                             parameters:nil
                            loadingText:nil
                            successText:nil
                                success:^(AFHTTPRequestOperation *operation, NSString *response)
                         {
                             NSLog(@"get friendly name response(%d): %@", i,response);
                             [self decode_response:response Forcmd:1 Forpos:i];
                             
                         }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                         {
                             NSLog(@"Error: %@", error);
                         }];
                        client.isNeedHUD = [@"YES" mutableCopy];//2014.02.26
                    }
                    //========================================
                    

                    searched_flag = 2;  //go into select menu
                    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
                }
                else if(2 == searched_flag){ //waiting for device name
                    NSInteger urlcnt,namecnt;
                    urlcnt = [deviceurls count];
                    namecnt = [devicenames count];
                    if ((urlcnt == namecnt)&& (urlcnt != 0)) {
                        NSLog(@"Get all friendy name!");
                        [urlTable reloadData];
                        urlTable.hidden = FALSE;
                    }else{
                        NSLog(@"waiting for decode");
                        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
                    }
                }
            }
            else{
                    NSLog(@"Searched 1 device, goto list!");
                    MagicUrl = [[deviceurls objectAtIndex:0] mutableCopy];
                    [self initMenu];
            }//end if ([deviceurls count] > 1) else
        } //end if (fadein_flag) else
    }
}

-(void)initMenu
{
    UITabBar *Tab = (id)[self.view viewWithTag:kMain_Tabbar_tag];
    UITabBar *Tab_2 = (id)[self.view viewWithTag:kMain_2_Tabbar_tag];  //Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
    UILabel *verLabel = (id)[self.view viewWithTag:kVer_Label_tag];
    UILabel *logLabel = (id)[self.view viewWithTag:klog_Label_tag];
    //Add for tansfer Current language to device.  @Jeanne.  2014.05.26
    NSString *path = [[NSString alloc] initWithFormat:@"/init?language=%@",Curlanguage];
    
    if (!([MagicUrl isEqualToString:@"magicinit"]))
    {//if (found magic device) begin
        
        client = [ILHTTPClient clientWithBaseURL:MagicUrl showingHUDInView:self.view];
        if(client.isNeedHUD == nil){
            client.isNeedHUD = [[NSMutableString alloc] initWithString:@"YES"];
        }
        //client.isNeedHUD = [@"NO" mutableCopy];//2014.02.26
        
        //Add for tansfer Current language to device.  @Jeanne.  2014.05.26
        [client getPath:path //@"/init"
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             NSLog(@"response: %@", response);
             [self decode_response:response Forcmd:0 Forpos:0];
             
             self.menuProperty.menuId = [[NSMutableString alloc] initWithFormat: @"%@",m_id];
             NSLog(@"m_id=%@",m_id);
             NSLog(@"self.menuProperty.menuId = %@",self.menuProperty.menuId);
             
             
             if (self.subViewController ==nil) {
                 
                 //Modified for support multi ios device.  @Jeanne. 2014.03.21
                 if ([self.CuriosDevice isEqualToString:@"iphone4"]) {
                     self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController_iphone4" bundle:nil];
                 }
                 else if ([self.CuriosDevice isEqualToString:@"iphone5"]) {
                     self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController" bundle:nil];
                 }
                 else if ([self.CuriosDevice isEqualToString:@"ipad"]) {
                     self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController_ipad" bundle:nil];
                 }
                 else{
                     self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController" bundle:nil];
                 }
                 
             }
             else{
                 
             }
             
             //Modified for support multi ios device.  @Jeanne. 2014.03.21
             if (self.subViewController.CuriosDevice == nil) {
                 self.subViewController.CuriosDevice = [[NSMutableString alloc] initWithString:self.CuriosDevice];
             }
             self.subViewController.CuriosDevice = [self.CuriosDevice mutableCopy];
             
             
             if (self.subViewController.toMagicUrl == nil) {
                 self.subViewController.toMagicUrl = [[NSMutableString alloc] initWithString:MagicUrl];
             }
             self.subViewController.toMagicUrl = MagicUrl; //2014.03.06 for rescan
             
             //Add for multi languages.  @Jeanne.  2014.03.13
             if (self.subViewController.strs == nil) {
                 self.subViewController.strs = [[NSMutableDictionary alloc] initWithDictionary:self.strs];
             }
             else{
                 self.subViewController.strs = [self.strs mutableCopy];
             }
             
             //Add for demo mode.  @Jeanne. 2014.04.04
             if (self.subViewController.IsinDemomode == nil) {
                 self.subViewController.IsinDemomode = [[NSMutableString alloc] initWithString:self.IsinDemomode];
             }
             else{
                 self.subViewController.IsinDemomode = [self.IsinDemomode mutableCopy];
             }
             
             //showLabel.hidden = TRUE;
             verLabel.hidden = TRUE;
             logLabel.hidden = TRUE;
             
             //Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
             self.subViewController.wifiSetFlag = self.configViewController.wifiSetFlag;
             if ([self.configViewController.wifiSetFlag isEqualToString:@"YES"]) {
                 Tab_2.hidden = FALSE;
             }
             else{
                 Tab.hidden = FALSE;
             }
             
             [self addChildViewController:self.subViewController];
             [self.view insertSubview:self.subViewController.view atIndex:1];
             
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
        
        //client.isNeedHUD = [@"YES" mutableCopy];//2014.02.26
        
    } //if (found magic device) end
    
}

-(void)initlanguage
{
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    int i;
    BOOL bSupportflag;
    NSLog(@"语言：%@", language);//en
    
    //Add for multi languages.  @Jeanne.  2014.03.13
    //#####################################################
    self.supportlanguages = @[
                              @"en",   //English
                              @"de",   //German
                              @"fr",   //French
                              @"da",   //Danish
                              @"sv",   //Swedish
                              @"nb",   //Norwegian
                              @"ru",   //Russian
                              ];
    
    NSString *supportlang;
    bSupportflag = FALSE;
    for (i=0; i<[self.supportlanguages count]; i++) {
        supportlang = [self.supportlanguages objectAtIndex:i];
        if ([supportlang isEqualToString:language]) {
            NSLog(@"Current language(%@) is supported",language);
            bSupportflag = TRUE;
            break;
        }
    }
    //创建一个可变数组来存储待显示的数据
    NSString *path;
    if(bSupportflag == TRUE){
        NSLog(@"Use current language: %@",language);
        //Add for tansfer Current language to device.  @Jeanne.  2014.05.26
        Curlanguage = [[NSString alloc] initWithFormat:@"%@", language];
        path = [[NSBundle mainBundle] pathForResource:language ofType:@"plist"];
    }
    else{
        NSLog(@"Use en language");
        //Add for tansfer Current language to device.  @Jeanne.  2014.05.26
        Curlanguage = @"en";
        path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"plist"];
    }
    self.strs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    //#####################################################
    
}

-(void) initProperties
{
    //Add for demo mode.  @Jeanne. 2014.04.04
    if (self.IsinDemomode == nil) {
        self.IsinDemomode = [[NSMutableString alloc] initWithString:@"NO"];
    }
    
    if (self.menuProperty == nil) {
        self.menuProperty = [[BIDMenuProperty alloc] init];
    }
    
    //初始化config菜单 2014.02.12
    //==============================
    if (self.configViewController ==nil) {
        //Modified for support multi ios device.  @Jeanne. 2014.03.21
        if ([self.CuriosDevice isEqualToString:@"iphone4"]) {
            self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController_iphone4" bundle:nil];
        }
        else if ([self.CuriosDevice isEqualToString:@"iphone5"]) {
            self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController" bundle:nil];
        }
        else if ([self.CuriosDevice isEqualToString:@"ipad"]) {
            self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController_ipad" bundle:nil];
        }
        else{
            self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController" bundle:nil];
        }
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
    
}

-(void)initVar
{
    UILabel *logLabel = (id)[self.view viewWithTag:klog_Label_tag];
    
    //for log.  @Jeanne. 2014.02.25
    logLabel.lineBreakMode = NSLineBreakByWordWrapping;
    logLabel.numberOfLines = 0;
    logLabel.textAlignment = NSTextAlignmentLeft;
    [logLabel setText:@"test"];
    
    
    //for multi devices found.  @Jeanne. 2014.02.26
    //------------------------------------------
    if (devicenames == nil) {
        devicenames = [[NSMutableDictionary alloc] init];
    }
    if (deviceurls == nil) {
        deviceurls = [[NSMutableArray alloc] initWithCapacity:0];
    }
    //------------------------------------------
    
    search_cnt = 0; //for search count  @Jeanne.  2014.02.25
    searched_flag = 0;  //for search icon.  @Jeanne. 2014.02.26
    
    if (MagicUrl == nil) {
        MagicUrl = [[NSMutableString alloc] initWithString:@"magicinit"];
    }
    m_id = [[NSMutableString alloc] init];
    
    //Check rescan flag
    NSString *flag = @"NO";
    [self addObserver:self forKeyPath:@"RESCAN" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [self setValue:flag forKey:@"RESCAN"];
    
    
}

-(void) initUpnp
{
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
    
    
    //Add for multi languages.  @Jeanne.  2014.03.13
    NSString *searchstr;
    searchstr = [self.strs valueForKey:@"SCANING"];
    [MBProgressHUD fadeInHUDInView:self.view withText:searchstr];
    fadein_flag = TRUE;    //for fade in flag.  @Jeanne. 2014.02.26
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //Init Language
    [self initlanguage];
    
    //Init Var
    [self initVar];
    
    //Init Properties
    [self initProperties];
    
    //Init Upnp
    [self initUpnp];
    
}

//如果FirstViewController中的变量name的值变化执行下面
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"RESCAN"])
    {
        NSLog(@"observer name is %@",[self valueForKey:@"RESCAN"]);
        if ([RESCAN isEqualToString:@"YES"]) {
            //Set Rescan process
            [self Rescandevice];
        }
    }
}

-(void)Rescandevice
{
    UITableView *urlTable = (id)[self.view viewWithTag:kurl_TableView_tag];
    UITabBar *Tab = (id)[self.view viewWithTag:kMain_Tabbar_tag];
    UITabBar *Tab_2 = (id)[self.view viewWithTag:kMain_2_Tabbar_tag];
    UITabBarItem *Tabitem;
    int i;
    //UITabBarItem *homeitem =
    NSLog(@"Recan devices!");
    [MBProgressHUD fadeInHUDInView:self.view withText:@"Search for device..."];
    fadein_flag = TRUE;    //for fade in flag.  @Jeanne. 2014.02.26
    search_cnt = 0; //for search count  @Jeanne.  2014.02.25
    searched_flag = 0;  //for search icon.  @Jeanne. 2014.02.26
    [devicenames removeAllObjects]; //for multi devices found.  @Jeanne. 2014.02.26
    [deviceurls removeAllObjects];  //for multi devices found.  @Jeanne. 2014.02.26
    MagicUrl = [@"magicinit" mutableCopy];
    //Add for force refresh after rescan.  @Jeanne. 2014.03.06
    self.subViewController.ForceRefreshFlag =[@"YES" mutableCopy];
    urlTable.hidden = TRUE;
    
    //init Tabbar
    Tab.hidden = TRUE;
    Tab_2.hidden = TRUE;
    for (i = 0; i < [Tab.items count]; i++) {
        Tabitem = [Tab.items objectAtIndex:i];

        switch (i) {
            case 0:
                Tabitem.image = [UIImage imageNamed:@"home"];
            case 1:
                Tabitem.enabled = FALSE;
                break;
                
            default:
                Tabitem.enabled = TRUE;
                break;
        }
    }
    
    for (i = 0; i < [Tab_2.items count]; i++) {
        Tabitem = [Tab_2.items objectAtIndex:i];
        
        switch (i) {
            case 0:
                Tabitem.image = [UIImage imageNamed:@"home"];
            case 1:
                Tabitem.enabled = FALSE;
                break;
                
            default:
                Tabitem.enabled = TRUE;
                break;
        }
    }
    //init timer to broadcast
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
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
            
            //[self passSelf: self.subViewController.BIDctrl]; //test control parent.  @Jeanne

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
                
                //Add for demo mode.  @Jeanne. 2014.04.04
                if ([self.IsinDemomode isEqualToString:@"YES"]){
                    NSLog(@"demomode: goto main menu");
                    self.subViewController.menuProperty.menuId = [@"1" mutableCopy];
                    [self.subViewController getDemomenu:uiMAIN_MENU];
                    [self.subViewController refresh_menu];
                }
                else{
            
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
            //Modified for support multi ios device.  @Jeanne. 2014.03.21
            if ([self.CuriosDevice isEqualToString:@"iphone4"]) {
                self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController_iphone4" bundle:nil];
            }
            else if ([self.CuriosDevice isEqualToString:@"iphone5"]) {
              self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController" bundle:nil];
            }
            else if ([self.CuriosDevice isEqualToString:@"ipad"]) {
                self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController_ipad" bundle:nil];
            }
            else{
              self.configViewController = [[BIDConfigViewController alloc] initWithNibName:@"BIDConfigViewController" bundle:nil];
            }
            
        }
        
        if (self.configViewController.toMagicUrl == nil) {
            self.configViewController.toMagicUrl = [[NSMutableString alloc] initWithString:MagicUrl];
        }
        else{
            self.configViewController.toMagicUrl = [MagicUrl mutableCopy];
        }
        
        //Add for multi languages.  @Jeanne.  2014.03.13
        if (self.configViewController.strs == nil) {
            self.configViewController.strs = [[NSMutableDictionary alloc] initWithDictionary:self.strs];
        }
        else{
            self.configViewController.strs = [self.strs mutableCopy];
        }
        
        //Add for demo mode.  @Jeanne. 2014.04.04
        if (self.configViewController.IsinDemomode == nil) {
            self.configViewController.IsinDemomode = [[NSMutableString alloc] initWithString:self.IsinDemomode];
        }
        else{
            self.configViewController.IsinDemomode = [self.IsinDemomode mutableCopy];
        }
        
        [self.subViewController.view removeFromSuperview];
        [self addChildViewController:self.configViewController]; //2014.03.06
        [self.view insertSubview:self.configViewController.view atIndex:1];
        
        item.enabled = FALSE;
        homeitem.enabled = TRUE;
        homeitem.image = [UIImage imageNamed:@"left_tab"];
    }
    else if(item.tag == 4){ //wifi setting
        
        NSLog(@"Wifi setting Pressed!!!\n");
        
        NSString *strUrl = [self.wifiSettingUrl stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        NSLog(@"strUrl=%@",strUrl);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
        
    }
    
}

#pragma mark -Table View Data Source Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [deviceurls count];
    
}//tableView:tableView numberOfRowsInSection:section

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImage *bgImage;
    NSString *str;
    NSString *poskey = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    
    str = [devicenames objectForKey:poskey];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = str;
    cell.textLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    cell.textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    
    //Modified for support multi ios device.  @Jeanne. 2014.03.21
    if ([self.CuriosDevice isEqualToString:@"ipad"])
    {
        bgImage = [UIImage imageNamed:@"bar_bg_ipad"];
        cell.textLabel.font = [UIFont systemFontOfSize:30];
    }
    else{
        bgImage= [UIImage imageNamed:@"bar_bg"];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    cell.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    //cell.textLabel.font = [UIFont systemFontOfSize:17];

    return cell;
}//tableView:tableView cellForRowAtIndexPath:indexPath

#pragma mark -Table View Delegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Modified for support multi ios device.  @Jeanne. 2014.03.21
    if ([self.CuriosDevice isEqualToString:@"ipad"])
    {
        return 96;
    }
    else{
        return 48;
    }
    
    
}

//tableView didSelectRowAtIndexPath:会在一行被选中时调用，告诉用户要单击细节展开按钮而不是选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str;
    str = [deviceurls objectAtIndex:indexPath.row];
    
    NSLog(@"Select url: %@",str);

    //取消选中项
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    //hid table first
    tableView.hidden = TRUE;
    
    //set magic url
    MagicUrl = [str mutableCopy];
    [self initMenu];
    


    
}

//Add for Demo mode.  @Jeanne. 2014.04.04
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITabBar *Tab = (id)[self.view viewWithTag:kMain_Tabbar_tag];
    UITabBar *Tab_2 = (id)[self.view viewWithTag:kMain_2_Tabbar_tag];  //Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
    UILabel *verLabel = (id)[self.view viewWithTag:kVer_Label_tag];
    UILabel *logLabel = (id)[self.view viewWithTag:klog_Label_tag];
    NSLog(@"click button: %ld (0:Rescan 1:demo)",(long)buttonIndex);
    
    if (1 == buttonIndex) {
        NSLog(@"Go to demo mode");
        
        self.IsinDemomode = [@"YES" mutableCopy];
        
        //Fade out first
        [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
        fadein_flag =FALSE;
        
        //goto demo mode
        self.menuProperty.menuId = [[NSMutableString alloc] initWithFormat: @"1"];
        NSLog(@"demo mode:self.menuProperty.menuId = %@",self.menuProperty.menuId);
        
        
        if (self.subViewController ==nil) {
            
            //Modified for support multi ios device.  @Jeanne. 2014.03.21
            if ([self.CuriosDevice isEqualToString:@"iphone4"]) {
                self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController_iphone4" bundle:nil];
            }
            else if ([self.CuriosDevice isEqualToString:@"iphone5"]) {
                self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController" bundle:nil];
            }
            else if ([self.CuriosDevice isEqualToString:@"ipad"]) {
                self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController_ipad" bundle:nil];
            }
            else{
                self.subViewController = [[BIDSubViewController alloc] initWithNibName:@"BIDSubViewController" bundle:nil];
            }
            
        }
        
        //Modified for support multi ios device.  @Jeanne. 2014.03.21
        if (self.subViewController.CuriosDevice == nil) {
            self.subViewController.CuriosDevice = [[NSMutableString alloc] initWithString:self.CuriosDevice];
        }
        self.subViewController.CuriosDevice = [self.CuriosDevice mutableCopy];
        
        
        if (self.subViewController.toMagicUrl == nil) {
            self.subViewController.toMagicUrl = [[NSMutableString alloc] initWithString:MagicUrl];
        }
        self.subViewController.toMagicUrl = MagicUrl; //2014.03.06 for rescan
        
        //Add for multi languages.  @Jeanne.  2014.03.13
        if (self.subViewController.strs == nil) {
            self.subViewController.strs = [[NSMutableDictionary alloc] initWithDictionary:self.strs];
        }
        else{
            self.subViewController.strs = [self.strs mutableCopy];
        }
        
        //Add for demo mode.  @Jeanne. 2014.04.04
        if (self.subViewController.IsinDemomode == nil) {
            self.subViewController.IsinDemomode = [[NSMutableString alloc] initWithString:self.IsinDemomode];
        }
        else{
            self.subViewController.IsinDemomode = [self.IsinDemomode mutableCopy];
        }
        
        verLabel.hidden = TRUE;
        logLabel.hidden = TRUE;
        
        //Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
        self.subViewController.wifiSetFlag = self.configViewController.wifiSetFlag;
        if ([self.configViewController.wifiSetFlag isEqualToString:@"YES"]) {
            Tab_2.hidden = FALSE;
        }
        else{
            Tab.hidden = FALSE;
        }
        
        [self addChildViewController:self.subViewController];
        [self.view insertSubview:self.subViewController.view atIndex:1];
    }
    else if(0 == buttonIndex){
        NSLog(@"Rescan!");
        search_cnt = 0;
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(searchip) userInfo:nil repeats:NO];
    }
}

/*  test control parent
-(void)passSelf:(id)sender
{
    sender = self;
}
*/

@end
