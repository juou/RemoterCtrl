//
//  BIDFMViewController.m
//  RemoterCtrl
//
//  Created by 张巧玲 on 6/10/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import "BIDFMViewController.h"
#import "BIDViewController.h"
#import "BIDFMItemCell.h"

#define kMark_image_tag           80
#define kSignal_image_tag         51
#define kVol_Slider_tag           52
#define kBack_Button_tag          53
#define kList_Button_tag          54
#define kBackword_Button_tag      55
#define kForword_Button_tag       56
#define kBacktune_Button_tag      57
#define kFortune_Button_tag       58
#define kAutosearch_Button_tag    59
#define kStore_Button_tag         60
#define kFAV1_Button_tag          61
#define kFAV2_Button_tag          62
#define kFAV3_Button_tag          63
#define kFAV4_Button_tag          64
#define kFAV5_Button_tag          65
#define kMute_Button_tag          66
#define kAudiomode_Button_tag     67
#define kFreq_Label_tag           68
#define kFM_Tableview_tag         70
#define kPrtAdd_Button_tag             71
#define kPrtCancel_Button_tag          72
#define kRDS_Label_tag            74

static NSMutableArray *Items;
static NSString *CellIdentifier = @"Cell";

@interface BIDFMViewController (){
    ILHTTPClient *client;   // http client
    BOOL volSettingFlag;
    int muteFlag;
    unsigned FreqHigh;
    unsigned FreqLow;
    unsigned FreqSignal;
    NSString *AudioMode;
    BOOL searchflag;
    NSString *RDS;
    BOOL FreqSetFlag;
    BOOL FreqStatusGetFlag;
    BOOL StopGetStatus;
    BOOL AutoSearchRemind;
    BOOL AutoSearchMsgShow;
    BOOL QuitRefresh;
}

@end

@implementation BIDFMViewController

@synthesize FMFavTable;
@synthesize singlePicker;

+(BIDFMItemCell *)makeItemCell:(NSString *)FavNo SetName:(NSString *)name SetFreq: (NSString *)freq
{
    BIDFMItemCell *itemCell =[[BIDFMItemCell alloc] init];
    itemCell.FavNo = [FavNo mutableCopy];
    itemCell.name = [name mutableCopy];
    itemCell.Freq = [freq mutableCopy];
    
    return (itemCell);
}

-(void) ShowHideAddFAV: (NSInteger) IsShow
{
    UIButton *SaveButton = (id)[self.view viewWithTag:kPrtAdd_Button_tag];
    UIButton *CancelButton = (id)[self.view viewWithTag:kPrtCancel_Button_tag];
    
    if (IsShow) {
        [singlePicker reloadAllComponents];
        singlePicker.hidden = FALSE;
        SaveButton.hidden = FALSE;
        CancelButton.hidden = FALSE;
    }
    else{
        singlePicker.hidden = TRUE;
        SaveButton.hidden = TRUE;
        CancelButton.hidden = TRUE;
        
    }
}


