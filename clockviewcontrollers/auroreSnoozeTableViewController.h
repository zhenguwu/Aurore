@protocol auroreSnoozeDelegate <NSObject>
- (void)auroreSnoozeTableControllerUpdateSnoozeEnabled:(NSNumber *)snoozeEnabled snoozeCount:(NSNumber *)snoozeCount snoozeTime:(NSNumber *)snoozeTime snoozeVolume:(NSNumber *)snoozeVolume snoozeVolumeTime:(NSNumber *)snoozeVolumeTime;
@end

/*
@interface PSSegmentableSlider : UISlider
- (id)initWithFrame:(CGRect)arg1;
- (void)setValue:(float)arg1 animated:(BOOL)arg2;
- (void)setSegmented:(BOOL)arg1 ;
- (void)setSegmentCount:(unsigned long long)arg1;


@end*/

@interface auroreSnoozeTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic,assign) id <auroreSnoozeDelegate> delegate;
@property (nonatomic,assign) BOOL isSleep;
@property (nonatomic,retain) NSNumber *snoozeEnabled;
@property (nonatomic,retain) NSNumber *snoozeCount;
@property (nonatomic,retain) NSNumber *snoozeTime;
@property (nonatomic,retain) NSNumber *snoozeVolume;
@property (nonatomic,retain) NSNumber *snoozeVolumeTime;
@property (nonatomic,assign) BOOL snoozeSettingsChanged;
- (id)initWithSettings:(NSDictionary *)settings inset:(BOOL)inset isSleep:(BOOL)isSleep;
- (void)returnAndSave;
- (void)saveState;
- (void)snoozeSwitchChanged:(UISwitch *)snoozeSwitch;
- (void)snoozeCountTextFieldChanged:(UITextField *)textField;
- (void)snoozeTimeTextFieldChanged:(UITextField *)textField;
- (void)snoozeVolumeTextFieldChanged:(UITextField *)textField;
- (void)snoozeVolumeTimeTextFieldChanged:(UITextField *)textField;

@end