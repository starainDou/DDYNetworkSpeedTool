#import "DDYNetworkSpeedTool.h"

#define start1 -0.33
#define measureURL @"http://down.sandai.net/thunder7/Thunder_dl_7.9.34.4908.exe"

@interface DDYNetworkSpeedTool ()<NSURLConnectionDelegate>
/** 测速定时器 */
@property (nonatomic, strong) NSTimer *measureTimer;
/** 测速计时秒 */
@property (nonatomic, assign) NSInteger measureSeconds;
/** 测速请求 */
@property (nonatomic, strong) NSURLConnection *measureConnect;
/** 即时数据 */
@property (nonatomic, strong) NSMutableData *measureInstantData;
/** 累计数据 */
@property (nonatomic, strong) NSMutableData *measureTotalData;


@end

@implementation DDYNetworkSpeedTool

#pragma mark 测速
- (void)startMeasureSpeed {
    _measureSeconds = 0;
    _measureInstantData = [NSMutableData data];
    _measureTotalData = [NSMutableData data];
    _measureTimer = [NSTimer scheduledTimerWithTimeInterval:1. target:self selector:@selector(countTime) userInfo:nil repeats:YES];
    [_measureTimer fire];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:measureURL]];
    _measureConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)countTime {
    if (_measureSeconds >= 15) {
        [self stopMeasureSpeed];
        return;
    }
    _measureSeconds ++;
    if (_measureBlock) {
        _measureBlock(nil, NO, _measureInstantData.length);
    }
    _measureInstantData = [NSMutableData data];
}

- (void)stopMeasureSpeed {
    if (_measureSeconds && _measureBlock) {
        _measureBlock(nil, YES, (_measureTotalData.length/_measureSeconds));
    }
    
    [_measureTimer invalidate];
    _measureTimer = nil;
    [_measureConnect cancel];
    _measureConnect = nil;
    _measureTotalData = nil;
}

#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_measureBlock) _measureBlock(error, NO, 0.);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_measureInstantData appendData:data];
    [_measureTotalData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection{
    [self stopMeasureSpeed];
}

@end