-(void) UpdateFreqDisp : (NSInteger)updateMark
{
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    UILabel *CurFreq = (id)[self.view viewWithTag:kFreq_Label_tag];
    UIImageView *MarkImage = (id)[self.view viewWithTag:kMark_image_tag];
    CGFloat x;
    float freq;
    int i;
    BIDFMItemCell *itemCell;
    UIButton *FAVButton;
    UIImage * bgImage;
    UIImage * clickbgImage;
    

    bgImage = [UIImage imageNamed:@"btn_fm.png"];
    clickbgImage = [UIImage imageNamed:@"btn_fm_click.png"];
    
    
    CurFreq.text = [[NSString alloc] initWithFormat:@"%d.%02d",FreqHigh,FreqLow];
    
    //Check if it is Preset btn
    for (i=0; i<5; i++) {
        FAVButton = (id)[self.view viewWithTag:(kFAV1_Button_tag+i)];
        if (i <[Items count]) {
            itemCell = [Items objectAtIndex:i];
            if ([CurFreq.text isEqualToString:itemCell.Freq]) {
                //It is preset fav
                [FAVButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
                [FAVButton setBackgroundImage:clickbgImage forState:UIControlStateNormal];
            }else{
                [FAVButton setTitleColor:[UIColor colorWithRed:17.0/255 green:207.0/255 blue:255.0/255 alpha:1] forState:UIControlStateNormal];
                [FAVButton setBackgroundImage:bgImage forState:UIControlStateNormal];
            }
        }
        else{//Error
            [FAVButton setTitleColor:[UIColor colorWithRed:17.0/255 green:207.0/255 blue:255.0/255 alpha:1] forState:UIControlStateNormal];
            [FAVButton setBackgroundImage:bgImage forState:UIControlStateNormal];
        }
        
    }
    

    if (updateMark)
    {
        //For iphone: Mark width: 18,  320/24 = 13.3333
        //For ipad:   Mark width: 42   768/24 = 32
        //MarkImage.hidden = TRUE;
        freq = [CurFreq.text floatValue];
        if ([parent.CuriosDevice isEqualToString:@"ipad"]) {
            if(freq <= 85){
                x = 21;
            }else{
                x = (Float32)(((freq - 85)*32)-21);
            }
            MarkImage.frame =CGRectMake(x, 630, 42, 90);
        }
        else if([parent.CuriosDevice isEqualToString:@"iphone4"])
        {
            if(freq <= 85){
                x = 9;
            }else{
                x = (Float32)(((freq - 85)*13.3333)-9);
            }
            MarkImage.frame =CGRectMake(x, 284, 18, 40);
        }
        else
        {
            if(freq <= 85){
                x = 9;
            }else{
                x = (Float32)(((freq - 85)*13.3333)-9);
            }
            MarkImage.frame =CGRectMake(x, 326, 18, 40);
        }
        MarkImage.hidden = FALSE;
    }
    else{
        MarkImage.hidden = TRUE;
    }

}

-(void)UpdatePresetFreq
{
    UIButton *FAVButton;
    BIDFMItemCell *itemCell;
    int i;
    
    if (![Items count]) {
        return;
    }
    
    for (i=0; i<5; i++) {
        FAVButton = (id)[self.view viewWithTag:(kFAV1_Button_tag+i)];
        if (i < [Items count]) {
            itemCell = [Items objectAtIndex:i];
            [FAVButton setTitle:itemCell.Freq forState:UIControlStateNormal];
        }
        else{//Error
            [FAVButton setTitle:@" " forState:UIControlStateNormal];
        }
        
    }
    
}

//cmd list Begin--------------
//cmd = 0: get fm list
//cmd = 1: get fm status
//cmd list End----------------

-(void) decode_menu:(NSString *)response Forcmd: (NSInteger)cmd
{
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    UISlider *Volslider = (id)[self.view viewWithTag:kVol_Slider_tag];
    UIButton *MuteButton = (id)[self.view viewWithTag:kMute_Button_tag];
    //UILabel *CurFreq = (id)[self.view viewWithTag:kFreq_Label_tag];
    UIImageView *SignalImage = (id)[self.view viewWithTag:kSignal_image_tag];
    UIButton *AudioModeButton = (id)[self.view viewWithTag:kAudiomode_Button_tag];
    UILabel *RDSLabel = (id)[self.view viewWithTag:kRDS_Label_tag];  //2014.07.11
    
    
    
    
    char *p,*p1;
    char FAVNo[10],cnt[10],tmp[20],tmp2[20];
    char infostr[100];
    NSString *item_freq= [[NSString alloc] init];
    NSString *item_name= [[NSString alloc] init];
    NSString *item_id = [[NSString alloc] init];
    BIDFMItemCell *itemCell;
    char vol[5],mute[3];
    
    const char *str = [response UTF8String];
    memset(cnt, 0, sizeof(cnt));
    
    if (cmd == 0)
    { //cmd = 0: get fm list
        
        //Get Item cell
        p =strstr(str, "<item>");
        while (p) {
            //move after <item>
            str = p+6;
            
            //get item id
            memset(FAVNo, 0, sizeof(FAVNo));
            p1 = strstr(str, "<id>");
            if(p1)
            {
                for (int i = 4; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    FAVNo[i-4] = p1[i];
                }
            }
            
            //get item name
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<Freq>");
            if(p1)
            {
                for (int i = 6; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-6] = p1[i];
                }
            }
            
            item_id = [NSString stringWithCString:FAVNo encoding:NSUTF8StringEncoding];
            item_freq = [NSString stringWithCString:infostr encoding:NSUTF8StringEncoding];
            item_name = [[NSString alloc] initWithFormat:@"%@) %@Mhz",item_id,item_freq];
            
            //add itemcell to menu
            itemCell = [BIDFMViewController makeItemCell:item_id SetName:item_name SetFreq:item_freq];
            [Items addObject:itemCell];
            
            //goto next item
            p =strstr(str, "<item>");
            
        }//while(p)
        
        //Update FAV Freq
        [self UpdatePresetFreq];
    }
    else if (cmd == 1){ //cmd = 1: get fm status
        
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
        
        //Get signal
        //---------------
        memset(tmp, 0, sizeof(tmp));
        p1 = strstr(str, "<Signal>");
        if(p1)
        {
            for (int i = 8; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                tmp[i-8] = p1[i];
            }
            
            FreqSignal = atoi(tmp);  //to process signal display
            NSString *index = [NSString stringWithFormat:@"signal_%d.png",(FreqSignal-1)];
            UIImage *Image = [UIImage imageNamed:index];
            [SignalImage setImage:Image];
        }

        //---------------
        
        
        //Get Audio Mode
        //===================
        memset(tmp, 0, sizeof(tmp));
        p1 = strstr(str, "<Sound>");
        if(p1)
        {
            for (int i = 7; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                tmp[i-7] = p1[i];
            }
            
            AudioMode = [NSString stringWithFormat:@"%s",tmp];
            
            if ([AudioMode isEqualToString:@"MONO"]) {
                UIImage *AudioImage = [UIImage imageNamed:@"mono.png"];
                [AudioModeButton setImage:AudioImage forState:UIControlStateNormal];
            }else{
                UIImage *AudioImage = [UIImage imageNamed:@"stereo.png"];
                [AudioModeButton setImage:AudioImage forState:UIControlStateNormal];
            }
        }

        //===================
        
        
        //Get Search Flag
        //@@@@@@@@@@@@@@@@@@@@@
        memset(tmp, 0, sizeof(tmp));
        p1 = strstr(str, "<Search>");
        if(p1)
        {
            for (int i = 8; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                tmp[i-8] = p1[i];
            }
            
            if(strstr(tmp, "TRUE")){
                searchflag = TRUE;
            }else{
                if (AutoSearchRemind == TRUE) {
                    [self QuitForSearch];
                }
                searchflag = FALSE;
            }
        }
        //@@@@@@@@@@@@@@@@@@@@@
        
        
        //Get Freq
        memset(tmp, 0, sizeof(tmp));
        memset(tmp2, 0, sizeof(tmp2));
        p1 = strstr(str, "<Freq>");
        if(p1)
        {
            int i,j;
            for (i = 6; (p1[i]!=0)&&(p1[i]!='.'); i++) {
                tmp[i-6] = p1[i];
            }
            
            i++;
            j=i;
            for (; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                tmp2[i-j] = p1[i];
            }
            
            //CurFreq.text = [[NSString alloc] initWithFormat:@"%s.%s",tmp,tmp2];
            NSString *FreqHigh_str = [NSString stringWithCString:tmp encoding:NSUTF8StringEncoding];
            NSString *FreqLow_str = [NSString stringWithCString:tmp2 encoding:NSUTF8StringEncoding];
            FreqHigh = [FreqHigh_str intValue];
            FreqLow =[FreqLow_str intValue];
            
            //Update Mark Freq image
            [self UpdateFreqDisp: 1];
        }
        
        
        
        //Get RDS
        memset(infostr, 0, sizeof(infostr));
        p1 = strstr(str, "<RDS>");
        if(p1)
        {
            for (int i = 5; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                infostr[i-5] = p1[i];
            }
            
            RDS = [NSString stringWithCString:infostr encoding:NSUTF8StringEncoding];
            RDSLabel.text = RDS;  //2014.07.11
        }
        

    }
        
}

