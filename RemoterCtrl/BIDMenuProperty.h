//
//  BIDMenuProperty.h
//  RemoterCtrl
//
//  Created by 张巧玲 on 1/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import <Foundation/Foundation.h>

// ---------------------------------------------------------------------------
// UI State
// ---------------------------------------------------------------------------
typedef enum
{
    uiIDLE,
    uiMAIN_MENU,                               //Level 0                           ----------1
    uiMEDIA_CENTER_MENU,              //Level 1
    uiINFO_CENTER_MENU,                //Level 1
    uiSERVICE_MENU,                         //Level 1
    uiFM_MENU,                                  //Level 1
    uiCONFIG_MENU,                          //Level 1
    uiSTORAGE_MENU,                        //Level 2
    uiUPNP_MENU,                               //Level 2
    uiLOCALSOURCE_MENU,                 //Level 2
    uiVOLUME_MENU,                         //Quick Menu                     -------------10
    uiSTANDBY_MENU,                       //Quick Menu
    uiINFOFILEOP_MENU,                   //Level 2
    uiSTORAGEFILEOP_MENU,             //Level 3
    uiADDRADIO_MENU,                     //Level 2
    uiFAVRENAME_MENU,                    //Level 3
    uiNETWORK_MENU,                      //Level 2
    uiCLOCK_MENU,                            //Level 2
    uiALARM_MENU,                            //Level 2
    uiALARM_PARAM_MENU,                //Level 3
    uiALARM_SETTIME_MENU,             //Level 4                    --------------20
    uiALARM_SETSOUND_MENU,         //Level 4
    uiLANGUAGE_MENU,                     //Level 2
    uiBACKLIGHT_MENU,                    //Level 2
    uiPOWERMANAGEMENT_MENU,                  //Level 2		// Tom 2012.04.25 add for power management
    uiSLEEPTIMER_MENU,                  //Level 2
    uiBUFFER_MENU,                         //Level 2
    uiWEATHER_MENU,                     //Level 2
    uiVERSIONUPDATE_MENU,           //Level 2
    uiVERSIONUPDATECONFIRM_MENU,           //Level 2
    uiSET_DATE_TIME_MENU,           //Level 3                      ----------------30
    uiSET_TIME_FORMAT_MENU,      //Level 3
    uiETHERNET_OR_WIFI_ONOFF_MENU,   //Level 3
    uiIPCONFIG_MENU,                               //Level 3
    uiWIFICONFIG_MENU,                          //Level 3
    uiSTBDISP_MENU,                                //Level 3
    uiTEMP_UNIT_MENU,                           //Level 3
    uiWIFICONFIG_SUB_MENU,                 //Level 4
    uiENTERWEPWPA_MENU,                                //Level 5
    uiMANUALSETTING_MENU,                   //Level 4
    uiIPADDRESS_MENU,                                       //Level 5             ---------------------40
    uiSUBMASK_MENU,                                          //Level 5
    uiDEFAULTGATEWAY_MENU,                          //Level 5
    uiPREFERDNS_MENU,                                      //Level 5
    uiALTERDNS_MENU,                                        //Level 5
    uiRECORD_MENU,
    uiABORT_THE_SETTING_MENU,           //Level 10
    uiLINEIN_MENU,                                  //Level 1
    uiIPOD_MENU,                                    //Level 1
    uiSELFTEST_MENU,                           //Level 1
    uiMYMEDIAU_LOGIN_MENU,            //Level 1      Jeanne.  2008-11-25.  Add for My mediaU Login           ---------50
    uiMYMEDIAU_MENU,                        //Level2      Jeanne.  2008-11-25.  Add for My mediaU
    uiINTERNET_RADIO_MENU,             //Leve1      Jeanne.  2008-12-15.  Add for New Main Menu
    uiRECORD_STORAGE_MENU,		    // Level 2		wangxiaobin 2008/12/23	add for Record and Storage
    uiFM_AUDIO_SETUP_MENU,		    // Level 2  	wangxiaobin 2009-1-15   	add for Method ID 40, Set FM Audio
    uiMYMEDIAUIDLIST_MENU,            //Level 2     Jeanne.  2009_03-04.  Add for My mediaU ID List
    uiMOBILE_NETWORK_SELECT_MENU,    //Level 3   Jeanne.  Add for 3G support  2009-05-07
    uiAUDIO_SETUP_MENU,					// Level 3		Add for Audio Setup, wangxiaobin 2009/5/19
    uiAUDIO_SETUP_BASSANDTREBLE_MENU,	// Level 4		add for Audio Setup, wangxiaobin 2009/5/19
    uiLAST_IRADIO_MENU,					// Level 2  	add for Last iRadio, wangxiaobin 2009/7/8
    uiLAST_IRADIO_OP_MENU,				// Level 3		add for Last IRadio, wangxiaobin 2009/7/8                    --------------60
    uiSET_DATE_FORMAT_MENU,				// Level 3		add for Set Date Format, wangxiaobin 2009/8/5
    uiFM_SETUP_MENU,                              // Level 2   Add for FM Area Function Jeanne .2009-08-04
    uiFM_AREA_SETUP_MENU,                   // Level 3   Add for FM Area Function Jeanne .2009-08-04
    uiDST_MENU,                                        //Level 3    Add for DST Menu  Jeanne.  2009-08-05
    uiALARM_TURNONOFF_MENU,				// Level 3 	// add for MultiThreading Alarm, wangxiaobin 2009/7/22
    uiALARM_NAP_MENU,						// Level 3 	// add for MultiThreading Alarm, wangxiaobin 2009/7/22
    uiALARM_VOLUME_MENU,					// Level 3		// add for Alarm Volume, wangxiaobin 2009/9/4
    uiDIMMER_TRUNON_MENU,				// Level 3 	// add for Dimmer Value, wangxiaobin 2009/9/7
    uiMYFAV_STATIONLIST_SORT_MENU,                //level3		 add for myfav sort, kevin. 2009-10-19
    uiREMIND_MENU,               //LEVEL 5   add for New WIFI  flow.   Jeanne.  2010.02.02                                   -----------70
    uiRADIO_MUSICEX_MENU,                                     //Level 1          Add for radio/music extend, kevin. 2010-1-19
    uiFILEOPEX_MENU,                                                   //Level 1          Add for radio/music extend, kevin. 2010-1-19
    uiSEARCHRADIOEX_MENU,                                     //Level 1          Add for radio/music extend, kevin. 2010-2-22
    uiSEARCHFILEOPEX_MENU,                                   //Level 1          Add for radio/music extend, kevin. 2010-2-22
    uiFAVEX_MENU,                                                     //Level 1          Add for radio/music extend, kevin. 2010-2-22
    uiFAVEXFILEOP_MENU,                                         //Level 1          Add for radio/music extend, kevin. 2010-2-22
    uiFAVEX_TEMPSTATION_MENU,                            //Level 1          Add for radio/music extend, kevin. 2010-2-22
    uiFAVEX_TEMPSTATION_FILEOP_MENU,              //Level 1          Add for radio/music extend, kevin. 2010-2-22
    uiINSTALL_SELECTNETWORK,     //LEVEL 5  //Improve Installation after Reset.   Jeanne.  2010.03.12
    uiALARM_REPEAT_MENU,						// Level 5		add for Mofity Alarm, wangxiaobin 2010-4-6             -------------80
    uiENTER_SSID,     // Add for Hidden Essid Edit.  Jeanne. 2010.04.07
    uiENCRYPTION_TYPE,  // Add for Hidden Essid Edit.  Jeanne. 2010.04.07
    uiENHANCE_ENCRYPTION_TYPE,  // Add for Hidden Essid Edit.  Jeanne. 2010.04.07
    uiENTER_PW_MENU,    // Add for Hidden Essid Edit.  Jeanne. 2010.04.07
    uiNETWORK_MANUALCONFIG_MENU, //Frank Suggest: Network menu struct improvement.   Jeanne.  2010.04.08
    uiWIFI_MANUALCONFIG_MENU, //Frank Suggest: Network menu struct improvement.   Jeanne.  2010.04.08
    uiLOCATIONRADIO_MENU,                                     //Level 1          Add for Location Radio extend, Jeanne. 2010.06.17
    uiLOCATIONRADIOFILEOPEX_MENU,                     //Level 1           Add for Location Radio extend, Jeanne. 2010.06.17
    uiLOCATIONCOUNTRY_MENU,                                     //Level 1          Add for Location Radio extend, Jeanne. 2010.06.21
    uiLOCATIONCOUNTRYOPEX_MENU,                             //Level 1          Add for Location Radio extend, Jeanne. 2010.06.21             --------------90
    uiDABEX_MENU,                                                         //Level 1           //Add for DAB Menu.   Jeanne.  2010.08.24         // Tom 2010.10.13 add
    uiDAB_FAVLIST_MENU,                                          //Add alarm Sound: DAB.  Jeanne.  2011.09.21
    uiLOCALRADIOSETUP_MENU,                                     //Level 1           //kevin, 2010/9/13. modify for local contury auto detect
    uiMYMEDIAU_SETUP_MENU,                                        //kevin, 2010/9/27. modify for adding my mediau enable and disable function
    uiWIFI_PROFILE_MENU,                                              //Add for Wifi Profile.  Jeanne. 2010.09.07
    uiDLNA_MENU,                                                            //Add for DLNA  Jeanne. 2010.10.27
    uiMEDIACENTER_SETUP_MENU,                                  //kevin, 2010/11/04. modify for adding mediacenter setup function
    uiDLNA_SETUP_MENU,                                                //Add for DLNA Device Setup Menu.  Jeanne. 2010.11.23
    uiDLNA_RENAME_MENU,                                             //Add for DLNA Device Rename Menu.  Jeanne. 2010.11.23
    uiNEWSEARCHRADIOEX_MENU,                                     //Level 1          ddt                                                                                -----------------100
    uiNEWSEARCHFILEOPEX_MENU,                                   //Level 1          ddt
    uiEQ_MENU,                                     //Level 3       //Add for Hipshing Kicker Project. [EQ]   Jeanne. 2011.03.16
    uiMEDIAUFILEOP_MENU,                     //Level 1          //kevin, 2011/3/18. modify for adding mediau's stations to myfav
    uiBLUETOOTH_MENU,                                             //Level 1          //Add for BlueTooth Speaker.  Jeanne.  2011.03.24
    uiPLAYLASTRADIOSETTING_MENU,                        //Level 3         //Add for Play Last Radio when Power On.  Jeanne.  2011.04.13
    uiFM_FAVLIST_MENU,                            //Level 7         //Add alarm Sound: Internet Radio and FM Radio.  Jeanne.  2011.04.26
    uiMYPLAYLIST_MENU,                                  //kevin, 2011/7/29. modify for adding My playlist function
    
    uiAUPEO_MENU,											// jy@2011/11/08 Aupeo support
    uiAUPEO_USER_STATION_MENU,								// jy@2011/11/08 Aupeo support
    uiAUPEO_MOOD_STATION_MENU,								// jy@2011/11/08 Aupeo support                  -----------------  110
    uiAUPEO_BROD_STATION_MENU,								// jy@2011/11/08 Aupeo support
    uiAUPEO_PERSONAL_STATION_MENU,                                               //Add for Aupeo "Personal station".   Jeanne. 2011.12.11
    uiAUPEO_PERSONAL_ACCOUNT_MANAGE_MENU,                               //Add for Aupeo "Personal station".   Jeanne. 2011.12.11
    uiAUPEO_PERSONAL_ACCOUNT_MENU,                                              //Add for Aupeo "Personal station".   Jeanne. 2011.12.11
    uiAUPEO_FARTISTS_STATION_MENU,                                               //Add for Aupeo "featured artists".   Jeanne. 2011.12.15
    uiNATEKS_STN_1_MENU,									      //Add for Nateks Project.   Jeanne. 2011.12.26
    uiNATEKS_STN_2_MENU,									      //Add for Nateks Project.   Jeanne. 2011.12.26
    uiNATEKS_STN_1_FILEOPEXMENU,							      //Add for Nateks Project.   Jeanne. 2011.12.26
    uiNATEKS_STN_2_FILEOPEXMENU,							      //Add for Nateks Project.   Jeanne. 2011.12.26
    uiDLNAINFO_MENU,                   //Add for DLNA Info.  Jeanne. 2012.02.09                                                              ----------------- 120
    uiDLNA_STBSUPPORT_MENU,                           //Add for support DLNA on standby.  Jeanne. 2012.07.27
    uiUSB_MENU,                             //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiSD_MENU,                               //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiDELPLAYLIST_MENU,             //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiRESET_MENU,                        //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiETH_CONFIG_MENU,             //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiWIFI_CONFIG_MENU,            //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiMOBILE_CONFIG_MENU,      //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiCHECK_POWERON_MENU,  //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiWIFI_WPS_MENU,               //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiGMT_MENU,                         //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiALARM_ONE_MENU,            //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiALARM_TWO_MENU,          //Add for Http Dsock.(for identified only)  @Jeanne. 2013.09.26
    uiHOTKEY_MENU,                   //Add for Http Dsock.(for identified only)  @Jeanne. 2013.12.31
    //--------
    uiINVALID                          // Used for enumerated type range  // checking (DO NOT REMOVE)
    
} eUI_STATE;

@interface BIDMenuProperty : NSObject
@property (copy, nonatomic) NSMutableString *menuId;
@property (copy, nonatomic) NSMutableString *name;
@property (copy, nonatomic) NSMutableString *status;
@property (copy, nonatomic) NSNumber *menuItemCnt;
@property (copy, nonatomic) NSMutableArray *menuItems;
@end
