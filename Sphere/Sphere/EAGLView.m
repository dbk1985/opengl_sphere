//
//  EAGLView.m
//  Simple_TextureCubemap
//
//  Created by Dan Ginsburg on 6/13/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "esUtil.h"
#import "SGDistortionRenderer.h"

// Functions in Simple_TextureCubemap.c
int Init(ESContext *esContext);
void Draw(ESContext *esContext);
void ShutDown(ESContext *esContext);

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;
@property (nonatomic, strong) SGDistortionRenderer *render;


- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;


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
            [self release];
            return nil;
        }
        self.render = [SGDistortionRenderer distortionRenderer];
        animationInterval = 1.0 / 60.0;
		
		Init(&esContext);
        [self loadImage:@"timg.jpeg"];
		prevTick = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}
// https://github.com/BSkyw/study_opengles/blob/ac80e0cae05244e8a0b0beb0aab22bb29baf9ca8/KY_GIF%E7%9A%84%E5%89%AF%E6%9C%AC/KY_GIF/KYView.m
- (void)drawView {
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    // Compute time delta
    NSTimeInterval curTick = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval deltaTime = curTick - prevTick;
    prevTick = curTick;
    
    [EAGLContext setCurrentContext:context];
    [self.render beforDrawFrame];
    esContext.width = backingWidth;
    esContext.height = backingHeight;
    
    Draw(&esContext);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    [self.render afterDrawFrame];
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    self.render.viewportSize = self.frame.size;
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
#define dLimitDegreeUpDown 80.0
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    
    esContext.degreeX += currentPoint.x - previousPoint.x;
    esContext.degreeY += currentPoint.y - previousPoint.y;
    
    // 限制上下转动的角度
    if (esContext.degreeY > dLimitDegreeUpDown) {
        esContext.degreeY = dLimitDegreeUpDown;
    }
    
    if (esContext.degreeY < -dLimitDegreeUpDown) {
        esContext.degreeY = -dLimitDegreeUpDown;
    }
    
}
- (void)startAnimation {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawView) userInfo:nil repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


- (void)setAnimationInterval:(NSTimeInterval)interval {
    
    animationInterval = interval;
    if (animationTimer) {
        [self stopAnimation];
        [self startAnimation];
    }
}


- (void)dealloc {
    
	ShutDown(&esContext);
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
    [super dealloc];
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
        if (esContext.updateTextureData) {
            esContext.updateTextureData(&esContext,width,height,woodImageData);
        }
        free(woodImageData);
    }
}

@end