-(void) FMStatusGet
{
    NSString *path = @"/GetFMStatus";
    
    client.isNeedHUD = [@"NO" mutableCopy];
    FreqStatusGetFlag = TRUE;
    //Get FM status
    [client getPath:path
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
            {
               //NSLog(@"refreshmenu: %@", response);
               [self decode_menu:response Forcmd:1];
                FreqStatusGetFlag = FALSE;
         
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
                NSLog(@"Error: %@", error);
                FreqStatusGetFlag = FALSE;
            }
     ];
    client.isNeedHUD = [@"YES" mutableCopy];
}

-(void) FMRefreshTimer
{
    if (QuitRefresh) {
        QuitRefresh = FALSE;
        return;
    }
    
    if (StopGetStatus) {
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(FMRefreshTimer) userInfo:nil repeats:NO];
        return;
    }
    
    if((FMFavTable.hidden)&&!(FreqSetFlag)&&!(FreqStatusGetFlag)){ // not in search && not in fav list
        //Get FM status
        [self FMStatusGet];
    }
    
    if(searchflag){
       [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(FMRefreshTimer) userInfo:nil repeats:NO];
    }else{
       [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(FMRefreshTimer) userInfo:nil repeats:NO];
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    QuitRefresh = TRUE;

}


-(void) viewWillAppear:(BOOL)animated
{
    NSString *path = @"/GetFMFAVlist";
    UIImageView *MarkImage = (id)[self.view viewWithTag:kMark_image_tag];
    
    //Init Params
    StopGetStatus = TRUE;
    FreqStatusGetFlag = FALSE;
    FreqSetFlag = FALSE;
    volSettingFlag = FALSE;
    muteFlag = FALSE;
    MarkImage.hidden = TRUE;
    AutoSearchRemind = FALSE;
    QuitRefresh = FALSE;
    
    client = [ILHTTPClient clientWithBaseURL:self.toMagicUrl
                            showingHUDInView:self.view];
    
    
    
    //Get FM FAV list
    [client getPath:path
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
            {
               //NSLog(@"refreshmenu: %@", response);
         
               //remove table objects first
               [Items removeAllObjects];
               [self decode_menu:response Forcmd:0];
         
               //reload FM fav list
               [FMFavTable reloadData];
                
               //Get FM status
               [self FMStatusGet];
                
                StopGetStatus = FALSE;
                [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(FMRefreshTimer) userInfo:nil repeats:NO];
         
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
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

-(IBAction)backButtonPressed
{
    if(FALSE == FMFavTable.hidden){ //In FM FAV list, hide it first
        FMFavTable.hidden = TRUE;
    }
    else{// In FM menu, go back to main menu
        NSString *gochildMaincmd = [[NSString alloc] initWithFormat:@"/gochild?id=%d",uiMAIN_MENU];
        NSLog(@"goback to main menu");
        BIDViewController *parent = (BIDViewController *)self.parentViewController;
        [client getPath:gochildMaincmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             NSLog(@"response: %@", response);
             [parent gotoMainMenu];
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }
         ];
        
    }
}

-(IBAction)FMListButtonPressed
{
    //Display FM FAV list
    FMFavTable.hidden = FALSE;
}


-(IBAction)ManaulsearchButtonPressed:(UIButton *)button
{
    NSString *cmd;
    if (button.tag == kBackword_Button_tag) { //backword
        cmd = @"/SetFMManualsearch?direction=backword";
    }
    else{//forword
        cmd = @"/SetFMManualsearch?direction=forword";
    }
    
    [MBProgressHUD fadeInHUDInView:self.view withText:@"Please wait..."];
    AutoSearchRemind = TRUE;
    
    client.isNeedHUD = [@"NO" mutableCopy];
    
    [client getPath:cmd
            parameters:nil
            loadingText:nil
            successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
            {
               NSLog(@"manualsearch response: %@", response);
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
            {
               NSLog(@"Error: %@", error);
            }
     ];
    client.isNeedHUD = [@"YES" mutableCopy];
}



-(IBAction)BacktuneButtonPressed
{
    NSString *cmd;
    
    if (FreqLow >= 5) {
        FreqLow = FreqLow - 5;
    }else{
        FreqLow = FreqLow + 100 - 5;
        FreqHigh = FreqHigh - 1;
    }
    
    if((FreqHigh < 87)||((FreqHigh == 87) && (FreqLow < 50)))
    {
        FreqHigh = 87;
        FreqLow = 50;
    }
    
    FreqSetFlag = TRUE;
    //Update Mark Freq image
    [self UpdateFreqDisp : 0];
    
    //Set Freq to FM
    cmd = [NSString stringWithFormat:@"/SetFMFreq?freqhigh=%d&freqlow=%d", FreqHigh,FreqLow];
    
    //client.isNeedHUD = [@"NO" mutableCopy];
    [client getPath:cmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"Set freq response: %@", response);
         [self FMStatusGet];
         FreqSetFlag = FALSE;
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         FreqSetFlag = FALSE;
     }
     ];
    //client.isNeedHUD = [@"YES" mutableCopy];
}

-(IBAction)FortuneButtonPressed
{
    //UILabel *CurFreq = (id)[self.view viewWithTag:kFreq_Label_tag];
    NSString *cmd;

    FreqLow = FreqLow + 5;
    
    if (FreqLow >= 100) {
        FreqLow = FreqLow - 100;
        FreqHigh = FreqHigh + 1;
    }
    
    if ((FreqHigh > 108)||((FreqHigh == 108) && (FreqLow > 0)))
    {
        FreqHigh = 108;
        FreqLow = 0;
    }
    
    FreqSetFlag = TRUE;
    //CurFreq.text = [[NSString alloc] initWithFormat:@"%d.%02d",FreqHigh,FreqLow];
    //Update Mark Freq image
    [self UpdateFreqDisp : 0];
    
    //Set Freq to FM
    cmd = [NSString stringWithFormat:@"/SetFMFreq?freqhigh=%d&freqlow=%d", FreqHigh,FreqLow];
    
    [client getPath:cmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         [self FMStatusGet];
         FreqSetFlag = FALSE;
         NSLog(@"Set freq response: %@", response);
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         FreqSetFlag = FALSE;
         NSLog(@"Error: %@", error);
     }
     ];
}

