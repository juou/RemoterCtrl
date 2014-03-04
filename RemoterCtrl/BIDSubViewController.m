//
//  BIDSubViewController.m
//  RemoterCtrl
//
//  Created by 张巧玲 on 1/7/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import "BIDSubViewController.h"
#import "UIImageView+AFNetworking.h"
#import <string.h>
#import "ILHTTPClient.h"
#import "BIDItemCell.h"

//Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
#define kMain_Tabbar_tag       5
#define kMain_2_Tabbar_tag     100

#define kMenu_Tableview_tag    1
#define kBack_Button_tag       2
#define kMute_Button_tag       3
#define kVol_Slider_tag        4
#define kPlay_Label_tag        6
#define kPlayname_Label_tag    7
#define kRadio_image_tag       8
#define kVolbg_image_tag       9
#define kStop_Button_tag       10
#define kPlaynamebg_image_tag       11
#define kRadiobg_image_tag          12
#define kAlbumbg_image_tag          13
#define kAlbum_image_tag            14
#define kPlayinfo_Label_tag           19
#define kPreset_1_Button_tag          20
#define kPreset_2_Button_tag          21
#define kPreset_3_Button_tag          22
#define kPreset_4_Button_tag          23
#define kPreset_5_Button_tag          24
#define kSearch_TextFiled_tag         25
#define kSearch_image_tag             26
#define kSearch_Button_tag            27
#define kPrtPlay_1_Button_tag          28
#define kPrtPlay_2_Button_tag          29
#define kPrtPlay_3_Button_tag          30
#define kPrtPlay_4_Button_tag          31
#define kPrtPlay_5_Button_tag          32
#define kPrtPlay_Add_Button_tag        33
#define kPrtbg_Button_tag              34
#define kPrtAdd_Button_tag             35
#define kPrtCancel_Button_tag          36

static NSMutableArray *Items;
static NSMutableArray *PresetItems;
static NSString *CellIdentifier = @"Cell";
//Paul Request: in main menu, items should be on fix pos. Jeanne. 2014.03.03
static NSMutableArray *FixMainMenuItems;

BIDItemCell *makeItemCell(NSString *submenuId, NSString *name, NSString *status)
{
    BIDItemCell *itemCell =[[BIDItemCell alloc] init];
    itemCell.submenuId = [submenuId mutableCopy];
    itemCell.name = [name mutableCopy];
    itemCell.status = [status mutableCopy];
    
    return (itemCell);
    
}

@interface BIDSubViewController (){
   ILHTTPClient *client;   // http client
    BOOL volSettingFlag;   //2014.01.26
    int muteFlag;         //2014.01.26
    NSMutableString *logo_url;
    NSMutableString *album_url;
    BOOL SearchInputFlag;  //2014.02.11
    NSMutableString *playitemid;
    BOOL AddPresetFlag;    //2014.02.18
}
@end

@implementation BIDSubViewController

//Paul Request: in main menu, items should be on fix pos. Jeanne. 2014.03.03
-(void)MakeMainMenuItem
{
    NSString *item_subid = [[NSString alloc] init];
    BIDItemCell *itemCell;
    int mainmenu_subid[3] = {uiLOCATIONRADIO_MENU,uiINTERNET_RADIO_MENU,uiUPNP_MENU};
    int i,cnt;
    BOOL foundflag;
    
    if ([FixMainMenuItems count] != 0) {
        [FixMainMenuItems removeAllObjects];
    }
    
    
    for (i= 0; i<3; i++) {
        item_subid = [NSString stringWithFormat:@"%d",mainmenu_subid[i]];
        
        foundflag = FALSE;
        for(cnt = 0; cnt < [Items count]; cnt++)
        {
            itemCell = [Items objectAtIndex:cnt];
            if ([itemCell.submenuId isEqualToString:item_subid]) {
                foundflag = TRUE;
                break;
            }
        }
        
        if (foundflag == TRUE) {
            //add itemcell to main menu
            [FixMainMenuItems addObject:itemCell];
        }
        
    }
    
    NSLog(@"MakeMainMenuItem OK");
    
}

-(IBAction)CancelPressed
{
    UIButton *BgButton =(id)[self.view viewWithTag:kPrtbg_Button_tag];
    UIButton *AddButton =(id)[self.view viewWithTag:kPrtAdd_Button_tag];
    UIButton *CancelButton =(id)[self.view viewWithTag:kPrtCancel_Button_tag];
    BgButton.hidden = TRUE;
    self.singlePicker.hidden = TRUE;
    AddButton.hidden = TRUE;
    CancelButton.hidden = TRUE;
    AddPresetFlag = FALSE;  //2014.02.18
    
}

