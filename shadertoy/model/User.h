//
//  User.h
//  GalaxyForIOS
//
//  Created by ydf on 12-12-24.
//  Copyright (c) 2012年 itoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (strong ,nonatomic) NSString  *loginName;
@property (strong ,nonatomic) NSString  *requestKey;
@property (strong ,nonatomic) NSString  *userID;
@property (strong ,nonatomic) NSString  *userIntID;
@property (strong ,nonatomic) NSString  *userCode;
@property (strong ,nonatomic) NSString  *userName;

@property (strong ,nonatomic) NSString  *companyIntID;
@property (strong ,nonatomic) NSString  *companyName;
@property (strong ,nonatomic) NSString  *deptIntID;
@property (strong ,nonatomic) NSString  *deptName;
@property (strong ,nonatomic) NSString  *OAUserName;
@property (strong ,nonatomic) NSString  *OAPassword;


- (id)init ;

@end
