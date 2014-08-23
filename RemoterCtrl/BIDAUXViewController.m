//
//  BIDAUXViewController.m
//  RemoterCtrl
//
//  Created by 张巧玲 on 8/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import "BIDAUXViewController.h"
#import "BIDViewController.h"

#define kMute_Button_tag          102
#define kVol_Slider_tag           103

@interface BIDAUXViewController (){
    ILHTTPClient *client;   // http client
    BOOL volSettingFlag;
    int muteFlag;
}

@end

@implementation BIDAUXViewController

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


-(IBAction)backButtonPressed
{// go back to main menu
    NSString *gochildMaincmd = [[NSString alloc] initWithFormat:@"/gochild?id=%d",uiMAIN_MENU];
    NSLog(@"AUX:goback to main menu");
    
    
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    [client getPath:gochildMaincmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"response: %@", response);
         [parent gotoMainMenu:3];
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }
     ];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    
    //Init Params
    volSettingFlag = FALSE;
    muteFlag = FALSE;
    
    client = [ILHTTPClient clientWithBaseURL:self.toMagicUrl
                            showingHUDInView:self.view];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
