@protocol auroreOthersDelegate <NSObject>
- (void)auroreOthersTableControllerUpdateShowWeather:(NSNumber *)showWeather dismissAction:(NSNumber *)dismissAction shortcut:(NSString *)shortcut;
@end

@interface auroreOthersTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic,assign) id <auroreOthersDelegate> delegate;
@property (nonatomic,assign) BOOL isSleep;
@property (nonatomic,retain) NSNumber *showWeather;
@property (nonatomic,retain) NSNumber *dismissAction;
@property (nonatomic,retain) NSString *shortcut;
@property (nonatomic,assign) BOOL othersSettingsChanged;
- (id)initWithSettings:(NSDictionary *)settings inset:(BOOL)inset isSleep:(BOOL)isSleep;
- (void)returnAndSave;
- (void)saveState;
- (void)weatherSwitchChanged:(UISwitch *)weatherSwitch;
- (void)shortcutTextFieldChanged:(UITextField *)textField;
@end