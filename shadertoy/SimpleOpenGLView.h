//
//  SimpleOpenGLView.h
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
//

 
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface SimpleOpenGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
}
@property(strong ,nonatomic) NSString  *shaderVName;
@property(strong ,nonatomic) NSString  *shaderFName;
@property(strong ,nonatomic) NSDate    *startTime;

@property(strong ,nonatomic) NSString  *shaderV;
@property(strong ,nonatomic) NSString  *shaderF;

@end