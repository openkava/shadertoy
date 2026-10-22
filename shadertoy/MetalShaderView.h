#import <MetalKit/MetalKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalShaderView : MTKView

- (BOOL)loadShaderFunction:(NSString *)functionName error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
