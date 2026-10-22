#import "MetalShaderView.h"

#import <QuartzCore/CABase.h>
#import <stddef.h>
#import <stdint.h>
#import <string.h>
#import <simd/simd.h>

// Must match ShaderUniforms in Shaders/Metal/ShaderCommon.h.
typedef struct {
    float time;
    simd_float2 mouse;
    simd_float2 resolution;
} ShaderUniforms;

_Static_assert(offsetof(ShaderUniforms, time) == 0, "ShaderUniforms.time offset");
_Static_assert(offsetof(ShaderUniforms, mouse) == 8, "ShaderUniforms.mouse offset");
_Static_assert(offsetof(ShaderUniforms, resolution) == 16, "ShaderUniforms.resolution offset");
_Static_assert(sizeof(ShaderUniforms) == 24, "ShaderUniforms size");

static NSString *const ShaderToyErrorDomain = @"ShaderToy";

@interface MetalShaderView () <MTKViewDelegate>
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLLibrary> library;
@property (nonatomic, strong) id<MTLRenderPipelineState> pipeline;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<MTLRenderPipelineState>> *pipelines;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) simd_float2 mouse;
@end

@implementation MetalShaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame device:MTLCreateSystemDefaultDevice()];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.device = MTLCreateSystemDefaultDevice();
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    self.clearColor = MTLClearColorMake(0.02, 0.02, 0.03, 1.0);
    self.preferredFramesPerSecond = 60;
    self.paused = NO;
    self.enableSetNeedsDisplay = NO;
    self.framebufferOnly = YES;
    self.delegate = self;
    self.pipelines = [NSMutableDictionary dictionary];
    self.startTime = CACurrentMediaTime();
    if (self.device) {
        self.commandQueue = [self.device newCommandQueue];
        self.library = [self.device newDefaultLibrary];
    }
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)applicationDidEnterBackground {
    self.paused = YES;
}

- (void)applicationWillEnterForeground {
    self.paused = NO;
}

- (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:ShaderToyErrorDomain code:1 userInfo:@{NSLocalizedDescriptionKey: message}];
}

- (BOOL)loadShaderFunction:(NSString *)functionName error:(NSError **)error {
    if (!self.device || !self.commandQueue) {
        if (error) {
            *error = [self errorWithMessage:@"This device has no Metal GPU."];
        }
        self.pipeline = nil;
        return NO;
    }
    if (!self.library) {
        self.library = [self.device newDefaultLibrary];
    }
    if (!self.library) {
        if (error) {
            *error = [self errorWithMessage:@"The app bundle has no default Metal library. The .metal sources did not compile into the target."];
        }
        self.pipeline = nil;
        return NO;
    }

    id<MTLRenderPipelineState> pipeline = self.pipelines[functionName];
    if (!pipeline) {
        id<MTLFunction> vertex = [self.library newFunctionWithName:@"fullscreen_vertex"];
        id<MTLFunction> fragment = [self.library newFunctionWithName:functionName];
        if (!vertex || !fragment) {
            if (error) {
                NSString *message = [NSString stringWithFormat:@"Metal function %@ was not found in the default library.", functionName];
                *error = [self errorWithMessage:message];
            }
            self.pipeline = nil;
            return NO;
        }
        MTLRenderPipelineDescriptor *descriptor = [[MTLRenderPipelineDescriptor alloc] init];
        descriptor.vertexFunction = vertex;
        descriptor.fragmentFunction = fragment;
        descriptor.colorAttachments[0].pixelFormat = self.colorPixelFormat;
        NSError *pipelineError = nil;
        pipeline = [self.device newRenderPipelineStateWithDescriptor:descriptor error:&pipelineError];
        if (!pipeline) {
            if (error) {
                *error = pipelineError ?: [self errorWithMessage:@"Metal pipeline creation failed."];
            }
            self.pipeline = nil;
            return NO;
        }
        self.pipelines[functionName] = pipeline;
    }

    self.pipeline = pipeline;
    self.startTime = CACurrentMediaTime();
    self.mouse = (simd_float2){0.0f, 0.0f};
    return YES;
}

- (void)updateMouseWithTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    CGSize bounds = self.bounds.size;
    CGSize drawable = self.drawableSize;
    if (bounds.width < 1.0 || bounds.height < 1.0 || drawable.width < 1.0 || drawable.height < 1.0) {
        return;
    }
    float x = (float)(point.x / bounds.width) * (float)drawable.width;
    float y = (float)(1.0 - (point.y / bounds.height)) * (float)drawable.height;
    self.mouse = (simd_float2){x, y};
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateMouseWithTouch:touches.anyObject];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateMouseWithTouch:touches.anyObject];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateMouseWithTouch:touches.anyObject];
}

- (void)drawInMTKView:(MTKView *)view {
    if (!self.pipeline || !self.commandQueue) {
        return;
    }
    if (view.drawableSize.width < 1.0 || view.drawableSize.height < 1.0) {
        return;
    }
    id<CAMetalDrawable> drawable = view.currentDrawable;
    MTLRenderPassDescriptor *pass = view.currentRenderPassDescriptor;
    if (!drawable || !pass) {
        return;
    }

    ShaderUniforms uniforms;
    memset(&uniforms, 0, sizeof(uniforms));
    uniforms.time = (float)(CACurrentMediaTime() - self.startTime);
    uniforms.mouse = self.mouse;
    uniforms.resolution = (simd_float2){(float)view.drawableSize.width, (float)view.drawableSize.height};

    // Constant-buffer bindings are 16-byte aligned. The shader reads 24 bytes;
    // the extra padding is not part of the struct.
    uint8_t bytes[32] = {0};
    memcpy(bytes, &uniforms, sizeof(uniforms));

    id<MTLCommandBuffer> buffer = [self.commandQueue commandBuffer];
    id<MTLRenderCommandEncoder> encoder = [buffer renderCommandEncoderWithDescriptor:pass];
    [encoder setRenderPipelineState:self.pipeline];
    [encoder setFragmentBytes:bytes length:sizeof(bytes) atIndex:0];
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [encoder endEncoding];
    [buffer presentDrawable:drawable];
    [buffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
}

@end
