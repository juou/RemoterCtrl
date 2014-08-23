//
//  BIDBTViewController.m
//  RemoterCtrl
//
//  Created by 张巧玲 on 8/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import "BIDBTViewController.h"
#import "BIDViewController.h"

#define kMute_Button_tag          97
#define kVol_Slider_tag           98

@interface BIDBTViewController (){
    ILHTTPClient *client;   // http client
    BOOL volSettingFlag;
    int muteFlag;
    BOOL StopGetStatus;
    BOOL QuitRefresh;
    BOOL BTStatusGetFlag;
    unsigned  BTStatus;
}

@end

@implementation BIDBTViewController

@synthesize BackwordButton;
@synthesize ForwordButton;
@synthesize StopButton;
@synthesize PlaypauseButton;
@synthesize BTStatusImageView;

-(IBAction)backButtonPressed
{// go back to main menu
    NSString *gochildMaincmd = [[NSString alloc] initWithFormat:@"/gochild?id=%d",uiMAIN_MENU];
    NSLog(@"goback to main menu");
    
    StopGetStatus = TRUE;
    
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    [client getPath:gochildMaincmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"response: %@", response);
         [parent gotoMainMenu:2];
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }
     ];
    
}

-(IBAction)StartBTMatchPressed
{
    NSString *BTMatchcmd = @"/StartBTMatch";
    NSLog(@"StartBTMatchPressed");
    
    StopGetStatus = TRUE;
    
    [client getPath:BTMatchcmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         StopGetStatus = FALSE;
         NSLog(@"response: %@", response);
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         StopGetStatus = FALSE;
         NSLog(@"Error: %@", error);
     }
     ];
    
}

-(IBAction)CMDButtonPressed:(UIButton *)button
{
    NSString *cmd;
    
    //=1: play/pause
    //=2: stop
    //=3: Forword
    //=4: Backword
    
    if (button.tag == BackwordButton.tag) {
        cmd = @"/BTCMD?cmd=4";
    }else if (button.tag == ForwordButton.tag) {
        cmd = @"/BTCMD?cmd=3";
    }else if (button.tag == StopButton.tag) {
        cmd = @"/BTCMD?cmd=2";
    }else if (button.tag == PlaypauseButton.tag) {
        cmd = @"/BTCMD?cmd=1";
    }
    
    StopGetStatus = TRUE;
    [client getPath:cmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         StopGetStatus = FALSE;
         NSLog(@"response: %@", response);
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         StopGetStatus = FALSE;
         NSLog(@"Error: %@", error);
     }
     ];
    
}

-(IBAction)volChange:(UISlider *)sender
{
    int progress = (int)lroundf(sender.value); //获取滑块当前值，四舍五入
    NSString *setVolcmd = [[NSString alloc] initWithFormat:@"/setvol?vol=%d&mute=0",progress];
    
    
    if(volSettingFlag)
    {
        NSLog(@"already in setting vol, ignore it!\n");
    }
    else
    {
        NSLog(@"%@",setVolcmd);
        //Set Setting vol flag
        volSettingFlag = TRUE;
        client.isNeedHUD = [@"NO" mutableCopy];
        
        [client getPath:setVolcmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             NSLog(@"Set vol response: %@", response);
             //clear Setting vol flag
             volSettingFlag = FALSE;
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             //clear Setting vol flag
             volSettingFlag = FALSE;
         }
         ];
        client.isNeedHUD = [@"YES" mutableCopy];
    }
    
}

-(IBAction)MuteButtonPressed
{
    UIButton *MuteButton =(id)[self.view viewWithTag:kMute_Button_tag];
    UISlider *Volslider = (id)[self.view viewWithTag:kVol_Slider_tag];
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    
    
    if(volSettingFlag)
    {
        NSLog(@"already in setting vol, ignore it!\n");
    }
    else
    {
        if (0 == muteFlag) {
            muteFlag = 1;
            //Modified for support multi ios device.  @Jeanne. 2014.03.21
            if ([parent.CuriosDevice isEqualToString:@"ipad"])
            {
                [MuteButton setImage:[UIImage imageNamed:@"mute_ipad.png"] forState:UIControlStateNormal];
            }
            else{
                [MuteButton setImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateNormal];
            }
            
            Volslider.enabled = FALSE;
        }
        else{
            muteFlag = 0;
            //Modified for support multi ios device.  @Jeanne. 2014.03.21
            if ([parent.CuriosDevice isEqualToString:@"ipad"])
            {
                [MuteButton setImage:[UIImage imageNamed:@"vol_ipad.png"] forState:UIControlStateNormal];
            }
            else{
                [MuteButton setImage:[UIImage imageNamed:@"vol.png"] forState:UIControlStateNormal];
            }
            
            Volslider.enabled = TRUE;
        }
        
        
        {
            int progress = (int)lroundf(Volslider.value); //获取滑块当前值，四舍五入
            NSString *setVolcmd = [[NSString alloc] initWithFormat:@"/setvol?vol=%d&mute=%d",progress,muteFlag];
            
            NSLog(@"%@",setVolcmd);
            //Set Setting vol flag
            volSettingFlag = TRUE;
            client.isNeedHUD = [@"NO" mutableCopy];
            
            [client getPath:setVolcmd
                 parameters:nil
                loadingText:nil
                successText:nil
                    success:^(AFHTTPRequestOperation *operation, NSString *response)
             {
                 NSLog(@"Set vol response: %@", response);
                 //clear Setting vol flag
                 volSettingFlag = FALSE;
             }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 NSLog(@"Error: %@", error);
                 //clear Setting vol flag
                 volSettingFlag = FALSE;
             }
             ];
            client.isNeedHUD = [@"YES" mutableCopy];
            
        }
    }
}