-(void)AddPresetprocess
{
    NSInteger row = [self.singlePicker selectedRowInComponent:0];
    if (![playitemid isEqualToString:@"noplayid"])
    {
        NSString *setFavcmd;
        if (5 == row) {
            setFavcmd = [[NSString alloc] initWithFormat:@"/setfav?id=%@&item=%@&favpos=0",self.menuProperty.menuId,playitemid];
        }
        else{
            setFavcmd = [[NSString alloc] initWithFormat:@"/setfav?id=%@&item=%@&favpos=%d",self.menuProperty.menuId,playitemid,row+1];
        }
        NSLog(@"CMD: %@",setFavcmd);
        [client getPath:setFavcmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             NSLog(@"setfav response: %@", response);
             if([response rangeOfString:@"OK"].location !=NSNotFound)
             {//update ok
                 UIAlertView *alert = [[UIAlertView alloc]
                                       initWithTitle:@"Preset process"
                                       message:@"Add to preset successful!"
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
                 [alert show];
             }
             else if([response rangeOfString:@"FAIL"].location !=NSNotFound)
             {
                 NSString *Failreson;
                 
                 if([response rangeOfString:@"EXIST"].location !=NSNotFound){
                     Failreson = @"Add to preset failed!\nThis station has already in preset list.";
                 }else if([response rangeOfString:@"FULL"].location !=NSNotFound){
                     Failreson = @"Add to preset failed!\nThe preset list is full.";
                 }else if([response rangeOfString:@"NO_SUCH_STATION"].location !=NSNotFound){
                     Failreson = @"Add to preset failed!\nNo such station.";
                 }else{
                     Failreson = @"Add to preset failed!";
                 }
                 
                 [MBProgressHUD fadeOutHUDInView:self.view withSuccessText:nil];
                 UIAlertView *alert = [[UIAlertView alloc]
                                       initWithTitle:@"Preset process"
                                       message:Failreson
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
                 [alert show];
             }
             //[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refresh_presetbtn) userInfo:nil repeats:NO];
             [self refresh_presetbtn]; //test delay
             [self CancelPressed];
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             [self CancelPressed];
         }];
    }
    
}

-(IBAction)AddPressed
{
    NSInteger row = [self.singlePicker selectedRowInComponent:0];
    BIDItemCell *itemCell;
    BOOL AddDirectly = FALSE;
    
    NSLog(@"Select row: %d",row);
    
    if (row < 5) {//on pos 0-4
        itemCell = [PresetItems objectAtIndex:row];
        if([itemCell.status isEqualToString:@"emptyfile"])
        {
            AddDirectly = TRUE;
        }
    }
    else if(5 == row)
    {
       AddDirectly = TRUE;
    }
    
    if (TRUE == AddDirectly)
    {
        [self AddPresetprocess]; //do add preset process.  @Jeanne. 2014.03.04
    }
    else{//need to replace
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"My Favorite"
                              message:@"This preset is already exist, do you want to overwrite it?"
                              delegate:self
                              cancelButtonTitle:@"No"
                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }

}

-(IBAction)AddPresetButtonPressed
{
    UIButton *BgButton =(id)[self.view viewWithTag:kPrtbg_Button_tag];
    UIButton *AddButton =(id)[self.view viewWithTag:kPrtAdd_Button_tag];
    UIButton *CancelButton =(id)[self.view viewWithTag:kPrtCancel_Button_tag];
    [self.singlePicker reloadAllComponents];
    BgButton.hidden = FALSE;
    self.singlePicker.hidden = FALSE;
    AddButton.hidden = FALSE;
    CancelButton.hidden = FALSE;
    AddPresetFlag = TRUE;  //2014.02.18
}

-(void) clearSearchFlag
{
    SearchInputFlag = FALSE;
}

-(IBAction)backgroundTap:(id)sender
{
    [self.SearchField resignFirstResponder];
}

-(IBAction)textFieldDoneEditing:(id)sender
{
    [self.SearchField resignFirstResponder];
    [sender resignFirstResponder];
    
    if (!([self.SearchField.text isEqualToString:@""]))
    {//Set Search string
        NSString *SetSearchStrcmd = [[NSString alloc] initWithFormat:@"/searchstn?str=%@",self.SearchField.text];
        
        NSLog(@"Set Search String: %@",SetSearchStrcmd);
        [client getPath:SetSearchStrcmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             NSString *gochildcmd = [[NSString alloc] initWithFormat:@"/gochild?id=%d",uiNEWSEARCHRADIOEX_MENU];
             //NSLog(@"response: %@", response);
             NSLog(@"go to New Search menu");
             //go to New Search menu
             [client getPath:gochildcmd
                  parameters:nil
                 loadingText:nil
                 successText:nil
                     success:^(AFHTTPRequestOperation *operation, NSString *response)
              {
                  //NSLog(@"response: %@", response);
                  NSLog(@"Refresh menu");
                  [self decode_menu:response Forcmd:2]; //2:gochild decode
                  SearchInputFlag = FALSE;
                  [self refresh_menu];
                  
              }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  NSLog(@"Error: %@", error);
              }
              ];
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }
         ];
    }
}


-(void) init_playinfo
{
    if (logo_url == nil) {
        logo_url = [[NSMutableString alloc] init];
    }
    
    if (album_url == nil) {
        album_url = [[NSMutableString alloc] init];
    }
    
    if (playitemid == nil) {
        playitemid = [[NSMutableString alloc] init];
    }
    
    logo_url = [@"nourl" mutableCopy];
    album_url = [@"nourl" mutableCopy];
    
    
}

