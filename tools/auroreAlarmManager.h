@interface MTAlarm
- (NSUUID *)alarmID;
- (NSString *)alarmIDStr;
@end

@interface MTMutableAlarm : MTAlarm
@end

@interface MTAlarmStorage : NSObject
- (NSArray *)allAlarms;
- (void)loadAlarms;
@end

@interface auroreAlarmManager : NSObject
@property (nonatomic,retain) NSArray *alarms;
- (id)init;
- (NSString *)alarmsPath;
- (NSString *)defaultsPath;
- (NSString *)versionPath;
- (BOOL)setAlarm:(NSString *)alarmID withData:(NSMutableDictionary *)data;
- (NSMutableDictionary *)getAlarm:(NSString *)alarmID;
- (NSMutableDictionary *)getDefaults;
- (void)syncAlarmsIfNeeded;
- (NSInteger)fileSetup:(BOOL)isUpdate;

@end

