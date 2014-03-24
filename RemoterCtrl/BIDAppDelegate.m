//
//  BIDAppDelegate.m
//  RemoterCtrl
//
//  Created by 张巧玲 on 1/6/14.
//  Copyright (c) 2014 Jeanne. All rights reserved.
//

#import "BIDAppDelegate.h"
#import "BIDViewController.h"
#import <UIKit/UIKit.h>


@implementation BIDAppDelegate

//Add for support multi ios device.  @Jeanne. 2014.03.21
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIDeviceResolution CurResoloution;
    
    if (self.CurDevice == nil) {
        self.CurDevice = [[BIDUIDevice alloc] init];
    }
    
    //get current device
    CurResoloution =[self.CurDevice currentResolution];
    NSLog(@"Current Resolution: %lu",(unsigned long)CurResoloution);
    
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //test
    //CurResoloution = UIDevice_iPhoneHiRes;
    
    //应用启动之后的一些自定义设置
   if (self.ViewController ==nil) {
       if ((UIDevice_iPhoneStandardRes == CurResoloution)
           ||(UIDevice_iPhoneHiRes == CurResoloution))
       {
           NSLog(@"3.5 inch");
            self.ViewController = [[BIDViewController alloc] initWithNibName:@"Main_iphone4" bundle:nil];
           self.ViewController.CuriosDevice = [@"iphone4" mutableCopy];
       }
       else if (UIDevice_iPhoneTallerHiRes == CurResoloution)
       {
           NSLog(@"4 inch");
           self.ViewController = [[BIDViewController alloc] initWithNibName:@"Main_iphone5" bundle:nil];
           self.ViewController.CuriosDevice = [@"iphone5" mutableCopy];
       }
       else if ((UIDevice_iPadHiRes == CurResoloution)
                ||(UIDevice_iPadStandardRes == CurResoloution))
       {
           NSLog(@"ipad");
           self.ViewController = [[BIDViewController alloc] initWithNibName:@"Main_ipad" bundle:nil];
           self.ViewController.CuriosDevice = [@"ipad" mutableCopy];
       }
       else{
           NSLog(@"else else else Jeanne");
           self.ViewController = [[BIDViewController alloc] initWithNibName:@"Main_iphone5" bundle:nil];
           self.ViewController.CuriosDevice = [@"iphone5" mutableCopy];
       }

    }


    //[[NSBundle mainBundle] loadNibNamed:@"Main_iphone4" owner:self options:nil];
    self.window.rootViewController = self.ViewController;
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
    
    //return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