-(void) QuitForSearch
{
    NSString *path = @"/GetFMFAVlist";
    [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
    
    if (AutoSearchMsgShow) { // it is auto search
        AutoSearchMsgShow = FALSE;
        
        //Get FM FAV list
        [client getPath:path
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             //NSLog(@"refreshmenu: %@", response);
             
             //remove table objects first
             [Items removeAllObjects];
             [self decode_menu:response Forcmd:0];
             
             //reload FM fav list
             [FMFavTable reloadData];
             //[self UpdatePresetFreq];
             
             //Get FM status
             [self FMStatusGet];
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }
         ];
        
    }
}

-(IBAction)AutosearchButtonPressed
{
    NSString *AutoRemindStr = [self.strs valueForKey:@"AUTO_REMIND"];
    NSString *SearchStr = [self.strs valueForKey:@"SEARCH"];
    NSString *OKStr = [self.strs valueForKey:@"OK"];
    NSString *CancelStr = [self.strs valueForKey:@"CANCEL"];
    
    
    
    AutoSearchMsgShow = TRUE;
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:SearchStr
                          message:AutoRemindStr
                          delegate:self
                          cancelButtonTitle:CancelStr
                          otherButtonTitles:OKStr, nil];
    [alert show];
}

-(void)AutoSearch
{
     NSString *cmd = @"/SetFMAutosearch";
    NSString *PleaseWaitStr = [self.strs valueForKey:@"WAIT_REMIND"];
    
    if(FreqStatusGetFlag){
        return;
    }
    
    [MBProgressHUD fadeInHUDInView:self.view withText:PleaseWaitStr];
    AutoSearchRemind = TRUE;
    
    client.isNeedHUD = [@"NO" mutableCopy];
    [client getPath:cmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"Set fm autosearch response: %@", response);
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }
     ];
    client.isNeedHUD = [@"YES" mutableCopy];
}

