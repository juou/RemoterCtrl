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

//Add for multi languages.  @Jeanne.  2014.03.13
#define kdlnaname_Label_tag       200
#define kswupdate_Label_tag       201
#define kdevice_Label_tag         202
#define kabout_Label_tag          203
#define kdlnaname_Button_tag      204
#define kswupdate_Button_tag      205
#define krescan_Button_tag        206
#define kabout_Button_tag         207
#define kbg_Button_tag            208
#define kdlnabg_image_tag         209
#define krename_Label_tag         210
#define knewname_Textfield_tag    211
#define kSave_Button_tag          212
#define kCancel_Button_tag        213

@interface BIDConfigViewController (){
    ILHTTPClient *client;   // http client
    int testcnt;     //for test only
}
@end

@implementation BIDConfigViewController

//Add for multi languages.  @Jeanne.  2014.03.13
-(void)refreshDisplay_forlanguage
{
    UILabel *dlnanameLabel =(id)[self.view viewWithTag:kdlnaname_Label_tag];
    UILabel *swupdateLabel =(id)[self.view viewWithTag:kswupdate_Label_tag];
    UILabel *deviceLabel =(id)[self.view viewWithTag:kdevice_Label_tag];
    UILabel *aboutLabel =(id)[self.view viewWithTag:kabout_Label_tag];
    //UIButton *dlnanameButton =(id)[self.view viewWithTag:kdlnaname_Button_tag];
    UIButton *swupdateButton =(id)[self.view viewWithTag:kswupdate_Button_tag];
    UIButton *rescanButton =(id)[self.view viewWithTag:krescan_Button_tag];
    UIButton *aboutButton =(id)[self.view viewWithTag:kabout_Button_tag];
    UILabel *renameLabel =(id)[self.view viewWithTag:krename_Label_tag];
    UIButton *SaveButton =(id)[self.view viewWithTag:kSave_Button_tag];
    UIButton *CancelButton =(id)[self.view viewWithTag:kCancel_Button_tag];
    
    dlnanameLabel.text = [[NSString alloc] initWithFormat:@"  %@",[self.strs valueForKey:@"DLNANAME"]];
    swupdateLabel.text = [[NSString alloc] initWithFormat:@"  %@",[self.strs valueForKey:@"IRSWUPDATE"]];
    deviceLabel.text = [[NSString alloc] initWithFormat:@"  %@",[self.strs valueForKey:@"IRDEVICE"]];
    aboutLabel.text = [[NSString alloc] initWithFormat:@"  %@",[self.strs valueForKey:@"ABOUT"]];
    
    [swupdateButton setTitle:[self.strs valueForKey:@"SWUPDATE"] forState:UIControlStateNormal];
    [rescanButton setTitle:[self.strs valueForKey:@"RESCAN"] forState:UIControlStateNormal];
    [aboutButton setTitle:[self.strs valueForKey:@"ABOUTDETAIL"] forState:UIControlStateNormal];
    
    renameLabel.text = [self.strs valueForKey:@"CHANGEDLNANAME"];
    
    [SaveButton setTitle:[self.strs valueForKey:@"SAVE"] forState:UIControlStateNormal];
    [CancelButton setTitle:[self.strs valueForKey:@"CANCEL"] forState:UIControlStateNormal];
    
}


//2014.03.05
-(IBAction)RescanPressed
{
    NSLog(@"Rescan pressed!");
    NSString *flag = @"YES";
    NSString *RescanKEY = @"RESCAN";
    [self.parentViewController setValue:flag forKey:RescanKEY];  //set rescan key
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
         NSString *updateStr = [self.strs valueForKey:@"SWUPDATE"]; //Add for multi languages.  @Jeanne.  2014.03.13
         NSString *SuccessStr = [self.strs valueForKey:@"UPDATESUCCESS_REMIND"]; //Add for multi languages.  @Jeanne.  2014.03.13
         NSString *FailStr = [self.strs valueForKey:@"UPDATEFAIL_REMIND"]; //Add for multi languages.  @Jeanne.  2014.03.13
         NSString *OKStr = [self.strs valueForKey:@"OK"]; //Add for multi languages.  @Jeanne.  2014.03.13
         
         NSLog(@"update response: %@", response);
         if([response rangeOfString:@"OK"].location !=NSNotFound)
         {//update ok
             bgButton.hidden = TRUE;
             [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:updateStr
                                   message:SuccessStr
                                   delegate:nil
                                   cancelButtonTitle:OKStr
                                   otherButtonTitles:nil];
             [alert show];
         }
         else if(([response rangeOfString:@"FAIL"].location !=NSNotFound)||(testcnt>50))
         {
             NSString *msg;
             if (testcnt > 50) {
                 msg = FailStr;//@"Update timeout!";
             }
             else{
                 msg = FailStr;//@"Update failed!";
             }
             bgButton.hidden = TRUE;
             [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:updateStr
                                   message:msg
                                   delegate:nil
                                   cancelButtonTitle:OKStr
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
    NSString *updateStr = [self.strs valueForKey:@"SWUPDATE"]; //Add for multi languages.  @Jeanne.  2014.03.13
    NSString *newversionStr = [self.strs valueForKey:@"NEWVERSION_REMIND"]; //Add for multi languages.  @Jeanne.  2014.03.13
    NSString *latestversionStr = [self.strs valueForKey:@"LATESTVERSION_REMIND"]; //Add for multi languages.  @Jeanne.  2014.03.13
    NSString *YesStr = [self.strs valueForKey:@"YES"]; //Add for multi languages.  @Jeanne.  2014.03.13
    NSString *NoStr = [self.strs valueForKey:@"NO"]; //Add for multi languages.  @Jeanne.  2014.03.13
    NSString *OKStr = [self.strs valueForKey:@"OK"]; //Add for multi languages.  @Jeanne.  2014.03.13
    
    
    
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
                                   initWithTitle:updateStr
                                   message:newversionStr
                                   delegate:self
                                   cancelButtonTitle:NoStr
                                   otherButtonTitles:YesStr, nil];
             [alert show];
         }
         else{
             UIAlertView *alert = [[UIAlertView alloc]
                                   initWithTitle:updateStr
                                   message:latestversionStr
                                   delegate:nil
                                   cancelButtonTitle:OKStr
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
    NSString *aboutStr = [self.strs valueForKey:@"ABOUTDETAIL"]; //Add for multi languages.  @Jeanne.  2014.03.13
    NSString *OKStr = [self.strs valueForKey:@"OK"]; //Add for multi languages.  @Jeanne.  2014.03.13
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:aboutStr
                          message:@"Version 1.0.16\nCopyright@2014 mediaU.\nAll rights reserved.\n2014.03.15"
                          delegate:nil
                          cancelButtonTitle:OKStr
                          otherButtonTitles:nil];

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
    
    //Add for multi languages.  @Jeanne.  2014.03.13
    [self refreshDisplay_forlanguage];
    
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
    NSLog(@"click button: %ld (1: Yes, 0: NO)",(long)buttonIndex);
    
    if (1 == buttonIndex) {
        NSLog(@"Go to software update process.");
        bgButton.hidden= FALSE;
        testcnt = 0;
        [MBProgressHUD fadeInHUDInView:self.view withText:@"Updating"];
        [self SWUpdate];
    }
}


@end
