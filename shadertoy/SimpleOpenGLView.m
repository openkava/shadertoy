//
//  SimpleOpenGLView.m
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
// http://www.cnblogs.com/andyque/archive/2011/08/08/2131019.html

#import "SimpleOpenGLView.h"
#import "util/MyUtil.h"
@implementation SimpleOpenGLView

// Replace initWithFrame with this
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initFirst] ;
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self setupDisplayLink];
    }
    return self;
}
GLfloat screenX ,screenY;
GLfloat mouseX ,mouseY;
GLfloat ftime;
GLuint _mouse;
GLuint _time;
GLuint _resolution;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}
- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
    
}
-(void) initFirst {
    
    self.startTime =[NSDate date];
    screenX = self.frame.size.width;
    screenY = self.frame.size.height;
    self.shaderVName =@"simple1";
    self.shaderFName =@"test";
    
     self.shaderV  = [MyUtil loadFile : self.shaderVName fileExt:@"vsh"];
    if(self.shaderF ==nil || self.shaderF.length <1)
       self.shaderF  = [MyUtil loadFile : self.shaderFName fileExt:@"fsh"];
}


- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}
- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}
- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}
- (void)render :(CADisplayLink*)displayLink {
    
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
    
    ftime = -[self.startTime timeIntervalSinceNow];
    glUniform1f(_time, ftime );
    glUniform2f(_mouse, mouseX ,mouseY);
    glUniform2f(_resolution, screenX  ,screenY);
    
    // 3
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
   
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    
   // NSLog(@"ftime: %f", ftime);

    
}
- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)dealloc
{
        _context = nil;
  //  _eaglLayer = nil;
    self.shaderF =nil;
    self.shaderV =nil;
    
}


- (GLuint)compileShader:(NSString*)shaderString withType:(GLenum)shaderType  {
   
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}
- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:self.shaderV      withType:GL_VERTEX_SHADER]  ;
    GLuint fragmentShader = [self compileShader:self.shaderF     withType:GL_FRAGMENT_SHADER ];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    _time = glGetUniformLocation(programHandle, "time");
    _mouse = glGetUniformLocation(programHandle, "mouse");
    _resolution = glGetUniformLocation(programHandle, "resolution");
     
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
//    glEnableVertexAttribArray(_time);
//    glEnableVertexAttribArray(_mouse);
//    glEnableVertexAttribArray(_resolution);
    
}

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {0, 1, 0, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

- (void)setupVBOs {
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
   // NSLog(@"sizeof Vertices: %ld",sizeof(Vertices));
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
   //  NSLog(@"sizeof Indices: %ld",sizeof(Indices));
    
}
#pragma mark - touch  methods
CGPoint originalLocation;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    originalLocation = [touch locationInView:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch =  [touches anyObject];
    if(touch.tapCount == 1)
    {
        self.backgroundColor = [UIColor redColor];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self];
    CGRect frame = self.frame;
    frame.origin.x += currentLocation.x-originalLocation.x;
    frame.origin.y += currentLocation.y-originalLocation.y;
    // self.frame = frame;
    mouseX = currentLocation.x;
    mouseY = currentLocation.y;
    
}

@end
