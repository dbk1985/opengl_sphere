//
//  ViewController.m
//  Sphere
//
//  Created by alan on 2018/11/12.
//  Copyright © 2018年 alan. All rights reserved.
//

#import "ViewController.h"
#import "EAGLView.h"
#import "SphereViewcontroller.h"
#import "PanoramaViewController.h"
#import "pathSleepController.h"
#import "ColorTrackingViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _glView.animationInterval = 1.0 / 60.0;
    [_glView startAnimation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)action:(id)sender {
//    [self.navigationController pushViewController:[[pathSleepController alloc] initWithNibName:@"pathSleepController" bundle:nil] animated:YES];
    [self.navigationController pushViewController:[[PanoramaViewController alloc] initWithUrlPath:[UIImage imageNamed:@"timg.jpeg"]] animated:YES];
    [self.navigationController pushViewController:[SphereViewcontroller new] animated:YES];
}
- (IBAction)boxTest:(UIBarButtonItem *)sender {
    [self.navigationController pushViewController:[[ColorTrackingViewController alloc] initWithScreen:[UIScreen mainScreen]] animated:YES];
}

@end