-(IBAction)StoreButtonPressed
{
    [self ShowHideAddFAV: 1];
}

-(IBAction)CancelPressed
{
    [self ShowHideAddFAV: 0];
}

-(IBAction)DonePressed
{
    NSInteger row = [self.singlePicker selectedRowInComponent:0];
    BIDFMItemCell *itemCell = [Items objectAtIndex:row];
    NSString *cmd = [NSString stringWithFormat:@"/SetFMFAV?fav=%d&freqhigh=%d&freqlow=%d",((int)row+1),FreqHigh,FreqLow];
    
    StopGetStatus = TRUE;
    [client getPath:cmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"set fav response: %@",response);
         itemCell.Freq = [[[NSString alloc] initWithFormat:@"%d.%02d",FreqHigh,FreqLow] mutableCopy];
         itemCell.name = [[[NSString alloc] initWithFormat:@"%d) %@Mhz",((int)row+1),itemCell.Freq] mutableCopy];
         [self UpdatePresetFreq];
         [FMFavTable reloadData];
         StopGetStatus = FALSE;
         [self ShowHideAddFAV: 0];
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         StopGetStatus = FALSE;
         [self ShowHideAddFAV: 0];
     }
     ];
}


-(IBAction)FAVButtonPressed:(UIButton *)button
{
    long FavNo;
    
    FavNo = button.tag - kFAV1_Button_tag + 1;
    
    //goto fav no
    NSString *cmd = [NSString stringWithFormat:@"/GotoFMfav?fav=%ld",FavNo];
    
    [client getPath:cmd
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSLog(@"goto favno %ld response: %@",FavNo,response);
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }
     ];
    
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

