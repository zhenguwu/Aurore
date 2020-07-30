@protocol auroreOthersDelegate <NSObject>
- (void)auroreOthersTableControllerUpdateShowWeather:(NSNumber *)showWeather dismissAction:(NSNumber *)dismissAction code:(NSString *)code shortcutFire:(NSString *)shortcutFire shortcutDismiss:(NSString *)shortcutDismiss;
- (void)auroreSetAsDefault;
- (void)auroreResetToDefault;
@end

@interface auroreOthersTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic,assign) id <auroreOthersDelegate> delegate;
@property (nonatomic,assign) BOOL isSleep;
@property (nonatomic,retain) NSNumber *showWeather;
@property (nonatomic,retain) NSNumber *dismissAction;
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *shortcutFire;
@property (nonatomic,retain) NSString *shortcutDismiss;
@property (nonatomic,assign) BOOL othersSettingsChanged;
- (id)initWithSettings:(NSDictionary *)settings inset:(BOOL)inset isSleep:(BOOL)isSleep;
- (void)returnAndSave;
- (void)saveState;
- (void)weatherSwitchChanged:(UISwitch *)weatherSwitch;
- (void)mathActionSwitchChanged:(UISwitch *)mathSwitch;
- (void)codeTextFieldChanged:(UITextField *)textField;
- (void)shortcutFireTextFieldChanged:(UITextField *)textField;
- (void)shortcutDismissTextFieldChanged:(UITextField *)textField;
@end