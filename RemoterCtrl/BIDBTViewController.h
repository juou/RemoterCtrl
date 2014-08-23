//
//  BIDBTViewController.h
//  RemoterCtrl
//
//  Created by 张巧玲 on 8/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDBTViewController : UIViewController

@property (copy, nonatomic) NSMutableString *toMagicUrl;
@property (strong, nonatomic) NSMutableDictionary *strs;
@property (strong,nonatomic) IBOutlet UIImageView *BTStatusImageView;
@property (strong,nonatomic) IBOutlet UIButton *BackwordButton;
@property (strong,nonatomic) IBOutlet UIButton *ForwordButton;
@property (strong,nonatomic) IBOutlet UIButton *StopButton;
@property (strong,nonatomic) IBOutlet UIButton *PlaypauseButton;

-(IBAction)backButtonPressed;
-(IBAction)StartBTMatchPressed;
-(IBAction)CMDButtonPressed:(UIButton *)button;
-(IBAction)volChange:(UISlider *)sender;
-(IBAction)MuteButtonPressed;

@end
