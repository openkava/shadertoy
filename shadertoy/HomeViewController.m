#import "HomeViewController.h"

#import "MetalShaderView.h"
#import "ShaderCatalog.h"

@interface HomeViewController ()
@property (nonatomic, strong) MetalShaderView *metalView;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UITextView *sourceView;
@property (nonatomic, assign) NSInteger sampleIndex;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.05 alpha:1.0];
    self.sampleIndex = 0;

    self.metalView = [[MetalShaderView alloc] initWithFrame:CGRectZero];
    self.metalView.translatesAutoresizingMaskIntoConstraints = NO;

    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.detailLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    self.detailLabel.numberOfLines = 2;
    self.detailLabel.adjustsFontForContentSizeCategory = YES;

    self.sourceView = [[UITextView alloc] init];
    self.sourceView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sourceView.editable = NO;
    self.sourceView.selectable = YES;
    self.sourceView.alwaysBounceVertical = YES;
    self.sourceView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:1.0];
    self.sourceView.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.sourceView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.sourceView.font = [UIFont fontWithName:@"Menlo" size:11.0] ?: [UIFont monospacedSystemFontOfSize:11.0 weight:UIFontWeightRegular];
    self.sourceView.textContainerInset = UIEdgeInsetsMake(10.0, 8.0, 10.0, 8.0);

    [self.view addSubview:self.metalView];
    [self.view addSubview:self.detailLabel];
    [self.view addSubview:self.sourceView];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.metalView.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [self.metalView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.metalView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.detailLabel.topAnchor constraintEqualToAnchor:self.metalView.bottomAnchor constant:8.0],
        [self.detailLabel.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:12.0],
        [self.detailLabel.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-12.0],
        [self.sourceView.topAnchor constraintEqualToAnchor:self.detailLabel.bottomAnchor constant:8.0],
        [self.sourceView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.sourceView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.sourceView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.sourceView.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:0.34],
    ]];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStylePlain target:self action:@selector(showPrevious)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(showNext)];

    [self showSampleAtIndex:0];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self applyContentScale];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)showPrevious {
    [self showSampleAtIndex:self.sampleIndex - 1];
}

- (void)showNext {
    [self showSampleAtIndex:self.sampleIndex + 1];
}

- (void)applyContentScale {
    NSArray<ShaderSample *> *samples = [ShaderCatalog samples];
    if (self.sampleIndex < 0 || self.sampleIndex >= (NSInteger)samples.count) {
        return;
    }
    CGFloat scale = samples[self.sampleIndex].lowResolution ? 1.0 : UIScreen.mainScreen.scale;
    if (self.metalView.contentScaleFactor != scale) {
        self.metalView.contentScaleFactor = scale;
    }
}

- (void)showSampleAtIndex:(NSInteger)index {
    NSArray<ShaderSample *> *samples = [ShaderCatalog samples];
    if (samples.count == 0) {
        return;
    }
    if (index < 0) {
        index = (NSInteger)samples.count - 1;
    }
    if (index >= (NSInteger)samples.count) {
        index = 0;
    }
    self.sampleIndex = index;
    ShaderSample *sample = samples[index];
    self.title = [NSString stringWithFormat:@"%@ (%ld/%lu)", sample.title, (long)index + 1, (unsigned long)samples.count];
    self.detailLabel.text = sample.blurb;
    [self applyContentScale];

    NSError *error = nil;
    BOOL loaded = [self.metalView loadShaderFunction:sample.functionName error:&error];
    NSString *path = [[NSBundle mainBundle] pathForResource:sample.resourceName ofType:@"fsh"];
    NSString *source = nil;
    if (path) {
        source = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    if (!loaded) {
        NSString *message = error.localizedDescription ?: @"Unable to load the Metal shader.";
        self.sourceView.text = [NSString stringWithFormat:@"// %@\n\n%@", message, source ?: @""];
    } else if (source) {
        self.sourceView.text = source;
    } else {
        self.sourceView.text = @"Shader source was not found in the app bundle.";
    }
    [self.sourceView scrollRangeToVisible:NSMakeRange(0, 0)];
}

@end