//index:
// 1: main menu
// 2: other menu
// 3: play menu
-(void) menu_disp_ctrl:(int)index
{
    UITableView *tableView = (id)[self.view viewWithTag:kMenu_Tableview_tag];           //other menu,main menu
    UIButton *BackButton =(id)[self.view viewWithTag:kBack_Button_tag];                 //other menu,play menu
    UIButton *MuteButton =(id)[self.view viewWithTag:kMute_Button_tag];                 //play menu
    UISlider *Volslider = (id)[self.view viewWithTag:kVol_Slider_tag];                  //play menu
    UILabel *playLabel = (id)[self.view viewWithTag:kPlay_Label_tag];                   //play menu
    UILabel *playName = (id)[self.view viewWithTag:kPlayname_Label_tag];                //play menu
    UIImageView *radioImage = (id)[self.view viewWithTag:kRadio_image_tag];             //play menu
    UIImageView *VolbgImage = (id)[self.view viewWithTag:kVolbg_image_tag];             //play menu
    UIButton *StopButton =(id)[self.view viewWithTag:kStop_Button_tag];                 //play menu
    UIImageView *PlaynamebgImage = (id)[self.view viewWithTag:kPlaynamebg_image_tag];   //play menu
    UIImageView *RadiobgImage = (id)[self.view viewWithTag:kRadiobg_image_tag];         //play menu
    UIImageView *AlbumbgImage = (id)[self.view viewWithTag:kAlbumbg_image_tag];         //play menu
    UIImageView *AlbumImage = (id)[self.view viewWithTag:kAlbum_image_tag];             //play menu
    UILabel *playinfoLabel = (id)[self.view viewWithTag:kPlayinfo_Label_tag];            //play menu
    UIView *parentView = self.parentViewController.view;
    UITabBar *tabBar;// =(id)[parentView viewWithTag:kMain_Tabbar_tag];           //main menu, other menu
    //Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
    UIButton *PresetButton;                                            //internet menu, play menu
    NSString *internetRadioId = [[NSString alloc] initWithFormat:@"%d",uiINTERNET_RADIO_MENU];
    NSString *upnpId = [[NSString alloc] initWithFormat:@"%d",uiUPNP_MENU];   //Fix Bug:UPnP時,加入preset應無功能  @Jeanne. 2014.03.03
    int i;
    NSInteger tag;
    BOOL Preset_hideflag,PrtPlay_hideflag;
    
    UIImageView *SearchImage = (id)[self.view viewWithTag:kSearch_image_tag];     //New Search Menu
    UIButton *SearchButton = (id)[self.view viewWithTag:kSearch_Button_tag];  //New Search Menu

    NSString *myfavId = [[NSString alloc] initWithFormat:@"%d",uiFAVEX_MENU];
    
    
    //Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
    if ([self.wifiSetFlag isEqualToString:@"YES"]) { //include wifi setting
        tabBar =(id)[parentView viewWithTag:kMain_2_Tabbar_tag];
    }else{//not include wifi setting
        tabBar =(id)[parentView viewWithTag:kMain_Tabbar_tag];
    }
    
    
    //Set Preset play Button flag
    //Fix Bug:UPnP時,加入preset應無功能  @Jeanne. 2014.03.03
    //================================================================
    if((3 == index)&&(FALSE ==SearchInputFlag)&&(!([self.menuProperty.menuId isEqualToString:upnpId])))
    {//play menu, and not in upnp
        PrtPlay_hideflag = FALSE;
    }
    else
    {
        PrtPlay_hideflag = TRUE;
    }
    for (i = 0; i < 6; i++) {
        tag = kPrtPlay_1_Button_tag + i;
        PresetButton = (id)[self.view viewWithTag:tag];
        PresetButton.hidden = PrtPlay_hideflag;
        if (i==5)
        {//preset add button
            UIImage *addbgImage = [UIImage imageNamed:@"btn_add.png"];
            UIImage *adddisbgImage = [UIImage imageNamed:@"btn_add_dis.png"];
            
            if([self.menuProperty.menuId isEqualToString:myfavId])
            {
                PresetButton.backgroundColor = [UIColor colorWithPatternImage:adddisbgImage];
                PresetButton.enabled = FALSE;
            }
            else{
                PresetButton.backgroundColor = [UIColor colorWithPatternImage:addbgImage];
                PresetButton.enabled = TRUE;
            }
        }
    }
    //================================================================
    
    //Set Preset Button flag
    //================================================================
    if(([self.menuProperty.menuId isEqualToString:internetRadioId])
       &&(FALSE ==SearchInputFlag)
       )
    { //internet menu
        Preset_hideflag = FALSE;
    }
    else
    {
        Preset_hideflag = TRUE;
    }
    
    for (i = 0; i < 5; i++) {
        tag = kPreset_1_Button_tag + i;
        PresetButton = (id)[self.view viewWithTag:tag];
        PresetButton.hidden = Preset_hideflag;
    }
    //================================================================
    
    
    switch (index) {
        case 1: //main menu
            tableView.hidden = FALSE;//TRUE;   //2014.02.07
            BackButton.hidden = TRUE;
            MuteButton.hidden = TRUE;
            Volslider.hidden = TRUE;
            tabBar.hidden = FALSE;
            playLabel.hidden = TRUE;
            playName.hidden = TRUE;
            radioImage.hidden = TRUE;
            VolbgImage.hidden = TRUE;
            StopButton.hidden = TRUE;
            PlaynamebgImage.hidden = TRUE;
            RadiobgImage.hidden = TRUE;
            AlbumbgImage.hidden = TRUE;
            AlbumImage.hidden = TRUE;
            //LocalButton.hidden = FALSE;
            //RadioButton.hidden = FALSE;
            //MediaButton.hidden = FALSE;
            //MainbgImage.hidden = FALSE;
            playinfoLabel.hidden = TRUE;
            break;
        
        case 2: //other menu
            tableView.hidden = FALSE;
            BackButton.hidden = FALSE;
            MuteButton.hidden = TRUE;
            Volslider.hidden = TRUE;
            tabBar.hidden = FALSE;
            playLabel.hidden = TRUE;
            playName.hidden = TRUE;
            radioImage.hidden = TRUE;
            VolbgImage.hidden = TRUE;
            StopButton.hidden = TRUE;
            PlaynamebgImage.hidden = TRUE;
            RadiobgImage.hidden = TRUE;
            AlbumbgImage.hidden = TRUE;
            AlbumImage.hidden = TRUE;
            playinfoLabel.hidden = TRUE;
            break;
            
        case 3: //play menu
            tableView.hidden = TRUE;
            BackButton.hidden = FALSE;
            MuteButton.hidden = FALSE;
            Volslider.hidden = FALSE;
            tabBar.hidden = TRUE;
            playLabel.hidden = FALSE;
            playName.hidden = FALSE;
            radioImage.hidden = FALSE;
            VolbgImage.hidden = FALSE;
            StopButton.hidden = FALSE;
            PlaynamebgImage.hidden = FALSE;
            RadiobgImage.hidden = FALSE;
            AlbumbgImage.hidden = FALSE;
            AlbumImage.hidden = FALSE;
            playinfoLabel.hidden = FALSE;
            break;
            
        default:
            break;
    }
    
    //2014.02.07------------------------  begin
    [self init_playinfo];
    UIImage *radiodfImage = [UIImage imageNamed:@"radio"];
    [radioImage setImage:radiodfImage];
    UIImage *albumdfImage = [UIImage imageNamed:@"album"];
    [AlbumImage setImage:albumdfImage];
    playLabel.text = @" ";
    playinfoLabel.text = @" ";
    //2014.02.07------------------------ end
    
    //2014.02.11 add for New Search Menu -------- begin
    if(TRUE ==SearchInputFlag)
    {
        tableView.hidden = TRUE;
        SearchImage.hidden = FALSE;
        SearchButton.hidden = FALSE;
        self.SearchField.hidden = FALSE;
    }
    else
    {
        SearchImage.hidden = TRUE;
        SearchButton.hidden = TRUE;
        self.SearchField.hidden = TRUE;
    }
    //2014.02.11 add for New Search Menu -------- end
}//menu_disp_ctrl:index



-(IBAction)backButtonPressed
{
    UILabel *playLabel = (id)[self.view viewWithTag:kPlay_Label_tag];
    
    if (TRUE == SearchInputFlag) {
        self.SearchField.text = @"";
        SearchInputFlag = FALSE;
        [self.SearchField resignFirstResponder];
        [self menu_disp_ctrl:2]; //other menu ctrl
    }
    else
    {
      if(playLabel.hidden == FALSE){
        NSLog(@"In Play menu, goback to menulist!!!\n");
          
          playitemid = [@"noplayid" mutableCopy]; //2014.02.18
          
          playLabel.hidden = TRUE; //set playLabel hide first, to stop get playinfo
        
        //send back cmd
        [client getPath:@"/back"
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             //NSLog(@"response: %@", response);
             [self decode_menu:response Forcmd:1]; //1:back cmd decode
             [self refresh_menu]; //2014.02.10
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             //Reset menu display ctrl @Jeanne. 2014.01.29
             if([self.menuProperty.menuId isEqualToString:@"1"])
             {
                 NSLog(@"to main menu!!!\n");
                 [self menu_disp_ctrl:1];  //main menu ctrl
             }
             else
             {
                 NSLog(@"to menu (%@)!!!\n",self.menuProperty.menuId);
                 [self menu_disp_ctrl:2];  //other menu ctrl
                 
             }
             
         }];
        
       }
       else{
        
        //send back cmd
        [client getPath:@"/back"
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             //NSLog(@"response: %@", response);
             [self decode_menu:response Forcmd:1]; //1:back cmd decode
             [self refresh_menu];
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             
         }];
      }
    }
    
    
    // [self performSelector:@selector(foo) withObject:nil afterDelay:5000.0f];
    
    
}//backButtonPressed

