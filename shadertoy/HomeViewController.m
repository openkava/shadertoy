//
//  HomeViewController.m
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
//

#import "HomeViewController.h"
#import "ViewController.h"
#import "SimpleOpenGLView.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    itemID = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shader1:(id)sender {
    
    ViewController *v  = [[ViewController alloc] init];
    
    [self.navigationController pushViewController:v animated:YES];
    
}
- (IBAction)shader2:(id)sender {
    
    ViewController *v  = [[ViewController alloc] init];
    
    [self.navigationController pushViewController:v animated:YES];
    
}
- (IBAction)shader3:(id)sender {
}


- (IBAction)doPrevious:(id)sender {
    
    ViewController *v  = [[ViewController alloc] init];
    
    [self.navigationController pushViewController:v animated:YES];
}
SimpleOpenGLView *simpleGLView;
- (IBAction)doNext:(id)sender {
    
     
    itemID++;
    NSString *path = [NSString stringWithFormat:@"%@%d" , GLSL_FRAGMENT_JSON, itemID ];
    
    [ApplicationDelegate.netDataPost postGetDataWithRequestData: path  usingBlockObject:^(NSDictionary *dataSet) {
        
        //NSLog(@"%@" ,dataSet);
        NSString *fsh =  dataSet[@"code"]  ;
        //NSLog(@"%@" ,fsh);
        NSLog(@"this is : %d" ,itemID);
        
        if(simpleGLView!=nil)
        {
            [simpleGLView removeFromSuperview];
            simpleGLView =nil;
        }
        
        simpleGLView  = [[SimpleOpenGLView  alloc] init];
        //simpleGLView.shaderF = fsh;
        [self.mGLContainerView addSubview:simpleGLView];
        [self.mGLContainerView bringSubviewToFront:simpleGLView];
        
       // [self.navigationController pushViewController:v animated:YES];
         
    }];
    

    
}
- (void)viewDidUnload {
    [self setMGLContainerView:nil];
    [super viewDidUnload];
}
@end