-(IBAction)AudiomodeButtonPressed
{

    NSString *AudioModeStr = [self.strs valueForKey:@"AUDIO_MODE"];
    NSString *AutoStr = [self.strs valueForKey:@"AUTO"];
    NSString *MonoStr = [self.strs valueForKey:@"MONO"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:AudioModeStr
                          message:nil
                          delegate:self
                          cancelButtonTitle:AutoStr
                          otherButtonTitles:MonoStr, nil];
    [alert show];
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
    
    if (Items == nil) {
        Items = [[NSMutableArray alloc] initWithCapacity:0];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -Table View Data Source Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([Items count]) {
       return [Items count];
    }
    else{
       return 1;  //if is empty, show empty item.  @Jeanne. 2014.03.10
    }
    
}//tableView:tableView numberOfRowsInSection:section

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    
    //Modified for support multi ios device.  @Jeanne. 2014.03.21
    if ([parent.CuriosDevice isEqualToString:@"ipad"])
    {
        return 96;
    }
    else{
        return 48;
    }
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BIDItemCell *itemCell;
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImage *bgImage;
    NSString *EmptyStr = [self.strs valueForKey:@"EMPTY"]; //Add for multi languages.  @Jeanne.  2014.03.13
    

    //if is empty, show empty item.  @Jeanne. 2014.03.10
    if ([Items count]) {
       itemCell = [Items objectAtIndex:indexPath.row];
    }

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.imageView.image = nil;
    
    //Modified for support multi ios device.  @Jeanne. 2014.03.21
    if ([parent.CuriosDevice isEqualToString:@"ipad"])
    {
        bgImage = [UIImage imageNamed:@"bar_bg_ipad"];
    }
    else{
        bgImage = [UIImage imageNamed:@"bar_bg"];
    }
    
    //if is empty, show empty item.  @Jeanne. 2014.03.10
    if (itemCell == nil) {
        cell.textLabel.text = EmptyStr;  //Add for multi languages.  @Jeanne.  2014.03.13
    }
    else{
        cell.textLabel.text = itemCell.name;
    }
    cell.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    cell.textLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    cell.textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];

    
    //Heiti SC
    //Modified for support multi ios device.  @Jeanne. 2014.03.21
    if ([parent.CuriosDevice isEqualToString:@"ipad"])
    {
        cell.textLabel.font = [UIFont systemFontOfSize:30];
    }
    else{
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }

    return cell;
    
}//tableView:tableView cellForRowAtIndexPath:indexPath

