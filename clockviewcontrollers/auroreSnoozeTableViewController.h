@interface auroreSnoozeTableViewController : UITableViewController
@property (nonatomic,retain) NSNumber *snoozeEnabled;
@property (nonatomic,retain) NSNumber *snoozeCount;
@property (nonatomic,retain) NSNumber *snoozeTime;
@property (nonatomic,retain) NSNumber *snoozeVolume;
@property (nonatomic,retain) NSNumber *snoozeVolumeTime;
- (id)initWithSettings:(NSDictionary *)settings;
@end