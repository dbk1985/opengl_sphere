//
//  DZGLView.m
//  Sphere
//
//  Created by wzkj on 2018/11/23.
//  Copyright © 2018 alan. All rights reserved.
//

#import "DZGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "SGDistortionRenderer.h"

#define USE_DEPTH_BUFFER 0

@interface DZGLView ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, strong) SGDistortionRenderer *render;
@end

@implementation DZGLView
@synthesize context;

// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }
    
        self.render = [SGDistortionRenderer distortionRenderer];
        
        [self loadImage:@"timg.jpeg"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self drawView];
}

- (BOOL)createFramebuffer {
    
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffers(1, &depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, backingWidth, backingHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    return YES;
}

- (void)destroyFramebuffer {
    
    glDeleteFramebuffers(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffers(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffers(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}

- (void)drawView {
    [EAGLContext setCurrentContext:context];
    [self.render beforDrawFrame];
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    [self.render afterDrawFrame];
    [context presentRenderbuffer:viewRenderbuffer];
}

-(void)loadImage:(NSString *)imageName
{
    CGImageRef woodImage;
    size_t width;
    size_t height;
    
    woodImage = [UIImage imageNamed:imageName].CGImage;
    width = CGImageGetWidth(woodImage);
    height = CGImageGetHeight(woodImage);
    //    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (woodImage) {
        GLubyte *woodImageData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        CGContextRef imageContext = CGBitmapContextCreate(woodImageData,
                                                          width,
                                                          height,
                                                          8,
                                                          width * 4,
                                                          /** colorSpace */CGImageGetColorSpace(woodImage),
                                                          kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), woodImage);
        CGContextRelease(imageContext);
        
//        glBindTexture(GL_TEXTURE_2D, userData->textureId);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, woodImageData);

        free(woodImageData);
    }
}

@end