-(IBAction)muteButtonPressed
{
    UIButton *MuteButton =(id)[self.view viewWithTag:kMute_Button_tag];
    UISlider *Volslider = (id)[self.view viewWithTag:kVol_Slider_tag];

    
    if(volSettingFlag)
    {
        NSLog(@"already in setting vol, ignore it!\n");
    }
    else
    {
        if (0 == muteFlag) {
            muteFlag = 1;
            [MuteButton setImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateNormal];
            Volslider.enabled = FALSE;
        }
        else{
            muteFlag = 0;
            [MuteButton setImage:[UIImage imageNamed:@"vol.png"] forState:UIControlStateNormal];
            Volslider.enabled = TRUE;
        }
        
        int progress = lroundf(Volslider.value); //获取滑块当前值，四舍五入
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
}//muteButtonPressed

-(IBAction)volChange:(UISlider *)sender
{
    int progress = lroundf(sender.value); //获取滑块当前值，四舍五入
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
    
}//volChange

-(IBAction)PresetButtonPressed:(UIButton *)button
{
    NSInteger hotkey;
    NSString *playhotkeycmd;
    BIDItemCell *itemCell;
    UILabel *playName = (id)[self.view viewWithTag:kPlayname_Label_tag];                //play menu
    

    switch (button.tag) {
        case kPreset_1_Button_tag:
        case kPreset_2_Button_tag:
        case kPreset_3_Button_tag:
        case kPreset_4_Button_tag:
        case kPreset_5_Button_tag:
            hotkey = button.tag - kPreset_1_Button_tag + 1;
            break;
            
        case kPrtPlay_1_Button_tag:
        case kPrtPlay_2_Button_tag:
        case kPrtPlay_3_Button_tag:
        case kPrtPlay_4_Button_tag:
        case kPrtPlay_5_Button_tag:
            hotkey = button.tag - kPrtPlay_1_Button_tag + 1;
            break;
    }
    
    
    NSLog(@" Preset Button Pressed: %d",hotkey);

    playhotkeycmd = [[NSString alloc] initWithFormat:@"/playhotkey?key=%d",hotkey];
    itemCell = [PresetItems objectAtIndex:hotkey-1];
    
    //Playhotkey cmd

    [client getPath:playhotkeycmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             //NSLog(@"playhotkey response: %@", response);
             [self decode_menu:response Forcmd:6]; //6:playhotkey
             //Reset menu display ctrl @Jeanne. 2014.01.29
             playName.text = itemCell.name; //set play name
             [self menu_disp_ctrl:3];  //play menu ctrl
             [self getPlayInfo];
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];
    
}

-(UIImage *) getImageFromURL:(NSString *)fileURL
{
    //NSLog(@"图片下载:%@",fileURL);
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}//getImageFromURL:fileURL

//index
// 1: logo image
// 2: album image
-(void) setradioImage: (NSInteger) index
{
    UIImage * imageFromURL;
    UIImageView *radioImage = (id)[self.view viewWithTag:kRadio_image_tag];
    UIImageView *albumImage = (id)[self.view viewWithTag:kAlbum_image_tag];
    UIImage *logoImage = [UIImage imageNamed:@"radio"];
    UIImage *albumdfImage = [UIImage imageNamed:@"album"];
    
    if (index == 1) { //logo image
        if (([logo_url isEqualToString:@"nourl"] )|| (logo_url == nil))
        {
            NSLog(@"No logo url, use default image!");
            [radioImage setImage:logoImage];
        }
        else{
            imageFromURL =[self getImageFromURL:logo_url];
            if (imageFromURL == nil) {
                NSLog(@"download fail, use default image!");
                [radioImage setImage:logoImage];
            }
            [radioImage setImage: imageFromURL];
        }
    }
    else if (index == 2) { //album image
        if (([album_url isEqualToString:@"nourl"] )|| (album_url == nil))
        {
            NSLog(@"No album url, use default image!");
            [albumImage setImage:albumdfImage];
        }
        else{
            imageFromURL =[self getImageFromURL:album_url];
            if (imageFromURL == nil) {
                NSLog(@"download fail, use default image!");
                [albumImage setImage:albumdfImage];
            }
            [albumImage setImage: imageFromURL];
        }
    }
    
    
    
}//setradioImage

//cmd list Begin--------------
// 0: list
// 1: back
// 2: gochild
// 3: playstn
// 4: playinfo
// 5: hotkeylist
// 6: playhotkey
//cmd list End----------------

-(void) decode_menu:(NSString *)response Forcmd: (NSInteger)cmd
{
    UILabel *playLabel = (id)[self.view viewWithTag:kPlay_Label_tag];
    UILabel *playinfoLabel = (id)[self.view viewWithTag:kPlayinfo_Label_tag];
    UISlider *Volslider = (id)[self.view viewWithTag:kVol_Slider_tag];
    UIButton *MuteButton = (id)[self.view viewWithTag:kMute_Button_tag];
    char *p,*p1;
    char id[10];
    char status[30],vol[5],mute[3];
    char infostr[250];
    NSString *item_subid = [[NSString alloc] init];
    NSString *item_status= [[NSString alloc] init];
    NSString *item_name= [[NSString alloc] init];
    BIDItemCell *itemCell;
    
    
    
    const char *str = [response UTF8String];
    memset(id, 0, sizeof(id));
    
    if (cmd == 0) { // 0: list
        
        //Get menu item return
        p =strstr(str, "<item_return>");
        if(p)
        {
            for (int i = 13; (p[i]!=0)&&(p[i]!='<'); i++) {
                id[i-13] = p[i];
            }
        }
        
        NSString *itemcnt=[NSString stringWithCString:id encoding:NSUTF8StringEncoding];
        self.menuProperty.menuItemCnt = [NSNumber numberWithInteger:[itemcnt integerValue]];
        
        //Get Item cell
        p =strstr(str, "<item>");
        while (p) {
            //move after <item>
            str = p+6;
            
            //get item id
            memset(id, 0, sizeof(id));
            p1 = strstr(str, "<id>");
            if(p1)
            {
                for (int i = 4; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    id[i-4] = p1[i];
                }
            }
            
            //get item status
            memset(status, 0, sizeof(status));
            p1 = strstr(str, "<status>");
            if(p1)
            {
                for (int i = 8; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    status[i-8] = p1[i];
                }
            }
            
            //get item name
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<name>");
            if(p1)
            {
                for (int i = 6; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-6] = p1[i];
                }
            }
            
            
            item_subid = [NSString stringWithCString:id encoding:NSUTF8StringEncoding];
            item_name= [NSString stringWithCString:infostr encoding:NSUTF8StringEncoding];
            item_status= [NSString stringWithCString:status encoding:NSUTF8StringEncoding];
            
            //add itemcell to menu
            itemCell = makeItemCell(item_subid,item_name,item_status);
            [Items addObject:itemCell];
            
            //goto next item
            p =strstr(str, "<item>");
            
        }//while(p)
    }//if cmd == 0
    else if ((1==cmd)||(2 == cmd)||(6 == cmd)){ // 1: back,  2: go child,  6: playhotkey
        NSString *newID;
        //get item id
        memset(id, 0, sizeof(id));
        p = strstr(str, "<id>");
        if(p)
        {
            for (int i = 4; (p[i]!=0)&&(p[i]!='<'); i++) {
                id[i-4] = p[i];
            }
        }
        
        newID = [[NSString alloc] initWithString:[NSString stringWithCString:id encoding:NSUTF8StringEncoding]];
        self.menuProperty.menuId = [newID mutableCopy];
        NSLog(@"Back to menu(%@)\n",self.menuProperty.menuId);
    }//if cmd == 1,2,6
    else if(3==cmd){  // 3: playstn
        NSLog(@"decode playstn in future!!!\n");
    }//if cmd == 3
    else if(4==cmd){  // 4: playinfo
        NSString *playStatus;
        
        //for test
        //[self setradioImage];
        
        //get item status
        memset(status, 0, sizeof(status));
        p1 = strstr(str, "<status>");
        if(p1)
        {
            for (int i = 8; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                status[i-8] = p1[i];
            }
        }
        
        playStatus = [[NSString alloc] initWithString:[NSString stringWithCString:status encoding:NSUTF8StringEncoding]];
        if ([playStatus isEqualToString:@"Playing"])
        {//in playing
            NSString *logourl;
            NSString *albumurl;
            NSString *stinfo;
            NSString *streamformat;
            NSString *song;
            NSString *artist;
            NSString *playinfo;
            
            //get logo img url
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<logo_img>");
            if(p1)
            {
                for (int i = 10; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-10] = p1[i];
                }
                logourl = [[NSString alloc] initWithString:[NSString stringWithCString:infostr encoding:NSUTF8StringEncoding]];
                logo_url = [logourl mutableCopy];
            }
            else
            {
                logo_url =[@"nourl" mutableCopy];
            }
            [self setradioImage:1];
            
            //get album img url
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<album_img>");
            if(p1)
            {
                for (int i = 11; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-11] = p1[i];
                }
                albumurl = [[NSString alloc] initWithString:[NSString stringWithCString:infostr encoding:NSUTF8StringEncoding]];
                album_url = [albumurl mutableCopy];
            }
            else
            {
                album_url =[@"nourl" mutableCopy];
            }
            [self setradioImage:2];
            
            //get station info
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<station_info>");
            if(p1)
            {
                for (int i = 14; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-14] = p1[i];
                }
                stinfo = [[NSString alloc] initWithString:[NSString stringWithCString:infostr encoding:NSUTF8StringEncoding]];
                NSString *string = [[NSString alloc] initWithFormat:@"%@:\n%@", playStatus, stinfo ];
                
                //自动折行设置
                playLabel.lineBreakMode = NSLineBreakByWordWrapping;
                playLabel.numberOfLines = 0;
                playLabel.textAlignment = NSTextAlignmentLeft;
                playLabel.text = string;
                if (playLabel.text.length > 20) { //need > 2line
                    playLabel.font =[UIFont systemFontOfSize:14];
                }
            }
            else
            {
                playLabel.font =[UIFont systemFontOfSize:17];
                playLabel.textAlignment = NSTextAlignmentCenter;
                playLabel.text = playStatus;
            }
            
            //get stream format
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<stream_format>");
            if(p1)
            {
                for (int i = 15; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-15] = p1[i];
                }
                NSString *string = [[NSString alloc] initWithString:[NSString stringWithCString:infostr encoding:NSUTF8StringEncoding]];
                streamformat = [[NSString alloc] initWithFormat:@"Format:%@\n", string];
            }
            else
            {
                streamformat = @"";
            }
            
            //get song
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<song>");
            if(p1)
            {
                for (int i = 6; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-6] = p1[i];
                }
                NSString *string = [[NSString alloc] initWithString:[NSString stringWithCString:infostr encoding:NSUTF8StringEncoding]];
                song = [[NSString alloc] initWithFormat:@"Song:%@\n", string];
            }
            else
            {
                song = @"";
            }
            
            //get artist
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<artist>");
            if(p1)
            {
                for (int i = 8; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-8] = p1[i];
                }
                NSString *string = [[NSString alloc] initWithString:[NSString stringWithCString:infostr encoding:NSUTF8StringEncoding]];
                artist = [[NSString alloc] initWithFormat:@"Artist:%@", string];
            }
            else
            {
                artist = @" ";
            }
            
            playinfo = [[NSString alloc] initWithFormat:@"%@%@%@",streamformat,song,artist];
            
            playinfoLabel.lineBreakMode = NSLineBreakByWordWrapping; //自动折行设置
            playinfoLabel.numberOfLines = 0;
            playinfoLabel.textAlignment = NSTextAlignmentLeft;
            playinfoLabel.text = playinfo;
        }
        else
        {//not in playing
            playLabel.font =[UIFont systemFontOfSize:17];
            playLabel.textAlignment = NSTextAlignmentCenter;
            playLabel.text = playStatus;
        }
        
        //get vol //Jeanne.  2014.01.16
        memset(vol, 0, sizeof(vol));
        p1 = strstr(str, "<vol>");
        if(p1)
        {
            for (int i = 5; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                vol[i-5] = p1[i];
            }
        }
        
        //get muteflag  //2014.01.26
        memset(mute, 0, sizeof(mute));
        p1 = strstr(str, "<mute>");
        if(p1)
        {
            for (int i = 6; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                mute[i-6] = p1[i];
            }
        }
        
        if (volSettingFlag) {
            NSLog(@"In set vol cmd, do nothing!\n");
        }
        else{
            Volslider.value = atoi(vol);
            muteFlag = atoi(mute); //2014.01.26
            
            if (0 == muteFlag) {
                [MuteButton setImage:[UIImage imageNamed:@"vol.png"] forState:UIControlStateNormal];
                Volslider.enabled = TRUE;
            }
            else{
                [MuteButton setImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateNormal];
                Volslider.enabled = FALSE;
            }
        }
    }//if cmd == 4
    else if(cmd == 5){ // 5: hotkeylist
        
        //Get Item cell
        p =strstr(str, "<item>");
        while (p) {
            //move after <item>
            str = p+6;
            
            //get item id
            memset(id, 0, sizeof(id));
            p1 = strstr(str, "<id>");
            if(p1)
            {
                for (int i = 4; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    id[i-4] = p1[i];
                }
            }
            
            //get item status
            memset(status, 0, sizeof(status));
            p1 = strstr(str, "<status>");
            if(p1)
            {
                for (int i = 8; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    status[i-8] = p1[i];
                }
            }
            
            //get item name
            memset(infostr, 0, sizeof(infostr));
            p1 = strstr(str, "<name>");
            if(p1)
            {
                for (int i = 6; (p1[i]!=0)&&(p1[i]!='<'); i++) {
                    infostr[i-6] = p1[i];
                }
            }
            
            item_subid = [NSString stringWithCString:id encoding:NSUTF8StringEncoding];
            item_name= [NSString stringWithCString:infostr encoding:NSUTF8StringEncoding];
            item_status= [NSString stringWithCString:status encoding:NSUTF8StringEncoding];
            
            //add itemcell to menu
            itemCell = makeItemCell(item_subid,item_name,item_status);
            [PresetItems addObject:itemCell];
            
            //goto next item
            p =strstr(str, "<item>");
            
        }//while(p)
    }//if cmd == 5
    
}//decode_menu:response Forcmd:cmd

