
#import "NetDataPost.h"
#import "AppDelegate.h"
#import "MyUtil.h" 
 

@implementation NetDataPost

-(MKNetworkOperation*) postGetDataWithRequestData: (NSDictionary *) requestData method:(NSString*) method  usingBlockObject:(postGetDataBlock) paramBlockObject
{
    MKNetworkOperation *op = [self operationWithPath:SERVER_PATH
                                              params:@{@"RequestKey": ApplicationDelegate.user.requestKey , @"RequestData":[MyUtil jsonFromDic:requestData], @"RequestMethod":method ,}
                                          httpMethod:@"POST"];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        
        NSError *error=nil;
        NSDictionary *dataSet=nil;
        //NSLog(@"json:%@",operation.responseJSON);
        @try {
               dataSet = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:&error];
          
            
        }
        @finally {
            paramBlockObject(dataSet);
        }
        
        
    } errorHandler:^(MKNetworkOperation *errorOp, NSError* error) {

    }];
    [self enqueueOperation:op];
    return op;
}

 @end