#pragma mark -Table View Delegate Methods

//调整缩进 @Jeanne. 2014.03.25
-(NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    
    if ([parent.CuriosDevice isEqualToString:@"ipad"])
    {
        return 2;
    }
    else{
        return 0;
    }
}


//tableView didSelectRowAtIndexPath:会在一行被选中时调用，告诉用户要单击细节展开按钮而不是选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //goto fav no
    NSString *cmd = [NSString stringWithFormat:@"/GotoFMfav?fav=%d",((int)(indexPath.row)+1)];
    UILabel *CurFreq = (id)[self.view viewWithTag:kFreq_Label_tag];
    BIDFMItemCell *itemCell;
    
    if ([Items count]){
        itemCell = [Items objectAtIndex:indexPath.row];
        [client getPath:cmd
              parameters:nil
              loadingText:nil
              successText:nil
              success:^(AFHTTPRequestOperation *operation, NSString *response)
              {
                  NSLog(@"goto favno %d response: %@",((int)indexPath.row+1),response);
                  
                  //update FM Freq.
                  CurFreq.text = itemCell.Freq;
                  
                  //Hide fav list.
                  FMFavTable.hidden = TRUE;
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  NSLog(@"Error: %@", error);
              }
        ];
    }
    
    
    //取消选中项
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    

}

#pragma mark-
#pragma mark Picker Data Source Methods
//选取器只有一个组件，so return 1
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//选取器组件包含几行数据
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 20;
}

#pragma mark Picker Delegate Methods
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    BIDFMItemCell *itemCell;
    NSString *itemStr;
    NSString *EmptyStr = [self.strs valueForKey:@"EMPTY"];
    BIDViewController *parent = (BIDViewController *)self.parentViewController;
    
    
    //modified from 'pos' to 'Preset'    @Jeanne.  2014.03.03
    if(row < [Items count])
    {
            itemCell = [Items objectAtIndex:row];
            itemStr = itemCell.name;
            
    }
    else{
            itemStr = [[NSString alloc] initWithFormat:@"%d) %@",(int)(row+1),EmptyStr];
    }

    
    label.text = [[NSString alloc] initWithFormat:@"   %@",itemStr];
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    //Modified for support multi ios device.  @Jeanne. 2014.03.21
    if ([parent.CuriosDevice isEqualToString:@"ipad"])
    {
        //label.frame = CGRectMake(0.0f, 0.0f, 500.0f, 60.0f);
        label.font =[UIFont systemFontOfSize:30];
    }
    
    return label;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *cmd;
    NSLog(@"click button: %ld (1: Yes, 0: NO)",(long)buttonIndex);
    
    if (AutoSearchMsgShow) {
        if (1 == buttonIndex){
            [self AutoSearch];
        }else{
            AutoSearchMsgShow = FALSE;
        }
    }else{

        if (1 == buttonIndex) {//Set Mono
            NSLog(@"Set Mono");
            cmd = @"/SetFMMode?mode=mono";
        }
        else{//Set Stereo
            NSLog(@"Set Stereo");
            cmd = @"/SetFMMode?mode=stereo";
        }
        
        StopGetStatus = TRUE;
        [client getPath:cmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             StopGetStatus = FALSE;
             NSLog(@"set mode response: %@",response);
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             StopGetStatus = FALSE;
             NSLog(@"Error: %@", error);
         }
         ];
    }
}

@end
