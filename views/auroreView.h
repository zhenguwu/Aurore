#import "../scanner/auroreScanner.h"

@interface CSEnhancedModalButton : UIButton
- (id)initWithFrame:(CGRect)arg1;
- (void)_setContinuousCornerRadius:(double)arg1;
- (void)_buttonPressed:(id)arg1;
- (void)_buttonReleased:(id)arg1;
@end

@interface auroreView : UIView
@property (nonatomic,retain) CSEnhancedModalButton *auroreDismissButton;
@property (nonatomic,retain) CSEnhancedModalButton *auroreSnoozeButton;
- (id)initWithFrame:(CGRect)rect;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (CSEnhancedModalButton *)setupDismissButton:(CGRect)frame radius:(float)radius;
- (CSEnhancedModalButton *)setupSnoozeButton:(CGRect)frame radius:(float)radius;
- (void)showCameraView;
@end