-(void) refresh_menu
{
    UIView *parentView = self.parentViewController.view;
    UITabBar *tabBar;// =(id)[parentView viewWithTag:kMain_Tabbar_tag];                     //main menu, other menu
    UITableView *tableView = (id)[self.view viewWithTag:kMenu_Tableview_tag];
    //UIButton *button = (id)[self.view viewWithTag:kBack_Button_tag];
    //get current menu list cmd
    NSString *path = [[NSString alloc] initWithFormat:@"/list?id=%@&start=1&count=250",self.menuProperty.menuId];
    
    //Add for wifisetting on tabbar.  @Jeanne. 2014.03.04
    if ([self.wifiSetFlag isEqualToString:@"YES"]) { //include wifi setting
        tabBar =(id)[parentView viewWithTag:kMain_2_Tabbar_tag];
    }else{//not include wifi setting
        tabBar =(id)[parentView viewWithTag:kMain_Tabbar_tag];
    }
    
    //tabBar.hidden = FALSE; //for set in menu_disp_ctrl @Jeanne. 2014.01.29
    
    //tabbar的item的enable，disable
    //------------------------------
    UITabBarItem *item = [tabBar.items objectAtIndex:0];
    if ([self.menuProperty.menuId isEqualToString:@"1"])
    {
        item.enabled = FALSE;
    }
    else
    {
        item.enabled = TRUE;
    }
    
    //------------------------------
    
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
         
         //Paul Request: in main menu, items should be on fix pos. Jeanne. 2014.03.03
         //*****************************************************
         if ([self.menuProperty.menuId isEqualToString:@"1"])
         {
             if ([FixMainMenuItems count] == 0) {
                 [self MakeMainMenuItem];
             }
             else{
                 NSLog(@"main menu has already init!");
             }
            
         }
         //*****************************************************
         
         [tableView reloadData];
         tabBar.selectedItem = nil;
         
         //Reset menu display ctrl @Jeanne. 2014.01.29
         if([self.menuProperty.menuId isEqualToString:@"1"])
         {
             NSLog(@"to main menu!!!\n");
             [self menu_disp_ctrl:1];  //main menu ctrl
         }
         else
         {
             NSLog(@"to menu (%@)!!!\n",self.menuProperty.menuId);
             [self menu_disp_ctrl:2];  //other menu ctrl
             
         }
         
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         tabBar.selectedItem = nil;
         
         //Reset menu display ctrl @Jeanne. 2014.01.29
         if([self.menuProperty.menuId isEqualToString:@"1"])
         {
             NSLog(@"to main menu!!!\n");
             [self menu_disp_ctrl:1];  //main menu ctrl
         }
         else
         {
             NSLog(@"to menu (%@)!!!\n",self.menuProperty.menuId);
             [self menu_disp_ctrl:2];  //other menu ctrl
             
         }
     }];
    
} //refresh_menu


