//
//  BIDAUXViewController.h
//  RemoterCtrl
//
//  Created by 张巧玲 on 8/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDAUXViewController : UIViewController

@property (copy, nonatomic) NSMutableString *toMagicUrl;
@property (strong, nonatomic) NSMutableDictionary *strs;


-(IBAction)backButtonPressed;
-(IBAction)volChange:(UISlider *)sender;
-(IBAction)MuteButtonPressed;

@end
