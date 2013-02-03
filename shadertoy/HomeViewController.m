//
//  HomeViewController.m
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
//

#import "HomeViewController.h"
#import "ViewController.h"

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
    // Do any additional setup after loading the view from its nib.
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
}
- (IBAction)shader3:(id)sender {
}

@end