-(void) getPlayInfo
{
    UILabel *playLabel = (id)[self.view viewWithTag:kPlay_Label_tag];
    if (AddPresetFlag == TRUE)
    {
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getPlayInfo) userInfo:nil repeats:NO];
    }
    else if (playLabel.hidden == FALSE) {
        //NSLog(@"Music Play,Get play Info");
        
        if (volSettingFlag) {
            NSLog(@"In setting vol cmd, donot get playinfo this time!");
        }
        else
        {
            //Get Play Info Begin ==================================
            client.isNeedHUD = [@"NO" mutableCopy];
            //send back cmd
            [client getPath:@"/playinfo"
                    parameters:nil
                    loadingText:nil
                    successText:nil
                    success:^(AFHTTPRequestOperation *operation, NSString *response)
                    {
                       //NSLog(@"playinfo response: %@", response);
                       [self decode_menu:response Forcmd:4]; //4:playinfo cmd decode
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                       NSLog(@"Error: %@", error);
                    }
             ];
             client.isNeedHUD = [@"YES" mutableCopy];
             //Get Play Info End ==================================
        }

        //Restart get playinfo timer
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getPlayInfo) userInfo:nil repeats:NO];
    }
    else{
        NSLog(@"Exit play menu!");
    }

}//getPlayInfo



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) refresh_presetbtn
{
    UIImage *bgImage = [UIImage imageNamed:@"btn_preset_h.png"];
    UIImage *disbgImage = [UIImage imageNamed:@"btn_preset_h_dis.png"];
    UIImage *playbgImage = [UIImage imageNamed:@"btn_preset_s.png"];
    UIImage *playdisbgImage = [UIImage imageNamed:@"btn_preset_s_dis.png"];
    
    NSLog(@"refresh preset btn!");
    client.isNeedHUD = [@"NO" mutableCopy];
    [client getPath:@"/hotkeylist"
         parameters:nil
        loadingText:nil
        successText:nil
            success:^(AFHTTPRequestOperation *operation, NSString *response)
     {
         NSInteger tag,itemcnt,playtag;
         UIButton *PresetButton,*PrtPlayButton;
         int i;
         BIDItemCell *itemCell;
         //NSLog(@"response: %@", response);
         //remove table objects first
         [PresetItems removeAllObjects];
         [self decode_menu:response Forcmd:5]; // 5: hotkeylist
         itemcnt =[PresetItems count];
         
         for (i = 0; i < 5; i++) {
             tag = kPreset_1_Button_tag + i;
             playtag = kPrtPlay_1_Button_tag + i;
             PresetButton = (id)[self.view viewWithTag:tag];
             PrtPlayButton = (id)[self.view viewWithTag:playtag];
             if (i>= itemcnt) {
                 PresetButton.backgroundColor = [UIColor colorWithPatternImage:disbgImage];
                 PresetButton.enabled = FALSE;
                 PrtPlayButton.backgroundColor = [UIColor colorWithPatternImage:playdisbgImage];
                 PrtPlayButton.enabled = FALSE;
             }
             else{
                 itemCell = [PresetItems objectAtIndex:i];
                 if ([itemCell.status isEqualToString:@"emptyfile"])
                 {
                    PresetButton.backgroundColor = [UIColor colorWithPatternImage:disbgImage];
                    PresetButton.enabled = FALSE;
                    PrtPlayButton.backgroundColor = [UIColor colorWithPatternImage:playdisbgImage];
                    PrtPlayButton.enabled = FALSE;
                 }
                 else{
                    PresetButton.backgroundColor = [UIColor colorWithPatternImage:bgImage];
                    PresetButton.enabled = TRUE;
                    PrtPlayButton.backgroundColor = [UIColor colorWithPatternImage:playbgImage];
                    PrtPlayButton.enabled = TRUE;
                 }
             }
             
         }
         
         
     }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
     }];
     client.isNeedHUD = [@"YES" mutableCopy];
    
}



