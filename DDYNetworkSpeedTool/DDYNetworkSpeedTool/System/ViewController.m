#import "ViewController.h"
#import "DDYNetworkSpeedTool.h"

#ifndef DDYTopH
#define DDYTopH (self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height)
#endif

#ifndef DDYScreenW
#define DDYScreenW [UIScreen mainScreen].bounds.size.width
#endif

#ifndef DDYScreenH
#define DDYScreenH [UIScreen mainScreen].bounds.size.height
#endif

@interface ViewController ()

@property (nonatomic, strong) UIButton *measureButton;

@property (nonatomic, strong) UILabel *speedLabel;

@property (nonatomic, strong) DDYNetworkSpeedTool *netTool;

@end

@implementation ViewController

- (UIButton *)measureButton {
    if (!_measureButton) {
        _measureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_measureButton setTitle:@"start measure speed" forState:UIControlStateNormal];
        [_measureButton setTitle:@"stop measure speed" forState:UIControlStateSelected];
        [_measureButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [_measureButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_measureButton setBackgroundColor:[UIColor lightGrayColor]];
        [_measureButton setFrame:CGRectMake(10, DDYTopH+50, DDYScreenW-20, 30)];
        [_measureButton addTarget:self action:@selector(handleBtn) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _measureButton;
}

- (UILabel *)speedLabel {
    if (!_speedLabel) {
        _speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, DDYTopH+10, DDYScreenW-20, 30)];
        [_speedLabel setFont:[UIFont systemFontOfSize:18]];
        [_speedLabel setTextColor:[UIColor greenColor]];
        [_speedLabel setBackgroundColor:[UIColor lightGrayColor]];
        [_speedLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _speedLabel;
}

- (DDYNetworkSpeedTool *)netTool {
    if (!_netTool) {
        _netTool = [[DDYNetworkSpeedTool alloc] init];
    }
    return _netTool;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.measureButton];
    [self.view addSubview:self.speedLabel];
    __weak __typeof (self)weakSelf = self;
    [self.netTool setMeasureBlock:^(NSError *error, BOOL finish, float speed) {
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        if (error) {
            strongSelf.speedLabel.text = [NSString stringWithFormat:@"%@", error.description];
            strongSelf.measureButton.selected = NO;
        } else if (!finish){
            strongSelf.speedLabel.text = [NSString stringWithFormat:@"speed:%@/s",[strongSelf formatSpeed:speed]];
        } else {
            strongSelf.speedLabel.text = [NSString stringWithFormat:@"avarage:%@/s   bandwidth:%@",[strongSelf formatSpeed:speed], [strongSelf formatBandWidth:speed]];
            strongSelf.measureButton.selected = NO;
        }
    }];
}

- (UIButton *)btn:(CGFloat)x {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"title" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button setFrame:CGRectMake(x, DDYTopH+10, 60, 60)];
    [button addTarget:self action:@selector(handleBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    return button;
}

- (void)handleBtn {
    if ((_measureButton.selected = !_measureButton.selected)) {
        [self.netTool startMeasureSpeed];
    } else {
        [self.netTool stopMeasureSpeed];
    }
}

- (NSString *)formatSpeed:(unsigned long long)size
{
    NSString *formattedStr = nil;
    if (size == 0) {
        formattedStr = @"0 KB";
    } else if (size > 0 && size < 1024) {
        formattedStr = [NSString stringWithFormat:@"%qubytes", size];
    } else if (size >= 1024 && size < pow(1024, 2)) {
        formattedStr = [NSString stringWithFormat:@"%.2fKB", (size / 1024.)];
    } else if (size >= pow(1024, 2) && size < pow(1024, 3)) {
        formattedStr = [NSString stringWithFormat:@"%.2fMB", (size / pow(1024, 2))];
    } else if (size >= pow(1024, 3)) {
        formattedStr = [NSString stringWithFormat:@"%.2fGB", (size / pow(1024, 3))];
    }
    return formattedStr;
}

- (NSString *)formatBandWidth:(unsigned long long)size
{
    size *=8;
    
    NSString *formattedStr = nil;
    if (size == 0) {
        formattedStr = @"0";
    } else if (size > 0 && size < 1024) {
        formattedStr = [NSString stringWithFormat:@"%qu", size];
    } else if (size >= 1024 && size < pow(1024, 2)) {
        int intsize = (int)(size / 1024);
        int model = size % 1024;
        if (model > 512) {
            intsize += 1;
        }
        formattedStr = [NSString stringWithFormat:@"%dK", intsize];
    } else if (size >= pow(1024, 2) && size < pow(1024, 3)) {
        unsigned long long l = pow(1024, 2);
        int intsize = size / pow(1024, 2);
        int  model = (int)(size % l);
        if (model > l/2) {
            intsize +=1;
        }
        formattedStr = [NSString stringWithFormat:@"%dM", intsize];
        
    } else if (size >= pow(1024, 3)) {
        int intsize = size / pow(1024, 3);
        formattedStr = [NSString stringWithFormat:@"%dG", intsize];
    }
    return formattedStr;
}

@end
