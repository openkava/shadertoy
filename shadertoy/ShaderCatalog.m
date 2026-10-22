#import "ShaderCatalog.h"

@implementation ShaderSample
@end

@implementation ShaderCatalog

+ (ShaderSample *)sample:(NSString *)title
                resource:(NSString *)resource
                function:(NSString *)function
                   blurb:(NSString *)blurb
           lowResolution:(BOOL)lowResolution {
    ShaderSample *sample = [[ShaderSample alloc] init];
    sample.title = title;
    sample.resourceName = resource;
    sample.functionName = function;
    sample.blurb = blurb;
    sample.lowResolution = lowResolution;
    return sample;
}

+ (NSArray<ShaderSample *> *)samples {
    return @[
        [self sample:@"simple1"
            resource:@"simple1"
            function:@"shader_simple1"
               blurb:@"Default shader from the old live view. Drag the image to move mouse."
       lowResolution:NO],
        [self sample:@"simple"
            resource:@"simple"
            function:@"shader_simple"
               blurb:@"Same plasma as simple1.fsh, kept as its own bundled copy."
       lowResolution:NO],
        [self sample:@"Shader"
            resource:@"Shader"
            function:@"shader_Shader"
               blurb:@"Same plasma again. The old GLKit controller loaded this file."
       lowResolution:NO],
        [self sample:@"julia"
            resource:@"julia"
            function:@"shader_julia"
               blurb:@"Julia set, 50 iterations. Points that stay bounded are black."
       lowResolution:NO],
        [self sample:@"heart"
            resource:@"heart"
            function:@"shader_heart"
               blurb:@"Animated heart. The original mouse uniform was an unused vec4."
       lowResolution:NO],
        [self sample:@"monjori"
            resource:@"monjori"
            function:@"shader_monjori"
               blurb:@"Classic Monjori pattern. The source file opens with an \"error\" comment; the shader is complete."
       lowResolution:NO],
        [self sample:@"vision"
            resource:@"vision"
            function:@"shader_vision"
               blurb:@"Perspective grid."
       lowResolution:NO],
        [self sample:@"flower"
            resource:@"flower"
            function:@"shader_flower"
               blurb:@"Kaleidoscope flower with a noise rock texture."
       lowResolution:NO],
        [self sample:@"ray_ball"
            resource:@"ray_ball"
            function:@"shader_ray_ball"
               blurb:@"Raymarched sphere with a sine displacement."
       lowResolution:NO],
        [self sample:@"test"
            resource:@"test"
            function:@"shader_test"
               blurb:@"Raymarched field. The source credits kabuto and tigrou (2013)."
       lowResolution:NO],
        [self sample:@"apple"
            resource:@"apple"
            function:@"shader_apple"
               blurb:@"Raymarched apple. Drawn at point size because the march is heavy."
       lowResolution:YES],
        [self sample:@"raytrace"
            resource:@"raytrace"
            function:@"shader_raytrace"
               blurb:@"Repeated bitten apples. Drawn at point size because the march is heavy."
       lowResolution:YES],
    ];
}

@end
