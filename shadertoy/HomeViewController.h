//
//  HomeViewController.h
//  shadertoy
//
//  Created by ydf on 13-2-3.
//
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController
{
    
}
- (IBAction)doPrevious:(id)sender;
- (IBAction)doNext:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *mGLContainerView;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
 
- (IBAction)doSliderChange:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *mGLContainerView2;
@property (weak, nonatomic) IBOutlet UITextField *mTitle;

@end
