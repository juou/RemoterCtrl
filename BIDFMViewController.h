//
//  BIDFMViewController.h
//  RemoterCtrl
//
//  Created by 张巧玲 on 6/10/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDSubViewController.h"
#import "BIDFMItemCell.h"

@interface BIDFMViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource>

@property (copy, nonatomic) NSMutableString *toMagicUrl;
@property (strong, nonatomic) NSMutableDictionary *strs;


@property (weak, nonatomic) IBOutlet UITableView *FMFavTable;
@property (strong,nonatomic) IBOutlet UIPickerView *singlePicker;
@property (strong,nonatomic) IBOutlet UIImageView *MarkImageView;

-(IBAction)volChange:(UISlider *)sender;
-(IBAction)backButtonPressed;
-(IBAction)FMListButtonPressed;
-(IBAction)ManaulsearchButtonPressed:(UIButton *)button;
-(IBAction)BacktuneButtonPressed;
-(IBAction)FortuneButtonPressed;
-(IBAction)AutosearchButtonPressed;
-(IBAction)StoreButtonPressed;
-(IBAction)FAVButtonPressed:(UIButton *)button;
-(IBAction)MuteButtonPressed;
-(IBAction)AudiomodeButtonPressed;
-(IBAction)CancelPressed;
-(IBAction)DonePressed;

-(void) decode_menu:(NSString *)response Forcmd: (NSInteger)cmd;
-(void) FMStatusGet;
-(void) FMRefreshTimer;
+(BIDFMItemCell *)makeItemCell:(NSString *)FavNo SetName:(NSString *)name SetFreq: (NSString *)freq;

@end
