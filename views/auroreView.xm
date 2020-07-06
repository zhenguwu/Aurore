#import "auroreView.h"

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
- (UIButton *)setupDismissButton:(CGRect)frame radius:(float)radius {
    self.auroreDismissButton = [[%c(CSEnhancedModalButton) alloc] initWithFrame:frame];
	[self.auroreDismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [self.auroreDismissButton _setContinuousCornerRadius:radius];
    self.auroreDismissButton.userInteractionEnabled = YES;
    [self addSubview:self.auroreDismissButton];

    return self.auroreDismissButton;
}
- (UIButton *)setupSnoozeButton:(CGRect)frame radius:(float)radius {
    self.auroreSnoozeButton = [[%c(CSEnhancedModalButton) alloc] initWithFrame:frame];
	[self.auroreSnoozeButton setTitle:@"Snooze" forState:UIControlStateNormal];
    [self.auroreSnoozeButton _setContinuousCornerRadius:radius];
    self.auroreSnoozeButton.userInteractionEnabled = YES;
    [self addSubview:self.auroreSnoozeButton];

    return self.auroreSnoozeButton;
}
- (void)showCameraView {
    
}
@end