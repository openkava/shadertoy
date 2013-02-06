//
//  myUtil.h
//  GalaxyForIOS
//
//  Created by ydf on 12-12-26.
//  Copyright (c) 2012年 itoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyUtil : NSObject

#define MONTH_SECONDS -1* 30 *24*60.0 *60.0 

+ (void)showMessage :(NSString*) msg title: (NSString*) title  ;
+ (NSString *)md5HexDigestUTF16:(NSString*)input;
+ (NSString *)md5HexDigestUTF8:(NSString*)input;
+ (NSInteger) getYear ;                             //2013
+ (NSString*) numberFormatString:(NSString*) input; // 123,32.2335
+ (NSString*) numberFormatNumber:(NSNumber*) input; // 123,32.2335
+ (NSString*) getYearMonth;                         // 201309
+ (NSString*) getYearMonth :(NSDate *)mydate;       // 201305
+ (float)  floatFormatString:(NSString*) input; // 123255.36655
+ (NSString *) jsonFromDic: (NSDictionary *) dic;
+ (void) openWeb: (NSString *) url;
+ (NSString*) getAppVersion;         // 返回当前版本号
+ (BOOL)  checkJsonResult:(NSDictionary*) data;
+ (NSString*) getDeviceInfo;
+ (BOOL) setPreference:(NSString*) key  value:(NSString*) value;
+ (NSString*) getPreference:(NSString*) key ;

+ (NSString *) encrypt : (NSString*) txt;
+ (NSString *) decrypt : (NSString*) txt;
 
+ (BOOL) isEmpty: (id) obj;
+ (BOOL) isStringEmpty: (NSString*) obj;
+ (void)checkNewVersion: (id) alertDelegate showHint:(BOOL) isShow;
+ (NSString*) loadFile:(NSString*)fileName  fileExt:(NSString*) ext ;
    
 

@end
