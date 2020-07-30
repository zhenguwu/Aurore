@protocol auroreMusicDelegate <NSObject>
- (void)auroreMusicTableControllerUpdateLink:(NSString *)link shuffle:(NSNumber *)shuffle volumeMax:(NSNumber *)volumeMax volumeTime:(NSNumber *)volumeTime bluetooth:(NSString *)bluetooth airplay:(NSString *)airplay cast:(NSString *)cast;
- (NSString *)auroreUpdateLinkContext:(BOOL)correct link:(NSString *)link reload:(BOOL)reload;
@end

@interface auroreMusicTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic,assign) id <auroreMusicDelegate> delegate;
@property (nonatomic,assign) BOOL isSleep;
@property (nonatomic,retain) NSString *link;
@property (nonatomic,retain) NSString *linkContext;
@property (nonatomic,retain) NSNumber *shuffle;
@property (nonatomic,retain) NSNumber *volumeMax;
@property (nonatomic,retain) NSNumber *volumeTime;
@property (nonatomic,retain) NSString *bluetooth;
@property (nonatomic,retain) NSString *airplay;
@property (nonatomic,retain) NSString *cast;
@property (nonatomic,assign) BOOL linkChanged;
@property (nonatomic,assign) BOOL musicSettingsChanged;
- (id)initWithSettings:(NSDictionary *)settings inset:(BOOL)inset isSleep:(BOOL)isSleep;
- (void)returnAndSave;
- (void)saveState;
- (void)linkTextFieldChanged:(UITextField *)textField;
- (void)shuffleSwitchChanged:(UISwitch *)shuffleSwitch;
- (void)volumeMaxTextFieldChanged:(UITextField *)textField;
- (void)volumeTimeTextFieldChanged:(UITextField *)textField;
- (void)bluetoothTextFieldChanged:(UITextField *)textField;
- (void)airplayTextFieldChanged:(UITextField *)textField;
- (void)castTextFieldChanged:(UITextField *)textField;
@end