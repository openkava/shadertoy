//
//  AppDelegate.h
//  shadertoy
//
//  Created by open kava on 12-12-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@class ViewController;
@class HomeViewController;


#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) UINavigationController *navigationController ;

@property (strong, nonatomic) ViewController *viewController;
@property (strong ,nonatomic)HomeViewController *homeViewController;
@property (strong ,nonatomic) User *user;
@end
