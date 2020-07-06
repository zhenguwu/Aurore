#import "auroreAlarmManager.h"
#import "../tools/constants.h"

#define alarmsPath @"/var/mobile/Library/Preferences/Aurore/alarms.plist"
#define defaultsPath @"/var/mobile/Library/Preferences/Aurore/defaults.plist"

@implementation auroreAlarmManager
- (id)init {
    self = [super init];
    MTAlarmStorage *alarmStorage = [[%c(MTAlarmStorage) alloc] init];
    [alarmStorage loadAlarms];
    self.alarms = [alarmStorage allAlarms];
    self.sleepAlarm = [alarmStorage sleepAlarm];
    return self;
}

- (NSMutableDictionary *)getAllAlarms {
    return [[NSMutableDictionary alloc] initWithContentsOfFile:alarmsPath];
}
- (BOOL)setAlarm:(NSString *)alarmID withData:(NSMutableDictionary *)data {
    NSMutableDictionary *currentAlarms = [self getAllAlarms];
    if (data) {
        currentAlarms[alarmID] = data;
    } else {
        [currentAlarms removeObjectForKey:alarmID];
    }
    [currentAlarms writeToFile:alarmsPath atomically:YES];
    return YES;
}

- (NSMutableDictionary *)getAlarm:(NSString *)alarmID {
    return (NSMutableDictionary *)[self getAllAlarms][alarmID];
}
- (NSMutableDictionary *)getDefaults {
    return [[NSMutableDictionary alloc] initWithContentsOfFile:defaultsPath];
}
- (NSMutableDictionary *)getSleepAlarm {
    return [self getAlarm:[self.sleepAlarm alarmIDStr]];
}
- (void)setSleepAlarmWithData:(NSMutableDictionary *)data {
    [self setAlarm:[self.sleepAlarm alarmIDStr] withData:data];
}

- (void)syncAlarmsIfNeeded {
    NSMutableDictionary *currentAlarms = [self getAllAlarms];
    NSMutableArray *realKeysArr = [[NSMutableArray alloc] init];
    for (MTAlarm *alarm in self.alarms) {
        [realKeysArr addObject:[alarm alarmIDStr]];
    }

    NSSet *currentKeys = [NSSet setWithArray:[currentAlarms allKeys]];
    NSSet *realKeys = [NSSet setWithArray:realKeysArr];

    if (![currentKeys isEqualToSet:realKeys]) {
        for (NSString *alarmID in realKeysArr) {
            if (![currentAlarms objectForKey:alarmID]) {
                currentAlarms[alarmID] = [self getDefaults];
            }
        }
        for (NSString *alarmID in currentKeys) {
            if (![realKeysArr containsObject:alarmID]) {
                [currentAlarms removeObjectForKey:alarmID];
            }
        }
        [currentAlarms writeToFile:alarmsPath atomically:YES];
    }
}

- (NSInteger)fileSetup:(BOOL)isUpdate {
	NSDictionary *defaults =  @{
        @"enabled" : @NO,
        @"link" : @"",
        @"linkContext" : @"",
        @"shuffle" : @YES,
        @"volumeMax" : @100,
        @"volumeTime" : @3,
        @"bluetooth" : @"",
        @"airplay" : @"",
        @"snoozeEnabled" : @YES,
        @"snoozeCount" : @1,
        @"snoozeTime" : @5,
        @"snoozeVolume" : @0,
        @"snoozeVolumeTime" : @2,
        @"showWeather" : @YES,
        @"dismissAction" : @0,
        @"shortcut" : @""
	};
    NSDictionary *defaults2 = @{
        @"interfaceStyle" : @2,
        @"blurStyle" : @3,
        @"buttonStyle" : @1,
        @"swapButtons" : @NO,
        @"hideDismiss" : @NO,
        @"bottomOffset" : @50,
        @"spacing" : @10,
        @"dismissWidth" : @130,
        @"dismissHeight" : @50,
        @"dismissCornerRadius" : @24,
        @"snoozeWidth" : @130,
        @"snoozeHeight" : @50,
        @"snoozeCornerRadius" : @24,
        @"lockPlayback" : @YES,
        @"lockVolume" : @YES,
        @"lockLS" : @YES,
        @"lockCC" : @NO,
        @"unlockLSCC" : @YES,
        @"disableCamera" : @YES,
        @"hideButtons" : @NO,
        @"name" : @"",
        @"pauseMusic" : @YES,
        @"setVolume" : @0,
        @"btForceReconnect" : @NO,
        @"btRetryTime" : @5,
        
    };
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (isUpdate) {
		;
	} else {
		NSString *dir = @"/var/mobile/Library/Preferences/Aurore";
		[fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
		[fileManager createFileAtPath:defaultsPath contents:nil attributes:nil];	
		[defaults writeToFile:defaultsPath atomically:YES];
		
		[fileManager createFileAtPath:alarmsPath contents:nil attributes:nil];
		NSMutableDictionary *auroreAlarms = [[NSMutableDictionary alloc] init];
		for (MTAlarm *alarm in self.alarms) {
			auroreAlarms[[alarm alarmIDStr]] = defaults;
		}
		[auroreAlarms writeToFile:alarmsPath atomically:YES];
		[fileManager createFileAtPath:versionPath contents:nil attributes:nil];
		[fileManager createFileAtPath:@"/var/mobile/Library/Preferences/Aurore/README.txt" contents:nil attributes:nil];
		[@"These files are essential to Aurore. Tampering with them may break the functionality of the tweak." writeToFile:@"/var/mobile/Library/Preferences/Aurore/README.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [defaults2 writeToFile:prefsPath atomically:YES];
    }
	[auroreVersion writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
	return 0;
}


@end