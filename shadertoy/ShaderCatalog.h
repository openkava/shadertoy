#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShaderSample : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *resourceName;
@property (nonatomic, copy) NSString *functionName;
@property (nonatomic, copy) NSString *blurb;
@property (nonatomic, assign) BOOL lowResolution;

@end

@interface ShaderCatalog : NSObject

+ (NSArray<ShaderSample *> *)samples;

@end

NS_ASSUME_NONNULL_END
