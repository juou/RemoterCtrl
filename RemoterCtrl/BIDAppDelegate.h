//
//  BIDAppDelegate.h
//  RemoterCtrl
//
//  Created by 张巧玲 on 1/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDUIDevice.h"
#import "BIDViewController.h"
@class BIDViewController;

@interface BIDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BIDViewController *ViewController;
@property (strong, nonatomic) BIDUIDevice *CurDevice;

//Test for Active/Background.  @Jeanne. 2014.08.10
@property (strong, nonatomic) NSString *EnterBackground;

@end