- (void)viewDidLoad
{
    //UITableView *tableView = (id)[self.view viewWithTag:kMenu_Tableview_tag];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (Items == nil) {
        Items = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (PresetItems == nil) {
        PresetItems = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (self.menuProperty == nil) {
        self.menuProperty = [[BIDMenuProperty alloc] init];
    }
    if(self.menuProperty.menuId == nil){
        self.menuProperty.menuId = [[NSMutableString alloc] initWithString:@"1"];
    }
    if(self.menuProperty.menuItemCnt ==nil){
        self.menuProperty.menuItemCnt =[[NSNumber alloc] init];
    }
    //Paul Request: in main menu, items should be on fix pos. Jeanne. 2014.03.03
    if (FixMainMenuItems == nil) {
        FixMainMenuItems = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    client = [ILHTTPClient clientWithBaseURL:self.toMagicUrl
                            showingHUDInView:self.view];

    //client.isNeedHUD = [@"NO" mutableCopy];//2014.02.26
    
    
    //Reset menu display ctrl @Jeanne. 2014.01.29
    [self menu_disp_ctrl:1];  //main menu ctrl
    

    volSettingFlag = FALSE;  //2014.01.26.  Init vol set flag
    muteFlag = FALSE;        //2014.01.26.
    [self init_playinfo];    //2014.02.07. init play info
    SearchInputFlag = FALSE; //2014.02.11  add for New search menu
    playitemid = [@"noplayid" mutableCopy]; //2014.02.18
    AddPresetFlag = FALSE;  //2014.02.18
    
    //Refresh main menu
    [self refresh_menu];
    
    //Refresh preset btn
    //[self refresh_presetbtn];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(refresh_presetbtn) userInfo:nil repeats:NO];
    
     
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -Table View Data Source Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Paul Request: in main menu, items should be on fix pos. Jeanne. 2014.03.03
    if([self.menuProperty.menuId isEqualToString:@"1"])
    {//main menu
        return [FixMainMenuItems count];
    }
    else
    {//other menu
        return [Items count];
    }
    
}//tableView:tableView numberOfRowsInSection:section

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.menuProperty.menuId isEqualToString:@"1"])
    {//main menu
        return 60;
    }
    else
    {//other menu
        return 48;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BIDItemCell *itemCell;// = [Items objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImage *bgImage;// = [UIImage imageNamed:@"bar_bg"];
    //Paul request to black bg.  @Jeanne. 2014.03.03
    //UIImage *bglistImage = [UIImage imageNamed:@"bk_list"];
    NSString *internetRadioId = [[NSString alloc] initWithFormat:@"%d",uiINTERNET_RADIO_MENU];
    
    //Paul Request: in main menu, items should be on fix pos. Jeanne. 2014.03.03
    if([self.menuProperty.menuId isEqualToString:@"1"])
    {//main menu
        itemCell = [FixMainMenuItems objectAtIndex:indexPath.row];
    }
    else
    {//other menu
        itemCell = [Items objectAtIndex:indexPath.row];
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([itemCell.status isEqualToString:@"content"])
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //info button (i)
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if([self.menuProperty.menuId isEqualToString:@"1"])
    {//In main menu, add icon
        int sub_id = [itemCell.submenuId intValue];
        UIImage *image;
        switch (sub_id) {
            case uiLOCATIONRADIO_MENU:
                //NSLog(@"Location menu item\n");
                image = [UIImage imageNamed:@"LocalRadio_icon.png"];
                cell.imageView.image = image;
                break;
            case uiINTERNET_RADIO_MENU:
                //NSLog(@"radio menu item\n");
                image = [UIImage imageNamed:@"Radio_icon.png"];
                cell.imageView.image = image;
                break;
            case uiUPNP_MENU:
                //NSLog(@"mediaCenter menu item\n");
                image = [UIImage imageNamed:@"MediaCenter_icon.png"];
                cell.imageView.image = image;
                break;
        }
        bgImage = [UIImage imageNamed:@"mainbar_bg"];
    }
    else if([self.menuProperty.menuId isEqualToString:internetRadioId])
    {//in ineternet radio
        int sub_id = [itemCell.submenuId intValue];
        UIImage *image;
        switch (sub_id) {
            case uiFAVEX_MENU:
                image = [UIImage imageNamed:@"MyFavorite.png"];
                cell.imageView.image = image;
                break;
            case uiRADIO_MUSICEX_MENU:
                image = [UIImage imageNamed:@"RadioMusic.png"];
                cell.imageView.image = image;
                break;
            case uiLOCATIONRADIO_MENU:
                image = [UIImage imageNamed:@"LocalRadio.png"];
                cell.imageView.image = image;
                break;
            case uiLAST_IRADIO_MENU:
                image = [UIImage imageNamed:@"History.png"];
                cell.imageView.image = image;
                break;
            case uiNEWSEARCHRADIOEX_MENU:
                image = [UIImage imageNamed:@"Service.png"];
                cell.imageView.image = image;
                break;
        }
        bgImage = [UIImage imageNamed:@"bar_bg"];
    }
    else{
        cell.imageView.image = nil;
        bgImage = [UIImage imageNamed:@"bar_bg"];
    }

    cell.textLabel.text = itemCell.name;
    cell.backgroundColor = [UIColor colorWithPatternImage:bgImage];
    cell.textLabel.textColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    cell.textLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    //cell.textLabel.frame = CGRectMake(50, 5, 200, 20);
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    //Paul request to black bg.  @Jeanne. 2014.03.03
    //tableView.backgroundColor = [UIColor colorWithPatternImage:bglistImage];
    return cell;
}//tableView:tableView cellForRowAtIndexPath:indexPath

#pragma mark -Table View Delegate Methods

//tableView didSelectRowAtIndexPath:会在一行被选中时调用，告诉用户要单击细节展开按钮而不是选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *playName = (id)[self.view viewWithTag:kPlayname_Label_tag];                //play menu
    BIDItemCell *itemCell = [Items objectAtIndex:indexPath.row];
    NSString *gochildcmd = [[NSString alloc] initWithFormat:@"/gochild?id=%@",itemCell.submenuId];
    NSString *playstncmd = [[NSString alloc] initWithFormat:@"/play_stn?id=%@",itemCell.submenuId];
    NSString *NewSearchMenuId = [[NSString alloc] initWithFormat:@"%d",uiNEWSEARCHRADIOEX_MENU];
    NSString *internetRadioId = [[NSString alloc] initWithFormat:@"%d",uiINTERNET_RADIO_MENU];

    //取消选中项
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if ([itemCell.status isEqualToString:@"file"]) {//it's a file,goto play info
        
        //get play stn itemid
        //将_分隔的字符串转换成数组
        NSArray *array1 = [itemCell.submenuId componentsSeparatedByString:@"_"];
        playitemid = [array1 objectAtIndex:1];
        NSLog(@"playitemid = %@",playitemid);
        
        [client getPath:playstncmd
             parameters:nil
            loadingText:nil
            successText:nil
                success:^(AFHTTPRequestOperation *operation, NSString *response)
         {
             //NSLog(@"playstn response: %@", response);
             [self decode_menu:response Forcmd:3]; //3:playstn decode
             //Reset menu display ctrl @Jeanne. 2014.01.29
             playName.text = itemCell.name; //set play name
             [self menu_disp_ctrl:3];  //play menu ctrl
             [self getPlayInfo];
             
         }
                failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
         }];

        
    }
    else if ([itemCell.status isEqualToString:@"content"])
    {//it's content
        
        //2014.02.11. Add for New Search menu
        if(([self.menuProperty.menuId isEqualToString:internetRadioId])
           &&([itemCell.submenuId isEqualToString:NewSearchMenuId])
           )
        {//will be go to New Search Menu, goto input first
            SearchInputFlag = TRUE;
            self.SearchField.text = @"";
            [self menu_disp_ctrl:2]; //other menu ctrl
        }
        else
        {
    
            [client getPath:gochildcmd
                    parameters:nil
                    loadingText:nil
                    successText:nil
                    success:^(AFHTTPRequestOperation *operation, NSString *response)
                    {
                        //NSLog(@"response: %@", response);
                        [self decode_menu:response Forcmd:2]; //2:gochild decode
                        [self refresh_menu];
         
                    }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error)
                    {
                        NSLog(@"Error: %@", error);
                    }
            ];
        }
    }
    else if ([itemCell.status isEqualToString:@"emptyfile"])
    {//it's empty file
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Empty File"
                                    message:@"It's empty file!"
                                   delegate:nil
                          cancelButtonTitle:@"OK,I knew."
                          otherButtonTitles:nil];
        [alert show];

    }
    
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
    return 6;
}

