@interface MTAlarm
- (NSUUID *)alarmID;
- (NSString *)alarmIDStr;
+ (id)alarmWithHour:(unsigned long long)arg1 minute:(unsigned long long)arg2;
- (void)setTitle:(NSString *)arg1;
@end

@interface MTMutableAlarm : MTAlarm
@end

@interface MTAlarmStorage : NSObject
- (NSArray *)allAlarms;
- (MTAlarm *)sleepAlarm;
- (void)loadAlarms;
@end

@interface auroreAlarmManager : NSObject
@property (nonatomic,retain) NSArray *alarms;
@property (nonatomic,retain) MTAlarm *sleepAlarm;
- (id)init;
- (BOOL)setAlarm:(NSString *)alarmID withData:(NSMutableDictionary *)data;
- (NSMutableDictionary *)getAlarm:(NSString *)alarmID;
- (NSMutableDictionary *)getDefaults;
- (NSMutableDictionary *)getSleepAlarm;
- (void)setSleepAlarmWithData:(NSMutableDictionary *)data;
- (void)syncAlarmsIfNeeded;
- (NSInteger)fileSetup:(BOOL)isUpdate;
@end

