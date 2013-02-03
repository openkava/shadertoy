
//
@interface NetDataPost : MKNetworkEngine


typedef void (^postGetDataBlock)(NSDictionary *dataSet);
-(MKNetworkOperation*) postGetDataWithRequestData: (NSDictionary *) requestData method:(NSString*) method  usingBlockObject:(postGetDataBlock) paramBlockObject;

@end
