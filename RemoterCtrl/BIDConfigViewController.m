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


#define kdlnabg_image_tag         4
#define kdlnaname_Button_tag      5
#define kbg_Button_tag            6
#define krename_Label_tag         7
#define kSave_Button_tag          8
#define kCancel_Button_tag        9

@interface BIDConfigViewController (){
    ILHTTPClient *client;   // http client
    int testcnt;     //for test only
}
@end

@implementation BIDConfigViewController

//2014.03.05
-(IBAction)RescanPressed
{
    NSLog(@"Rescan pressed!");
    [self.view removeFromSuperview];
}

-(void) DisplayRenameMenu:(NSInteger)bDispFlag
{
    UIImageView *dlnabgImage = (id)[self.view viewWithTag:kdlnabg_image_tag];
    UIButton *bgButton =(id)[self.view viewWithTag:kbg_Button_tag];
    UIButton *SaveButton =(id)[self.view viewWithTag:kSave_Button_tag];
    UIButton *CancelButton =(id)[self.view viewWithTag:kCancel_Button_tag];
    UILabel *RenameLabel =(id)[self.view viewWithTag:krename_Label_tag];

    if (1 == bDispFlag) { //Display Rename menu
        dlnabgImage.hidden = FALSE;
        bgButton.hidden = FALSE;
        SaveButton.hidden = FALSE;
        CancelButton.hidden = FALSE;
        RenameLabel.hidden = FALSE;
        if (self.dlna_name != nil) {
            self.rename_field.text = self.dlna_name;
        }
        self.rename_field.hidden = FALSE;
    }
    else
    {
        dlnabgImage.hidden = TRUE;
        bgButton.hidden = TRUE;
        SaveButton.hidden = TRUE;
        CancelButton.hidden = TRUE;
        RenameLabel.hidden = TRUE;
        self.rename_field.hidden = TRUE;
    }
}

-(IBAction)textFieldDoneEditing:(id)sender
{
    [self.rename_field resignFirstResponder];
    [sender resignFirstResponder];
}

-(IBAction)SaveButtonPressed
{
    UIButton *dlnaButton =(id)[self.view viewWithTag:kdlnaname_Button_tag];
    NSString *newname = [[NSString alloc] initWithString:[self.rename_field.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
    if (!([self.rename_field.text isEqualToString:@""]))
    {//save the new name to device
        NSString *setdlnanamecmd = [[NSString alloc] initWithFormat:@"/setdlnaname?name=%@",newname];
        
        NSLog(@"Set dlna name to device!");
        //set dlna name  @Jeanne. 2014.03.03
        //=========================================
        client.isNeedHUD = [@"NO" mutableCopy];
        [client getPath:setdlnanamecmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             NSLog(@"set dlnaname response: %@", response);
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
        client.isNeedHUD = [@"YES" mutableCopy];
        //=========================================
    }
    
    //close the rename menu
    NSLog(@"Close the rename menu after 500ms");
    self.dlna_name = [self.rename_field.text mutableCopy];
    [dlnaButton setTitle:self.rename_field.text forState:UIControlStateNormal];
    [self.rename_field resignFirstResponder];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(CancelButtonPressed) userInfo:nil repeats:NO];
    
    
}
-(IBAction)CancelButtonPressed
{
    NSLog(@"CancelButtonPressed");
    [self.rename_field resignFirstResponder];
    [self DisplayRenameMenu: 0]; // hide Rename Menu
}
-(IBAction)dlnaRenameButtonPressed
{
    //show Rename Menu
    [self DisplayRenameMenu: 1];
}

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
                          message:@"Version 1.0.12\nCopyright@2014 mediaU.\nAll rights reserved.\n2014.03.05"
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    //alert.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [alert show];
     


}

//move to tab menu.  @Jeanne. 2014.03.03
/*
-(IBAction)WifiButtonPressed
{//
    NSString *strUrl = [self.wifiSettingUrl stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) decodedlna_response:(NSString *)response
{
    char *p;
    char dl_name[50];
    const char *str = [response UTF8String];
    memset(dl_name, 0, sizeof(dl_name));
    
    //Get menu id
    p =strstr(str, "<name>");
    if(p)
    {
        for (int i = 6; (p[i]!=0)&&(p[i]!='<'); i++) {
            dl_name[i-6] = p[i];
        }
    }
    
    NSString *name=[NSString stringWithCString:dl_name encoding:NSUTF8StringEncoding];
    
    if (self.dlna_name == nil) {
        self.dlna_name = [[NSMutableString alloc] initWithString:name];
    }
    else{
        self.dlna_name = [name mutableCopy];
    }
    
    NSLog(@"dlname=%@",self.dlna_name);
    
}

-(void)viewWillAppear:(BOOL)animated
{
    UIButton *dlnaButton =(id)[self.view viewWithTag:kdlnaname_Button_tag];
    //NSString *wifitext;  //test only @Jeanne.  2014.02.13
    //test only
    //wifitext = [[NSString alloc] initWithFormat:@"    Wifi url: %@",self.wifiSettingUrl];
    //[wifiButton setTitle:wifitext forState:UIControlStateNormal];
    
    /* move to main tab menu  @Jeanne 2014.03.03
    //set wifi setting hide or display.  2014.02.12
    if ([self.wifiSetFlag isEqualToString:@"YES"]) {
        wifiLabel.hidden = FALSE;
        wifiButton.hidden = FALSE;
    }
    else{
        wifiLabel.hidden = TRUE;
        wifiButton.hidden = TRUE;
    }
    */
    
    if (client == nil) {
        client = [ILHTTPClient clientWithBaseURL:self.toMagicUrl
                                showingHUDInView:self.view];
    }
    
    //get dlna name  @Jeanne. 2014.03.03
    //=========================================
    client.isNeedHUD = [@"NO" mutableCopy];
    [client getPath:@"/getdlnaname"
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"get dlnaname response: %@", response);
         [self decodedlna_response:response];
         if (self.dlna_name != nil) {
             //[dlnaButton setTitleEdgeInsets:UIEdgeInsetsMake(4, 14, 0, 0)];
             [dlnaButton setTitle:self.dlna_name forState:UIControlStateNormal];
         }
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         if (self.dlna_name != nil) {
             [dlnaButton setTitle:self.dlna_name forState:UIControlStateNormal];
         }
     }];
    client.isNeedHUD = [@"YES" mutableCopy];
    //=========================================
    
    
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
