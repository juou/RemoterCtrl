//
//  BIDConfigViewController.m
//  RemoterCtrl
//
//  Created by 张巧玲 on 2/10/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import "BIDConfigViewController.h"
#import "UIImageView+AFNetworking.h"
#import <string.h>
#import "ILHTTPClient.h"



#define kwifi_Label_tag       4
#define kwifi_Button_tag      5
#define kbg_Button_tag        6

@interface BIDConfigViewController (){
    ILHTTPClient *client;   // http client
    int testcnt;     //for test only
}
@end

@implementation BIDConfigViewController

-(void) SWUpdate
{
    UIButton *bgButton =(id)[self.view viewWithTag:kbg_Button_tag];
    testcnt++;
    NSLog(@"SWUpdate.. %d",testcnt);
    //check new sw
    client.isNeedHUD = [@"NO" mutableCopy];
    [client getPath:@"/updatenewsw"
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"update response: %@", response);
         if([response rangeOfString:@"OK"].location !=NSNotFound)
         {//update ok
             bgButton.hidden = TRUE;
             [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Update Software"
                                   message:@"Update successful!"
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         }
         else if(([response rangeOfString:@"FAIL"].location !=NSNotFound)||(testcnt>50))
         {
             NSString *msg;
             if (testcnt > 50) {
                 msg = @"Update timeout!";
             }
             else{
                 msg = @"Update failed!";
             }
             bgButton.hidden = TRUE;
             [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Update Software"
                                   message:msg
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         }
         else if([response rangeOfString:@"PROCESSING"].location !=NSNotFound)
         {
             NSLog(@"processing...");
             [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(SWUpdate) userInfo:nil repeats:NO];
             
         }
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
     client.isNeedHUD = [@"YES" mutableCopy];
    
}

-(IBAction)SWupdateButtonPressed
{
    //check new sw
    [client getPath:@"/checknewsw"
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"checksw response: %@", response);
         if([response rangeOfString:@"YES"].location !=NSNotFound)
         {
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Update Software"
                                   message:@"There is a newer version available.\nWould you like to update now?"
                                   delegate:self
                                   cancelButtonTitle:@"No"
                                   otherButtonTitles:@"Yes", nil];
             [alert show];
         }
         else{
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:@"Update Software"
                                   message:@"You already have the latest version."
                                   delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
             [alert show];
         }
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
    
}

-(IBAction)AboutButtonPressed
{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"AirMusic Control App"
                          message:@"Version 1.04\nCopyright@2014 mediaU.\nAll rights reserved.\n2014.02.19"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    //alert.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [alert show];
     


}

-(IBAction)WifiButtonPressed
{//
    NSString *strUrl = [self.wifiSettingUrl stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    UILabel *wifiLabel = (id)[self.view viewWithTag:kwifi_Label_tag];
    UIButton *wifiButton =(id)[self.view viewWithTag:kwifi_Button_tag];
    NSString *wifitext;  //test only @Jeanne.  2014.02.13
    //test only
    wifitext = [[NSString alloc] initWithFormat:@"    Wifi url: %@",self.wifiSettingUrl];
    [wifiButton setTitle:wifitext forState:UIControlStateNormal];
    
    
    //set wifi setting hide or display.  2014.02.12
    if ([self.wifiSetFlag isEqualToString:@"YES"]) {
        wifiLabel.hidden = FALSE;
        wifiButton.hidden = FALSE;
    }
    else{
        wifiLabel.hidden = TRUE;
        wifiButton.hidden = TRUE;
    }
}

- (void)viewDidLoad
{
    //UILabel *wifiLabel = (id)[self.view viewWithTag:kwifi_Label_tag];
    //UIButton *wifiButton =(id)[self.view viewWithTag:kwifi_Button_tag];
    //NSString *wifitext;  //test only @Jeanne.  2014.02.13
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    client = [ILHTTPClient clientWithBaseURL:self.toMagicUrl
                            showingHUDInView:self.view];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIButton *bgButton =(id)[self.view viewWithTag:kbg_Button_tag];
    NSLog(@"click button: %d (1: Yes, 0: NO)",buttonIndex);
    
    if (1 == buttonIndex) {
        NSLog(@"Go to software update process.");
        bgButton.hidden= FALSE;
        testcnt = 0;
        [MBProgressHUD fadeInHUDInView:self.view withText:@"Updating"];
        [self SWUpdate];
    }
}


@end
