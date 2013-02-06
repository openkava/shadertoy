//
//  myUtil.m
//  GalaxyForIOS
//
//  Created by ydf on 12-12-26.
//  Copyright (c) 2012年 itoc. All rights reserved.
//

#import "myUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import "Encryption.h"
#import "NSData+MKBase64.h"
@implementation MyUtil


+(void)showMessage :(NSString*) msg title: (NSString*) title 
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg 
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确认", @"")
                                          otherButtonTitles:nil];
    [alert show];
}

+(NSString*) numberFormatString:(NSString*) input
{
    int i= input.intValue;
     
    return  [NSNumberFormatter localizedStringFromNumber:@(i)
                                     numberStyle:NSNumberFormatterDecimalStyle];
     
}
+(NSString*) numberFormatNumber:(NSNumber*) input
{
    return  [NSNumberFormatter localizedStringFromNumber: input
                                             numberStyle:NSNumberFormatterDecimalStyle];
}
+ (NSString *)md5HexDigestUTF16:(NSString*)input
{

    NSData *data = [input dataUsingEncoding:NSUTF16LittleEndianStringEncoding allowLossyConversion:NO];
    //const char * str =data.bytes ;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, data.length, result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return [ret lowercaseString];
    
    //NSString *base64 = [hashData base64EncodedString];
    // NSLog(@"%@", base64);
    
}
+ (NSString *)md5HexDigestUTF8:(NSString*)input
{
    const char* str = [input UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02X",result[i]];
    }
    return [ret lowercaseString];
    
}
+(NSInteger) getYear
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
     
    comps = [calendar components:unitFlags fromDate:now];
    NSInteger thisyear = [comps year];
    return thisyear; 
}

+(NSString*) getYearMonth
{
    NSDate *now = [[NSDate date] dateByAddingTimeInterval: MONTH_SECONDS];
    return  [MyUtil getYearMonth:  now ];
   
}
+(NSString*) getYearMonth :(NSDate *)mydate
{
   
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:mydate];
    
    int month =[comps month];
    NSString *strMonth;
    if( month <10)
        strMonth = [NSString stringWithFormat:@"0%d" ,month];
    else
        strMonth = [NSString stringWithFormat:@"%d" ,month];
    
    
    NSString *r = [NSString stringWithFormat:@"%d%@" ,[comps year] ,strMonth];
    
    
    return r ; // @"201212" ;
    
}
 
+ (float)  floatFormatString:(NSString*) input
{
    float  i= input.floatValue;
    return i;
}
+ (NSString *) jsonFromDic: (NSDictionary *) dic
{
    NSError *error=nil;
    NSString *jsonString =nil;    
    NSData *jsonData= [NSJSONSerialization dataWithJSONObject:dic options: NSJSONWritingPrettyPrinted error:&error];
    
    if([jsonData length] >0 && error == nil)
    {
        DLog(@"success serialized data to json");
        jsonString = [[NSString alloc] initWithData:jsonData encoding: NSUTF8StringEncoding];
        DLog(@" json :%@",jsonString);
    }
    else if ([jsonData length ] >0  && error == nil)
    {
        DLog(@"No data to json");
    }
    if ( error != nil)
    {
        DLog(@"Error  to json");
    }
    return jsonString;
}
+ (void) openWeb: (NSString *) url
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

}
+(NSString*) getAppVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    return app_Version;
}
// 检查是否出错，如果出错，提示出错，返回NO ，否则返回YES
+ (BOOL)  checkJsonResult:(NSDictionary*) data
{
    id error = [data objectForKey:@"Error"];
    if( data ==nil || [data isEqual:[NSNull null]] || error !=nil)
    {
        [MyUtil showMessage: error  title:@"Galaxy"];
        return NO;
    }
    return YES;
}
+ (NSString*) getDeviceInfo
{
    NSString *content=[[NSString alloc]
                       initWithFormat:
                       @"%@:%@",
                       [[UIDevice currentDevice] systemName],                        
                       [[UIDevice currentDevice] systemVersion]];
                      
                       
    DLog(@"%@",content);
    return content; 
}
+ (BOOL) setPreference:(NSString*) key  value:(NSString*) value
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];        
    BOOL r = [defaults synchronize];
    defaults = nil;
    return r;
}
+ (NSString*) getPreference:(NSString*) key
{
    NSString *s;
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    @try {
          s= [defaults objectForKey:key];//根据键值取出name       
    }
    @catch (NSException *exception) {
        NSLog(@"Error read saved data: %@",key);
        s =@"";
    }
    @finally {
        defaults = nil;
        return s;
    }
    
}
+ (NSString *) encrypt : (NSString*) txt
{
    NSData *plain = [txt dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipher = [plain AES256EncryptWithKey:AES_KEY];
    return [cipher base64EncodedString];
    
   
}
+ (NSString *) decrypt : (NSString*) txt
{
    NSData *cipher = [NSData dataFromBase64String:txt];
    
//    NSLog(@"%@",[cipher newStringInBase64FromData] );
//    printf("%s\n", [[cipher description] UTF8String]);
    
    NSData *plain1 =[cipher AES256DecryptWithKey:AES_KEY];
    return [[NSString alloc] initWithData:plain1 encoding:NSUTF8StringEncoding];
    
   
   
}
+ (BOOL)    sendOALogin
{
    return YES;
}
+ (BOOL) isEmpty: (id) obj
{
    if( obj ==nil || [[NSNull null] isEqual:obj])
        return YES;
    else
        return NO ;
}
+ (BOOL) isStringEmpty: (NSString*) obj
{
    if( obj ==nil || [[NSNull null] isEqual:obj] || [@"" isEqualToString:obj])
        return YES;
    else
        return NO ;
}
+ (void)checkNewVersion:(id) alertDelegate showHint:(BOOL) isShow
{
//    NSDictionary *requestData= @{ @"Module" : MODULE_NAME  };;
//    NSString *method = @"Galaxy.Server.Environment.Mobile.UpdateManagement.GetUpdateItems";
//
//    [ApplicationDelegate.netDataPost postGetDataWithRequestData: requestData method: method usingBlockObject:^(NSDictionary *dataSet) {
//        NSArray *dt = dataSet[@"t_Update_Items"];
//        NSDictionary *item = dt[0];
//        NSString *app_Version =  [MyUtil getAppVersion];
//        
//        NSString *version   =   item[@"ItemVersion"];
//        NSString *updateUrl =   item[@"ItemDownloadUrl"];
//        NSLog(@"url :%@",updateUrl);
//        ApplicationDelegate.updateUrl = updateUrl;
//        ApplicationDelegate.lastCheckUpdateDT = [NSDate date];
//        if ( ![version isEqualToString:app_Version])
//        {
//            UIAlertView *av=[[UIAlertView alloc] initWithTitle:@"检测新版本"
//                                                       message:@"检测到有新版本的程序，是否更新？"
//                                                      delegate:alertDelegate
//                                             cancelButtonTitle:@"取消" otherButtonTitles: @"确认",nil];
//            [av show];
//             
//        }
//        else
//        {
//           if( isShow==YES)
//               [MyUtil showMessage:@"当前版本已经是最新版本" title:@"检测新版本"];
//           
//        }
//    }];
    
}
+ (NSString*) loadFile:(NSString*)fileName  fileExt:(NSString*) ext {
    
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:fileName
                                                           ofType:ext];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        return @"";
    }
    return shaderString;
}
@end
