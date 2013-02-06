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
    self.mTitle.text =@"1";
    
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
    
    [self.mTitle resignFirstResponder];
    
    int itemID = self.mTitle.text.intValue;
     
    self.mySlider.value = itemID +1;
    
    self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
    //int itemID = (int)self.mySlider.value;
    NSString *path = [NSString stringWithFormat:@"%@%d" , GLSL_FRAGMENT_JSON, itemID ];
    
    [ApplicationDelegate.netDataPost postGetDataWithRequestData: path  usingBlockObject:^(NSDictionary *dataSet) {
        
        //NSLog(@"%@" ,dataSet);
        NSString *fsh =  dataSet[@"code"]  ;
        //NSLog(@"%@" ,fsh);
        NSLog(@"this is : %d" ,(int)self.mySlider.value);
        
        if(simpleGLView!=nil)
        {
            [simpleGLView removeFromSuperview];
            simpleGLView =nil;
        }
        CGRect screenBounds  = self.mGLContainerView.bounds;
        simpleGLView  =  [SimpleOpenGLView alloc]  ;
        simpleGLView.shaderF = fsh;
        simpleGLView = [simpleGLView initWithFrame:screenBounds];
        [self.mGLContainerView addSubview:simpleGLView];
        [self.mGLContainerView bringSubviewToFront:simpleGLView];
        
  
         
       
    }];
    

    
}
- (void)viewDidUnload {
    [self setMGLContainerView:nil];
    [self setMySlider:nil];
    [self setMTitle:nil];
    [self setMGLContainerView2:nil];
    [self setMTitle:nil];
    [super viewDidUnload];
}
- (IBAction)doSliderChange:(id)sender {
    
    self.mTitle.text = [NSString stringWithFormat:@"%d" ,(int)self.mySlider.value ];
}
@end
