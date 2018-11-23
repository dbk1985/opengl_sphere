//
//  PanoramaViewController.h
//  Sphere
//
//  Created by wzkj on 2018/11/13.
//  Copyright © 2018 alan. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PanoramaViewController : GLKViewController

/// 全景图路径
@property (strong, nonatomic)UIImage* image;

-(id)initWithUrlPath: (UIImage *)image;

@end

NS_ASSUME_NONNULL_END
