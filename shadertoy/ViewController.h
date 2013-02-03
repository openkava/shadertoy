//
//  ViewController.h
//  shadertoy
//
//  Created by open kava on 12-12-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController

@property(strong ,nonatomic) NSString  *shaderVName;
@property(strong ,nonatomic) NSString  *shaderFName;
@property(strong ,nonatomic) NSDate    *startTime;



@end
