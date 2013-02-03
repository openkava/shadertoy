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
}

@end