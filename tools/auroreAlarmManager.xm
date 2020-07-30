#import "auroreAlarmManager.h"
#import "constants.h"
#import "crypto.h"
#import "helpers.h"
//#import "MobileGestalt.h"
#import <RemoteLog5.h>

#define alarmsPath @"/var/mobile/Library/Preferences/Aurore/alarms.plist"

extern void hikari_bcf(void);
extern void hikari_fla(void);
extern void hikari_indibr(void);
extern void hikari_strenc(void);


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
    NSMutableDictionary *defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:defaultsPath];
    if (![defaults[@"link"] isEqualToString:@""] && [defaults[@"linkContext"] isEqualToString:@""]) {
        NSURL *urlRequest = [NSURL URLWithString:defaults[@"link"]];
		NSError *error = nil;

		NSString *htmlString = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&error];

		if (htmlString) {
            NSString *title;
			NSRegularExpression *regex = [NSRegularExpression
									regularExpressionWithPattern:@"<title[^>]*>(.*?)</title>"
									options:0
									error:&error];
			NSTextCheckingResult *result = [regex firstMatchInString:htmlString options:NSMatchingReportProgress range:NSMakeRange(0, [htmlString length])];
			NSRange titleRange = [result rangeAtIndex:1];
			title = [htmlString substringWithRange:titleRange];
			if ([title containsString:@"&#039;"]) {
				title = [title stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
			}
            defaults[@"linkContext"] = title;
            [self setDefaults:defaults];
        }
    }
    return defaults;
}
- (void)setDefaults:(NSMutableDictionary *)newDefaults {
    [newDefaults writeToFile:defaultsPath atomically:YES];
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
    /*hikari_bcf();
    hikari_fla();
    hikari_indibr();
    hikari_strenc();*/
	NSDictionary *defaults =  @{
        @"enabled" : @NO,
        @"link" : @"",
        @"linkContext" : @"",
        @"shuffle" : @YES,
        @"volumeMax" : @100,
        @"volumeTime" : @3,
        @"bluetooth" : @"",
        @"airplay" : @"",
        @"cast" : @"",
        @"snoozeEnabled" : @YES,
        @"snoozeCount" : @1,
        @"snoozeTime" : @5,
        @"snoozeVolume" : @0,
        @"snoozeVolumeTime" : @2,
        @"showWeather" : @YES,
        @"dismissAction" : @0,
        @"code" : @"",
        @"shortcutFire" : @"",
        @"shortcutDismiss" : @""
	};
    NSDictionary *defaults2 = @{
        @"interfaceStyle" : @2,
        @"blurStyle" : @3,
        @"buttonStyle" : @1,
        @"swapButtons" : @NO,
        @"hideDismiss" : @NO,
        @"bottomOffset" : @"50", //
        @"spacing" : @"10", //
        @"dismissSize" : @"18", //
        @"dismissShouldColor" : @NO,
        @"dismissColor" : @"#fd9426",
        @"dismissAlpha" : @0.5,
        @"dismissWidth" : @"130", //
        @"dismissHeight" : @"50", //
        @"dismissCornerRadius" : @"24", //
        @"snoozeSize" : @"18", //
        @"snoozeShouldColor" : @NO,
        @"snoozeColor" : @"#53d769",
        @"snoozeAlpha" : @0.5,
        @"snoozeWidth" : @"130", //
        @"snoozeHeight" : @"50", //
        @"snoozeCornerRadius" : @"24", //
        @"lockScreen" : @YES,
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
        @"mathDifficulty" : @2,
        @"mathNumber" : @3,
        @"shortcutDelay" : @"5", //
        @"caseSensitive" : @NO,
        @"btForceReconnect" : @NO,
        @"btRetryTime" : @"5", //
        @"airplayForcePhone" : @NO,
        @"compatibility" : @NO,
    };

    pid_t pid;
    int status;
    //const char *args[] = {"ls", [AES128Decrypt([[NSFileManager defaultManager] contentsAtPath:@"/Library/Application Support/MZW/temp_0005A31E.db-shm"]) UTF8String], NULL, NULL};
    const char *args[] = {"ls", "/var/lib/dpkg/info/com.zhenguwu.aurore.list", NULL, NULL};
	posix_spawn(&pid, "/usr/bin/ls", NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, 0);
    
    if (WEXITSTATUS(status) != 2) {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *dir = @"/var/mobile/Library/Preferences/Aurore";

        if (isUpdate) {
            NSString *versionInstalled = [NSString stringWithContentsOfFile:versionPath encoding:NSUTF8StringEncoding error:nil];
            
            NSMutableDictionary *mDefaults = [defaults mutableCopy];
            [mDefaults addEntriesFromDictionary:[[NSDictionary alloc] initWithContentsOfFile:defaultsPath]];
            if (![mDefaults writeToFile:defaultsPath atomically:YES]) {
                postAlert(@"Aurore Error", @"Unable to update defaults file");
                return 1;
            }

            NSMutableDictionary *mDefaults2 = [defaults2 mutableCopy];
            [mDefaults2 addEntriesFromDictionary:[[NSDictionary alloc] initWithContentsOfFile:prefsPath]];
            if (![mDefaults2 writeToFile:prefsPath atomically:YES]) {
                postAlert(@"Aurore Error", @"Unable to update preferences file");
                return 1;
            }
            
            NSMutableDictionary *oldAlarms = [[NSMutableDictionary alloc] initWithContentsOfFile:alarmsPath];
            NSMutableDictionary *auroreAlarms = [[NSMutableDictionary alloc] init];
            for (id key in oldAlarms) {
                NSDictionary *oldAlarm = (NSDictionary *)oldAlarms[key];
                NSMutableDictionary *newAlarm = [self getDefaults];
                [newAlarm addEntriesFromDictionary:oldAlarm];
                auroreAlarms[key] = newAlarm;
            }
            if(![auroreAlarms writeToFile:alarmsPath atomically:YES]) {
                postAlert(@"Aurore Error", @"Unable to update alarms file");
                return 1;
            }

            /*if (![auroreVersion writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
                postAlert(@"Aurore Error", @"Unable to update version file");
                return 1;
            }*/

            return 0;
        } else {
            if (![fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil]) {
                postAlert(@"Aurore Error", @"Unable to setup directory");
                return 1;
            }
            [fileManager createFileAtPath:defaultsPath contents:nil attributes:nil];	
            if (![defaults writeToFile:defaultsPath atomically:YES]) {
                postAlert(@"Aurore Error", @"Unable to write defaults file");
                return 1;
            }

            [fileManager createFileAtPath:alarmsPath contents:nil attributes:nil];
            NSMutableDictionary *auroreAlarms = [[NSMutableDictionary alloc] init];
            for (MTAlarm *alarm in self.alarms) {
                auroreAlarms[[alarm alarmIDStr]] = defaults;
            }
            if(![auroreAlarms writeToFile:alarmsPath atomically:YES]) {
                postAlert(@"Aurore Error", @"Unable to write alarms file");
                return 1;
            }
            [fileManager createFileAtPath:versionPath contents:nil attributes:nil];
            [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/Aurore/README.txt" contents:nil attributes:nil];
            [@"These files are essential to Aurore. Tampering with them may break the functionality of the tweak." writeToFile:@"/var/mobile/Library/Preferences/Aurore/README.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (![defaults2 writeToFile:prefsPath atomically:YES]) {
                postAlert(@"Aurore Error", @"Unable to write preferences file"); 
                return 1;
            }
            if (![auroreVersion writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
                postAlert(@"Aurore Error", @"Unable to write version file");
                return 1;
            }
            return 0;
        }
    } else {
        return 3;
    }   
}

@end