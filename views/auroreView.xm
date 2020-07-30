#import "auroreView.h"

static UIColor *colorFromHexString(NSString *hexString, float alpha) {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    UIColor *color = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
    return color;
}

@implementation auroreView
- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    return self;
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView * view in [self subviews]) {
        if (view.userInteractionEnabled && [view pointInside:[self convertPoint:point toView:view] withEvent:event]) {
            return YES;
        }
    }
    return NO;
}
- (CSEnhancedModalButton *)setupDismissButton:(CGRect)frame color:(NSString *)color alpha:(float)alpha size:(float)size radius:(float)radius {
    self.auroreDismissButton = [[%c(CSEnhancedModalButton) alloc] initWithFrame:frame];
	[self.auroreDismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [self.auroreDismissButton _setContinuousCornerRadius:radius];
    self.auroreDismissButton.titleLabel.font = [UIFont systemFontOfSize:size];
    self.auroreDismissButton.userInteractionEnabled = YES;
    if (color) {
        self.auroreDismissButton.backgroundColor = colorFromHexString(color, alpha);
    }
    [self addSubview:self.auroreDismissButton];

    return self.auroreDismissButton;
}
- (CSEnhancedModalButton *)setupSnoozeButton:(CGRect)frame color:(NSString *)color alpha:(float)alpha size:(float)size radius:(float)radius {
    self.auroreSnoozeButton = [[%c(CSEnhancedModalButton) alloc] initWithFrame:frame];
	[self.auroreSnoozeButton setTitle:@"Snooze" forState:UIControlStateNormal];
    [self.auroreSnoozeButton _setContinuousCornerRadius:radius];
    self.auroreSnoozeButton.titleLabel.font = [UIFont systemFontOfSize:size];
    self.auroreSnoozeButton.userInteractionEnabled = YES;
    if (color) {
        self.auroreSnoozeButton.backgroundColor = colorFromHexString(color, alpha);
    }
    [self addSubview:self.auroreSnoozeButton];

    return self.auroreSnoozeButton;
}
- (void)showCameraView {
    // future feature
}
@end