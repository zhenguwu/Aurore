#import "MTBBarcodeScanner.h"

@interface auroreScanner : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) UIView *viewforCamera;

- (BOOL)startScanning;

- (void)stopScanning;

@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end