//cmd list Begin--------------
//cmd = 1: get BT status
//cmd list End----------------

-(void) decode_menu:(NSString *)response Forcmd: (NSInteger)cmd
{
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    UISlider *Volslider = (id)[self.view viewWithTag:kVol_Slider_tag];
    UIButton *MuteButton = (id)[self.view viewWithTag:kMute_Button_tag];
    char *p1;
    char tmp[20];
    char vol[5],mute[3];
    
    const char *str = [response UTF8String];
    
    if (cmd == 1){ //cmd = 1: get fm status
        
        //get vol
        memset(vol, 0, sizeof(vol));
        p1 = strstr(str, "<vol>");
        if(p1)
        {
            for (int i = 5; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                vol[i-5] = p1[i];
            }
        }
        
        //get muteflag
        memset(mute, 0, sizeof(mute));
        p1 = strstr(str, "<mute>");
        if(p1)
        {
            for (int i = 6; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                mute[i-6] = p1[i];
            }
            
            if (volSettingFlag) {
                NSLog(@"In set vol cmd, do nothing!\n");
            }
            else{
                Volslider.value = atoi(vol);
                muteFlag = atoi(mute); //2014.01.26
                
                if (0 == muteFlag) {
                    //Modified for support multi ios device.  @Jeanne. 2014.03.21
                    if ([parent.CuriosDevice isEqualToString:@"ipad"])
                    {
                        [MuteButton setImage:[UIImage imageNamed:@"vol_ipad.png"] forState:UIControlStateNormal];
                    }
                    else{
                        [MuteButton setImage:[UIImage imageNamed:@"vol.png"] forState:UIControlStateNormal];
                    }
                    Volslider.enabled = TRUE;
                }
                else{
                    //Modified for support multi ios device.  @Jeanne. 2014.03.21
                    if ([parent.CuriosDevice isEqualToString:@"ipad"])
                    {
                        [MuteButton setImage:[UIImage imageNamed:@"mute_ipad.png"] forState:UIControlStateNormal];
                    }
                    else{
                        [MuteButton setImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateNormal];
                    }
                    Volslider.enabled = FALSE;
                }
            }
            
        }
        
        //Get Status
        //---------------
        memset(tmp, 0, sizeof(tmp));
        p1 = strstr(str, "<Status>");
        if(p1)
        {
            UIImage *Image;
            for (int i = 8; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                tmp[i-8] = p1[i];
            }
            
            BTStatus = atoi(tmp);  //to process BTStatus display
            
            //1: [not matched]   2:[matching]  3:[matched]	4:[playing]
            if (BTStatus == 1) {
                Image = [UIImage imageNamed:@"unmatched.png"];
            }
            else if (BTStatus == 2) {
                Image = [UIImage imageNamed:@"matching.png"];
            }
            else if (BTStatus == 3) {
                Image = [UIImage imageNamed:@"matched.png"];
            }
            else if (BTStatus == 4) {
                Image = [UIImage imageNamed:@"playing.png"];
            }

            [BTStatusImageView setImage:Image];
        }
        
        //---------------
        
        
    }
    
}


-(void) BTStatusGet
{
    NSString *path = @"/GetBTStatus";
    
    client.isNeedHUD = [@"NO" mutableCopy];
    BTStatusGetFlag = TRUE;
    //Get FM status
    [client getPath:path
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         //NSLog(@"refreshmenu: %@", response);
         [self decode_menu:response Forcmd:1];
         BTStatusGetFlag = FALSE;
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         BTStatusGetFlag = FALSE;
     }
     ];
    client.isNeedHUD = [@"YES" mutableCopy];
}

-(void) BTRefreshTimer
{
    if (QuitRefresh) {
        QuitRefresh = FALSE;
        return;
    }
    
    if (StopGetStatus) {
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(BTRefreshTimer) userInfo:nil repeats:NO];
        return;
    }
    
    
    //Get BT status
    [self BTStatusGet];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(BTRefreshTimer) userInfo:nil repeats:NO];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{

    //Init Params
    StopGetStatus = TRUE;
    BTStatusGetFlag = FALSE;
    volSettingFlag = FALSE;
    muteFlag = FALSE;
    QuitRefresh = FALSE;
    
    client = [ILHTTPClient clientWithBaseURL:self.toMagicUrl
                            showingHUDInView:self.view];
    
    
    //Get BT status
    [self BTStatusGet];
    
    StopGetStatus = FALSE;
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(BTRefreshTimer) userInfo:nil repeats:NO];
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    QuitRefresh = TRUE;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