#pragma mark Picker Delegate Methods
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    BIDItemCell *itemCell;
    NSString *itemStr;
    
    //modified from 'pos' to 'Preset'    @Jeanne.  2014.03.03
    if(row < 5)
    {
        if(row < [PresetItems count])
        {
            itemCell = [PresetItems objectAtIndex:row];
            
            if([itemCell.status isEqualToString:@"emptyfile"])
            {
               itemStr = [[NSString alloc] initWithFormat:@"Add to Preset %d",row+1];
            }
            else
            {
               itemStr = [[NSString alloc] initWithFormat:@"Replace Preset %d: %@",row+1,itemCell.name];
            }
            
        }
        else{
            itemStr = [[NSString alloc] initWithFormat:@"Add to Preset %d",row+1];
        }
    }
    else
    {
        itemStr = @"Add to last";
    }
    
    label.text = [[NSString alloc] initWithFormat:@"   %@",itemStr];
    label.textColor = [UIColor blueColor];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
    //return itemStr;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"click button: %d (1: Yes, 0: NO)",buttonIndex);
    
    if (1 == buttonIndex) {
        NSLog(@"do add preset process.");
        [self AddPresetprocess]; //do add preset process.  @Jeanne. 2014.03.04
    }
    else{
        NSLog(@"Cancel it!");
        [self CancelPressed];
    }
}

@end
