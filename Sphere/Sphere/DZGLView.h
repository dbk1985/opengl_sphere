//
//  DZGLView.h
//  Sphere
//
//  Created by wzkj on 2018/11/23.
//  Copyright © 2018 alan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface DZGLView : UIView{
@private
    /* The pixel dimensions of the backbuffer */
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
   
    /* OpenGL names for the renderbuffer and framebuffers used to render to this view */
    GLuint viewRenderbuffer, viewFramebuffer;
    
    /* OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist) */
    GLuint depthRenderbuffer;
}
@end

NS_ASSUME_NONNULL_END
