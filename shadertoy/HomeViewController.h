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
    int itemID  ;
}
- (IBAction)doPrevious:(id)sender;
- (IBAction)doNext:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *mGLContainerView;

@end
