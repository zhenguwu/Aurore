#import "auroreAlarmManager.h"
#import "../tools/constants.h"

@implementation auroreAlarmManager
- (id)init {
    self = [super init];
    MTAlarmStorage *alarmStorage = [[%c(MTAlarmStorage) alloc] init];
    [alarmStorage loadAlarms];
    self.alarms = [alarmStorage allAlarms];
    return self;
}

- (NSString *)alarmsPath {
	return @"/var/mobile/Library/Preferences/Aurore/alarms.plist";
}
- (NSString *)defaultsPath {
	return @"/var/mobile/Library/Preferences/Aurore/defaults.plist";
}
- (NSString *)versionPath {
    return @"/var/mobile/Library/Preferences/Aurore/version.txt";
}

- (NSMutableDictionary *)getAllAlarms {
    return [[NSMutableDictionary alloc] initWithContentsOfFile:[self alarmsPath]];
}
- (BOOL)setAlarm:(NSString *)alarmID withData:(NSMutableDictionary *)data {
    NSMutableDictionary *currentAlarms = [self getAllAlarms];
    if (data) {
        currentAlarms[alarmID] = data;
    } else {
        [currentAlarms removeObjectForKey:alarmID];
    }
    [currentAlarms writeToFile:[self alarmsPath] atomically:YES];
    return YES;
}

- (NSMutableDictionary *)getAlarm:(NSString *)alarmID {
    return (NSMutableDictionary *)[self getAllAlarms][alarmID];
}
- (NSMutableDictionary *)getDefaults {
    return [[NSMutableDictionary alloc] initWithContentsOfFile:[self defaultsPath]];
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
        [currentAlarms writeToFile:[self alarmsPath] atomically:YES];
    }
}

- (NSInteger)fileSetup:(BOOL)isUpdate {
	NSDictionary *defaults =  @{
        @"enabled" : @NO,
        @"link" : @"",
        @"linkContext" : @"",
        @"shuffle" : @YES,
        @"volumeMax" : @100,
        @"volumeTime" : @180,
        @"bluetooth" : @"",
        @"airplay" : @"",
        @"snoozeEnabled" : @YES,
        @"snoozeCount" : @1,
        @"snoozeTime" : @300,
        @"snoozeVolume" : @0,
        @"snoozeVolumeTime" : @120,
        @"showWeather" : @YES,
        @"dismissAction" : @0,
        @"shortcutFire" : @"",
        @"shortcutSnooze" : @"",
        @"shortcutAlarm" : @"",
	};
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (isUpdate) {
		;
	} else {
		NSString *dir = @"/var/mobile/Library/Preferences/Aurore";
		[fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
		[fileManager createFileAtPath:[self defaultsPath] contents:nil attributes:nil];	
		[defaults writeToFile:[self defaultsPath] atomically:YES];
		
		[fileManager createFileAtPath:[self alarmsPath] contents:nil attributes:nil];
		NSMutableDictionary *auroreAlarms = [[NSMutableDictionary alloc] init];
		for (MTAlarm *alarm in self.alarms) {
			auroreAlarms[[alarm alarmIDStr]] = defaults;
		}
		[auroreAlarms writeToFile:[self alarmsPath] atomically:YES];
		[fileManager createFileAtPath:[self versionPath] contents:nil attributes:nil];
		[fileManager createFileAtPath:@"/var/mobile/Library/Preferences/Aurore/README.txt" contents:nil attributes:nil];
		[@"These files are essential to Aurore. Tampering with them may break the functionality of the tweak." writeToFile:@"/var/mobile/Library/Preferences/Aurore/README.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
	}
	[auroreVersion writeToFile:[self versionPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
	return 2;
}


@end