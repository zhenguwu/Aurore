#import <spawn.h>
#import <dlfcn.h>
#import <RemoteLog5.h>
#import "tools/constants.h"
#import "tools/helpers.h"
#import "tools/MediaRemote.h"
//#import "tools/MobileGestalt.h"
#import "tools/crypto.h"
#import "clockviewcontrollers/auroreMusicTableViewController.h"
#import "clockviewcontrollers/auroreSnoozeTableViewController.h"
#import "clockviewcontrollers/auroreOthersTableViewController.h"
#import "interfaces.h"
#import "views/auroreModal.h"
#import "tools/auroreAlarmManager.h"
#import "views/auroreView.h"
//#import "scanner/auroreScanner.h"


%group SpringBoard

%hook NCNotificationDispatcher
-(BOOL)_shouldPostNotificationRequest:(NCNotificationRequest *)req {
	if ([[req sectionIdentifier] isEqualToString:@"com.apple.mobiletimer"]) {
		if ([[[req content] title] isEqualToString:@"Snooze Complete"]) {
			[[%c(SBLockScreenManager) sharedInstance] auroreSnoozeComplete];
			return NO;
		}
		NSDictionary *settings = [self auroreAlarmCheck:[req notificationIdentifier]];
		if (settings && [settings[@"enabled"] boolValue]) {
			[(SpringBoard *)[UIApplication sharedApplication] _simulateHomeButtonPress];
			if ([[%c(SBLockScreenManager) sharedInstance] auroreUnlock:@"XyQO1pAhDniJ5m7EUjglnN5TCE5NmJ7e"]) {
				[[%c(SBLockScreenManager) sharedInstance] auroreMain:settings compatibility:NO];
			}
			return NO;
		}
	}
	return %orig;
}

%new
- (NSDictionary *)auroreAlarmCheck:(NSString *)identifier {
	NSDictionary *settings = [[[auroreAlarmManager alloc] init] getAlarm:identifier];
	if (settings && [settings[@"enabled"] boolValue]) {
		return settings;
	} else {
		return nil;
	}
}
%end


%hook SBLockScreenManager
%property (nonatomic,assign) BOOL showAuroreModal;
%property (nonatomic,assign) BOOL auroreIsUpdate;
%property (nonatomic,assign) BOOL auroreSuccessful; // reused for both modal and alarm
%property (nonatomic,assign) NSInteger auroreError;
%property (nonatomic,assign) BOOL aurorePirate;
%property (nonatomic,retain) NSString *auroreOldVersion;
%property (nonatomic,retain) auroreModal *auroreModal;
%property (nonatomic,retain) auroreAlarmManager *alarmManager;
%property (nonatomic,retain) NSDictionary *auroreSettings;
%property (nonatomic,retain) NSDictionary *auroreSettings2;
%property (nonatomic,retain) MTAlarm *backupAlarm;
%property (nonatomic,assign) BOOL isStation;
%property (nonatomic,retain) NSString *auroreCast;
%property (nonatomic,retain) auroreView *auroreView;
%property (nonatomic,retain) CSDNDBedtimeController *bedtimeContr;
%property (nonatomic,retain) SBDashBoardIdleTimerProvider *idleTimer;
%property (nonatomic,assign) BOOL auroreDismissed;
%property (nonatomic,assign) BOOL auroreCompletelyDismissed;
%property (nonatomic,retain) SBVolumeControl *auroreVolumeContr;
%property (nonatomic,retain) CSEnhancedModalButton *snoozeButton;
%property (nonatomic,assign) float auroreVolume;
%property (nonatomic,assign) int auroreSnoozeCount;
%property (nonatomic,assign) int auroreSnoozeTime;

- (id)init {
	self = %orig;
	self.auroreDismissed = YES;
	self.auroreCompletelyDismissed = YES;

	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:versionPath]) {
		NSString *versionInstalled = [NSString stringWithContentsOfFile:versionPath encoding:NSUTF8StringEncoding error:nil];
		if (![versionInstalled isEqualToString:auroreVersion]) {
			self.showAuroreModal = YES;
			self.auroreIsUpdate = YES;

			self.alarmManager = [[auroreAlarmManager alloc] init];
			NSInteger result = [self.alarmManager fileSetup:YES];
			if (result == 0) {
				self.auroreSuccessful = YES;
			} else if (result == 1) {
				self.auroreSuccessful = NO;
				self.auroreError = 1;
				self.aurorePirate = NO;
			} else if (result == 2) {
				self.auroreSuccessful = NO;
				self.auroreError = 2;
				self.aurorePirate = NO;
			} else {
				self.auroreSuccessful = NO;
				self.aurorePirate = YES;
			}
			self.auroreOldVersion = versionInstalled;
			self.alarmManager = nil;
		} else {
			self.showAuroreModal = NO;
		}
	} else {
		self.showAuroreModal = YES;
		self.auroreIsUpdate = NO;

		self.alarmManager = [[auroreAlarmManager alloc] init];
		NSInteger result = [self.alarmManager fileSetup:NO];
		if (result == 0) {
			self.auroreSuccessful = YES;
		} else if (result == 1) {
			self.auroreSuccessful = NO;
			self.auroreError = 1;
			self.aurorePirate = NO;
		} else if (result == 2) {
			self.auroreSuccessful = NO;
			self.auroreError = 2;
			self.aurorePirate = NO;
		} else {
			self.auroreSuccessful = NO;
			self.aurorePirate = YES;
		}
		self.alarmManager = nil;
	}

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.zhenguwu.aurore" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(auroreProcessNotif:) name:@"com.zhenguwu.aurore" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auroreLog:) name:nil object:nil];
	return self;
}

/*
%new
- (void)auroreLog:(NSNotification *)notif {
	RLog(@"%@", notif);
}*/

// Modal Methods

- (void)lockScreenViewControllerDidDismiss {
	
	if (self.showAuroreModal) {
		self.showAuroreModal = NO;
		
		if (self.auroreIsUpdate) {
			if (self.auroreSuccessful) {
				NSMutableArray *listTitles = [[NSMutableArray alloc] init];
				NSMutableArray *listContents = [[NSMutableArray alloc] init];
				NSMutableArray *listImages = [[NSMutableArray alloc] init];
				[listTitles addObjectsFromArray:@[@"Security", @"Fade In", @"Bug Fixes"]];
				[listContents addObjectsFromArray:@[@"YOU MUST SET YOUR PASSCODE AGAIN IN PREFERENCES. Encryption key has changed and your currently saved passcode will not work.", @"Setting fade in time to 0 will now cause music to instantly reach specified max volume", @"Conflict with Siri resolved. Added dependency I forgot which is needed for snooze functionality"]];
				[listImages addObjectsFromArray:@[[UIImage systemImageNamed:@"exclamationmark.shield"], [UIImage systemImageNamed:@"speaker.3"], [UIImage systemImageNamed:@"exclamationmark.triangle"]]];
				if ([self.auroreOldVersion isEqualToString:@"1.0"]) {
					[listTitles addObjectsFromArray:@[@"Bug Fix"]];
					[listContents addObjectsFromArray:@[@"Fixed an issue where changing the defaults in preferences would cause the clock app to crash upon enabling Music. If you face this issue, click the reset button in preferences.\nFixed Spotify albums being marked as invalid."]];
					[listImages addObjectsFromArray:@[[UIImage systemImageNamed:@"exclamationmark.triangle"]]];
				}
				[self aurorePresentModal:@"Aurore" subTitle:[NSString stringWithFormat:@"What's new in v%@ from v%@", auroreVersion, self.auroreOldVersion] listTitles:listTitles listContents:listContents listImages:listImages style:1];
			} else {
				NSArray *listTitles;
				NSArray *listContents;
				NSArray *listImages;
				if (self.aurorePirate) {
					listTitles = @[@"Ahoy, Matey"];
					listContents = @[@"Please purchase the official verison of Aurore at the link below"];
					listImages = @[[UIImage systemImageNamed:@"dollarsign.circle"]];
					[self aurorePresentModal:@"Aye Aye Pirate" subTitle:nil listTitles:listTitles listContents:listContents listImages:listImages style:2];
				} else {
					if (self.auroreError == 1) {
						listTitles = @[@"Retry", @"Reset", @"Contact"];
						listContents = @[@"Respring to retry the update", @"Reset the tweak's files if respringing does not fix the issue", @"Shoot me an email at Michaelwu21@gmail.com if neither options work"];
						listImages = @[[UIImage systemImageNamed:@"arrow.clockwise"], [UIImage systemImageNamed:@"arrow.2.circlepath"], [UIImage systemImageNamed:@"envelope"]];
					} else {
						listTitles = @[@"Verification Error"];
						listContents = @[@"Make sure you have an internet connection and respring to try again"];
						listImages = @[[UIImage systemImageNamed:@"wifi.exclamationmark"]];
					}
					[self aurorePresentModal:@"Error in Aurore Update" subTitle:[NSString stringWithFormat:@"Failed updating from v%@ to v%@", self.auroreOldVersion, auroreVersion] listTitles:listTitles listContents:listContents listImages:listImages style:3];
				}
			}
		} else {
			NSArray *listTitles;
			NSArray *listContents;
			NSArray *listImages;
			if (self.auroreSuccessful) {
				listTitles = @[@"Settings", @"Clock", @"Music", @"Apple Music", @"Spotify"];
				listContents = @[@"The device passcode must be setup prior to use. The settings also include customization for the interface.", @"Every alarm, including bedtime, can be individually customized. Enabling \"Music\" within the alarm editing pane will reveal further options for configuration.", @"Aurore currently supports the following links:", @"- Any playlist with play and shuffle buttons\n- Radio station", @"- Playlist\n- Track\n- Album"];
				listImages = @[[UIImage systemImageNamed:@"gear"], [UIImage systemImageNamed:@"alarm"], [UIImage systemImageNamed:@"music.note.list"], [UIImage systemImageNamed:@"music.note"], [UIImage systemImageNamed:@"music.note"]];
				[self aurorePresentModal:@"Welcome to Aurore" subTitle:nil listTitles:listTitles listContents:listContents listImages:listImages style:0];
			} else {
				if (self.aurorePirate) {
					listTitles = @[@"Ahoy, Matey"];
					listContents = @[@"Please purchase the official verison of Aurore at the link below"];
					listImages = @[[UIImage systemImageNamed:@"dollarsign.circle"]];
					[self aurorePresentModal:@"Aye Aye Pirate" subTitle:nil listTitles:listTitles listContents:listContents listImages:listImages style:2];
				} else {
					if (self.auroreError == 1) {
						listTitles = @[@"Retry", @"Reset", @"Contact"];
						listContents = @[@"Respring to retry the setup", @"Reset the tweak's files if respringing does not fix the issue", @"Shoot me an email at Michaelwu21@gmail.com if neither options work"];
						listImages = @[[UIImage systemImageNamed:@"arrow.clockwise"], [UIImage systemImageNamed:@"arrow.2.circlepath"], [UIImage systemImageNamed:@"envelope"]];
					} else {
						listTitles = @[@"Verification Error"];
						listContents = @[@"Make sure you have an internet connection and respring to try again"];
						listImages = @[[UIImage systemImageNamed:@"wifi.exclamationmark"]];
					}
					[self aurorePresentModal:@"Error in Aurore Setup" subTitle:nil listTitles:listTitles listContents:listContents listImages:listImages style:3];
				}
			}
		}
	}
	%orig;
}

%new
- (void)aurorePresentModal:(NSString *)title subTitle:(NSString *)subTitle listTitles:(NSArray *)listTitles listContents:(NSArray *)listContents listImages:(NSArray *)listImages style:(NSInteger)style {
	self.auroreModal = [[auroreModal alloc] initWithTitle:title detailText:subTitle];
	
	for (int x = 0; x < [listTitles count]; x++) {
		[self.auroreModal addBulletedListItemWithTitle:listTitles[x] description:listContents[x] image:listImages[x]];
	}

	OBBoldTrayButton *button = [self.auroreModal buttonForStyle:style];
	if (style == 0) {
		[button addTarget:self action:@selector(auroreModalSetup) forControlEvents:UIControlEventTouchUpInside];
	} else if (style == 1) {
		[button addTarget:self action:@selector(auroreModalUpdate) forControlEvents:UIControlEventTouchUpInside];
	} else if (style == 2) {
		[button addTarget:self action:@selector(auroreModalPurchase) forControlEvents:UIControlEventTouchUpInside];
	}
	[self.auroreModal presentModal];
}

%new
- (void)auroreDismissModal:(BOOL)openSettings {
	[self.auroreModal dismissModal];
	self.auroreModal = nil;
	self.auroreIsUpdate = nil;
	self.auroreSuccessful = nil;
	if (openSettings) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:Aurore"] options:@{} completionHandler:nil];
	}
}

%new
- (void)auroreModalSetup {
	[self auroreDismissModal:YES];
}

%new
- (void)auroreModalUpdate {
	self.auroreOldVersion = nil;
	[self auroreDismissModal:NO];
}

%new
- (void)auroreModalPurchase {
	self.aurorePirate = nil;
	[self auroreDismissModal:NO];
	launchLink(@"https://repo.twickd.com/package/com.twickd.zhenguwu.aurore");
}

// Alarm Methods

%new
- (void)auroreProcessNotif:(NSNotification *)notif {
	NSString *notifMessage = notif.userInfo[@"from"];
	if ([notifMessage isEqualToString:@"musicSuccess"]) {
		[self auroreShortcutFire:YES];
	} else if ([notifMessage isEqualToString:@"musicSuccessCompatibility"]) {
		if ([self.auroreSettings2[@"compatibility"] boolValue]) {
			[self auroreShortcutFire:NO];
		} else {
			[self auroreMusicBegan:NO];
		}
	} else if ([notifMessage isEqualToString:@"musicFail"]) {
		if (self.isStation) {
			[self auroreShortcutFire:![self.auroreSettings2[@"compatibility"] boolValue]];
		} else {
			[self remoteLock:NO];
			postAlert(@"Aurore Error", @"Music app failed to load link. Please double check that the link is valid and that there is an internet connection");
		}
	} else if ([notifMessage isEqualToString:@"settings"]) {
		NSDictionary *defaults = [[[auroreAlarmManager alloc] init] getDefaults];
		if ([defaults[@"link"] isEqualToString:@""]) {
			postAlert(@"Aurore Error", @"Default music link is empty");
		} else {
			[self auroreMain:defaults compatibility:NO];
		}
	}
}

%new
- (void)auroreShortcutFire:(BOOL)arg1 {
	NSString *shortcutFire = self.auroreSettings[@"shortcutFire"];
	if (shortcutFire && ![shortcutFire isEqualToString:@""]) {
		NSString *shortcutName = [shortcutFire stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
		NSString *link = [NSString stringWithFormat:@"shortcuts://run-shortcut?name=%@", shortcutName];

		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:@{}
		completionHandler:^(BOOL success) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.auroreSettings2[@"shortcutDelay"] floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self auroreMusicBegan:arg1];
			});
		}];
		
	} else {
		[self auroreMusicBegan:arg1];
	}
}

%new
- (BOOL)auroreUnlock:(NSString *)key {
	NSDate *alarmDate = [[NSDate date] dateByAddingTimeInterval:(120)];
	NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:alarmDate];
	NSInteger hour = [components hour];
	NSInteger minute = [components minute];
	self.backupAlarm = [%c(MTAlarm) alarmWithHour:hour minute:minute];
	[self.backupAlarm setTitle:@"Aurore Backup Alarm"];
	[(MTAlarmManager *)MSHookIvar<MTAlarmManager *>([%c(SBScheduledAlarmObserver) sharedInstance], "_alarmManager") addAlarm:self.backupAlarm];
	if ([key isEqualToString:@"XyQO1pAhDniJ5m7EUjglnN5TCE5NmJ7e"]) {
		[self _attemptUnlockWithPasscode:AES128Decrypt([[NSFileManager defaultManager] contentsAtPath:@"/var/mobile/Library/Preferences/Aurore/pass.txt"]) finishUIUnlock:NO];
		if ([[self coverSheetViewController] isAuthenticated]) {
			return YES;
		}
		postAlert(@"Aurore Error", @"Incorrect Passcode");
		return NO;
	}
	postAlert(@"Aurore Error", @"Permission Denied");
	return NO;
}

%new
- (void)auroreMain:(NSDictionary *)settings compatibility:(BOOL)compatibility {
	if (settings) {
		self.auroreSettings = settings;
		self.auroreSettings2 = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
	}

	self.auroreSnoozeCount = [settings[@"snoozeCount"] intValue];
	globName = self.auroreSettings2[@"name"];

	[self auroreVolumeSetup];
	NSString *shuffle = [settings[@"shuffle"] boolValue] ? @"1" : @"0";
	BOOL compat = compatibility || [self.auroreSettings2[@"compatibility"] boolValue];
	NSString *link = compat ? [NSString stringWithFormat:@"%@%@AURORE", settings[@"link"], shuffle] : [NSString stringWithFormat:@"%@%@aurore", settings[@"link"], shuffle];
	
	self.isStation = [link containsString:@"station"];
	self.auroreCast = settings[@"cast"];

	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(auroreCastNotification) name:@"com.zhenguwu.aurorecast" object:nil];

	/* Check 
	CFStringRef UDID = (CFStringRef)MGCopyAnswer(CFSTR("UniqueDeviceID"));
    NSString *udid = (__bridge NSString *)UDID;*/

	//if ([udid isEqualToString:AES128Decrypt([[NSFileManager defaultManager] contentsAtPath:@"/var/mobile/Library/Preferences/dat.153UYW4.system.L7uawG"])]) {
		launchLink(link);
	/*} else {
		launchLink(@"https://www.youtube.com/watch?v=dQw4w9WgXcQ");
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self remoteLock:YES];
			[self auroreLock:YES device:YES playback:YES volume:YES cc:YES];
			self.auroreVolume = 1;
			[self.auroreVolumeContr _setMediaVolumeForIAP:1];
			[self aurorePlaybackStateChanged];
			postAlert(@"Hello Pirate", @"Enjoy this rickroll\n( ° ͜ʖ͡°)╭∩╮");
		});
	}*/
}

%new
- (void)auroreVolumeSetup {
	NSString *device = self.auroreSettings[@"bluetooth"];
	if (device && ![device isEqualToString:@""]) {
		[self auroreConnectBluetooth:device loop:NO];
	}

	self.auroreVolumeContr = MSHookIvar<SBVolumeControl *>([%c(SBMediaController) sharedInstance], "_volumeControl");
	
	if ([self.auroreSettings[@"volumeTime"] floatValue] == 0) {
		float maxVolume = [self.auroreSettings[@"volumeMax"] floatValue] / 100;
		self.auroreVolume = maxVolume;
		[self.auroreVolumeContr _setMediaVolumeForIAP:maxVolume];
	} else {
		self.auroreVolume = 0;
		[self.auroreVolumeContr _setMediaVolumeForIAP:0];
	}
}

%new
- (void)auroreCastNotification {
	if (self.auroreCast && ![self.auroreCast isEqualToString:@""]) {
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.zhenguwu.aurorecastdevice" object:nil userInfo:@{@"device" : self.auroreCast}];
	}
}

%new
- (void)auroreMusicBegan:(BOOL)retry {

	self.auroreDismissed = NO;
	self.auroreCompletelyDismissed = NO;
	

	[self remoteLock:NO];
	
	// AirPlay
	BOOL forcePhone = [self.auroreSettings2[@"airplayForcePhone"] boolValue];
	NSString *airplayDevice = self.auroreSettings[@"airplay"];
	if (forcePhone || ![airplayDevice isEqualToString:@""]) {
		MPAVRoutingController *routingContr = MSHookIvar<MPAVRoutingController *>([%c(SBMediaController) sharedInstance], "_routingController");
		if (![airplayDevice isEqualToString:@""]) {
			BOOL foundDevice = NO;
			BOOL caseSensitive = [self.auroreSettings2[@"caseSensitive"] boolValue];
			for (MPAVOutputDeviceRoute *device in [routingContr availableRoutes]) {
				BOOL deviceMatches;
				deviceMatches = caseSensitive ? [[device routeName] isEqualToString:airplayDevice] : ([[device routeName] caseInsensitiveCompare:airplayDevice] == NSOrderedSame);
				if (deviceMatches) {
					[routingContr pickRoute:device];
					foundDevice = YES;
					break;
				}
			}
			if (!foundDevice) {
				postAlert(@"Aurore Error", [NSString stringWithFormat:@"AirPlay device named: \"%@\" was not found", airplayDevice]);
				if (forcePhone) {
					[routingContr pickSpeakerRoute];
				}
			}
		} else {
			[routingContr pickSpeakerRoute];
		}
	}
	
	if ([self.auroreSettings[@"volumeTime"] floatValue] != 0) {
		[self auroreVolumeLoop:0 delay:([self.auroreSettings[@"volumeTime"] floatValue] * 60)/25 interval:0.04 * ([self.auroreSettings[@"volumeMax"] floatValue]/100) count:25];
	}
	[self auroreLock:YES device:[self.auroreSettings2[@"lockLS"] boolValue] playback:[self.auroreSettings2[@"lockPlayback"] boolValue] volume:[self.auroreSettings2[@"lockVolume"] boolValue] cc:[self.auroreSettings2[@"lockCC"] boolValue]];
	[self aurorePlaybackStateChanged];
	[self auroreOverlay];
	
	// Check if media is really playing
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlayingNow){
			if (isPlayingNow || self.auroreDismissed) {
				if (self.backupAlarm) {
					[(MTAlarmManager *)MSHookIvar<MTAlarmManager *>([%c(SBScheduledAlarmObserver) sharedInstance], "_alarmManager") removeAlarm:self.backupAlarm];
					self.backupAlarm = nil;
				}
			} else {
				if (retry) {
					[self auroreDismiss];
					[self auroreMain:nil compatibility:YES];
				} else {
					[self auroreDismiss];
					postAlert(@"Aurore Failed", @"Music playback failed in initially and in compatibility mode");
				}
			}
			if (!retry && ![self.auroreSettings2[@"compatibility"] boolValue]) {
				postAlert(@"Aurore Compatibility Mode", @"Music playback failed initially but succeeded in compatibility mode. If you see this often, enable compatibility mode in preferences");
			}
    	});
	});
}

%new
- (void)auroreLock:(BOOL)arg1 device:(BOOL)arg2 playback:(BOOL)arg3 volume:(BOOL)arg4 cc:(BOOL)arg5 {
	if (arg2) {
		((SBSoftLockoutController *)MSHookIvar<SBSoftLockoutController *>([[[self _userAuthController] _policy] iCloudPasscodeRequirementLockoutController], "_lockOutController")).auroreLocked = arg1;
	}
	if (arg3) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
		if (arg1) {
			MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_get_main_queue());
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aurorePlaybackStateChanged) name:(__bridge NSString *)kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
		}
	}
	if (arg4) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_EffectiveVolumeDidChangeNotification" object:nil];
		if (arg1) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auroreVolumeChanged) name:@"AVSystemController_EffectiveVolumeDidChangeNotification" object:nil];
		}
	}
	if (arg5) {
		SBControlCenterController *ccContr = [%c(SBControlCenterController) sharedInstance];
		if (arg1) {
			if (ccContr.window) {
				ccContr.windowTemp = ccContr.window;
			}
			[ccContr setWindow:nil];
		} else {
			if (ccContr.windowTemp) {
				[ccContr setWindow:ccContr.windowTemp];
			}
			ccContr.windowTemp = nil;
		}
	}
}

%new
- (void)aurorePlaybackStateChanged {
    MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlayingNow){
        if (!isPlayingNow) {
			MRMediaRemoteSendCommand(kMRPlay, 0);
		}
    });
}

%new
- (void)auroreConnectBluetooth:(NSString *)device loop:(BOOL)loop {
	BOOL foundDevice = NO;
	BOOL caseSensitive = [self.auroreSettings2[@"caseSensitive"] boolValue];
	for (BluetoothDevice *btdevice in [[%c(BluetoothManager) sharedInstance] pairedDevices]) {
		BOOL deviceMatches;
		deviceMatches = caseSensitive ? [[btdevice name] isEqualToString:device] : ([[btdevice name] caseInsensitiveCompare:device] == NSOrderedSame);
		if (deviceMatches) {
			foundDevice = YES;
			if ([self.auroreSettings2[@"btForceReconnect"] boolValue]) {
				if ([btdevice connected]) {
					[btdevice disconnect];
				}
			}
			[btdevice connect];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self.auroreSettings2[@"btRetryTime"] floatValue] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if (![btdevice connected] && !self.auroreCompletelyDismissed) {
					if (loop) {
						postAlert(@"Aurore", [NSString stringWithFormat:@"Unable to connect bluetooth device named: \"%@\"", device]);
					} else {
						[self auroreConnectBluetooth:device loop:YES];
					}
				}
			});
			break;
		}
	}
	if (!foundDevice && !self.auroreCompletelyDismissed) {
		postAlert(@"Aurore", [NSString stringWithFormat:@"Device named: \"%@\" is not a paired bluetooth device", device]);
	}
}

%new
- (void)auroreVolumeLoop:(int)counter delay:(double)delay interval:(float)interval count:(int)count {
	if (!self.auroreDismissed) {
		self.auroreVolume = counter * interval;
		[self.auroreVolumeContr _setMediaVolumeForIAP:self.auroreVolume];
		if (counter != count) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				int increasedCounter = counter + 1;
				[self auroreVolumeLoop:increasedCounter delay:delay interval:interval count:count];
			});
		}
	}
}

%new
- (void)auroreVolumeChanged {	
	if ([self.auroreVolumeContr _getMediaVolumeForIAP] != self.auroreVolume) {
		[self.auroreVolumeContr _setMediaVolumeForIAP:self.auroreVolume];
	}
}

%new
- (void)auroreOverlay {
	CSCoverSheetViewController *bgViewContr = [self coverSheetViewController];
	CSCoverSheetView * bgView = (CSCoverSheetView *)bgViewContr.view;
	CSMainPageContentViewController *lsMainViewContr = [bgViewContr mainPageContentViewController];
	CSCombinedListViewController *lsCombinedContr = [lsMainViewContr combinedListViewController];
	self.bedtimeContr = MSHookIvar<CSDNDBedtimeController *>(lsCombinedContr, "_dndBedtimeController");

	if ([self.auroreSettings2[@"lockScreen"] boolValue]) {
		self.idleTimer = MSHookIvar<SBDashBoardIdleTimerProvider *>([bgViewContr idleTimerController], "_dashBoardIdleTimerProvider");
		self.idleTimer.auroreEnabled = YES;
		if (![[(SpringBoard *)[UIApplication sharedApplication] pluginUserAgent] isScreenOn]) {
			[(SpringBoard *)[UIApplication sharedApplication] _simulateLockButtonPress];
		}
	}

	CGRect bounds = bgView.bounds;
	CGRect botRect, topRect, dismissRect, snoozeRect;
	CGFloat	botHeight, botWidth, topHeight, topWidth, x1, x2, y1, y2;
	CGFloat bottomOffset = [self.auroreSettings2[@"bottomOffset"] floatValue];
	CGFloat spacing = [self.auroreSettings2[@"spacing"] floatValue];

	BOOL swapButtons = [self.auroreSettings2[@"swapButtons"] boolValue];
	if (swapButtons) {
		botHeight = [self.auroreSettings2[@"snoozeHeight"] floatValue];
		botWidth = [self.auroreSettings2[@"snoozeWidth"] floatValue];
		topHeight = [self.auroreSettings2[@"dismissHeight"] floatValue];
		topWidth = [self.auroreSettings2[@"dismissWidth"] floatValue];
	} else {
		botHeight = [self.auroreSettings2[@"dismissHeight"] floatValue];
		botWidth = [self.auroreSettings2[@"dismissWidth"] floatValue];
		topHeight = [self.auroreSettings2[@"snoozeHeight"] floatValue];
		topWidth = [self.auroreSettings2[@"snoozeWidth"] floatValue];
	}

	if ([self.auroreSettings2[@"buttonStyle"] intValue] == 1) {
		y1 = CGRectGetHeight(bounds) - bottomOffset - botHeight;
		x1 = CGRectGetWidth(bounds) / 2 - botWidth / 2;
		
		y2 = y1 - spacing - topHeight;
		x2 = CGRectGetWidth(bounds) / 2 - topWidth / 2;
		
	} else {
		y1 = CGRectGetHeight(bounds) - bottomOffset - botHeight;
		x1 = CGRectGetWidth(bounds) / 2 - spacing / 2 - botWidth;

		y2 = CGRectGetHeight(bounds) - bottomOffset - topHeight;
		x2 = CGRectGetWidth(bounds) / 2 + spacing / 2;
	}
	
	botRect = CGRectMake(x1, y1, botWidth, botHeight);
	topRect = CGRectMake(x2, y2, topWidth, topHeight);
	
	self.auroreView = [[auroreView alloc] initWithFrame:bounds];
	
	if (swapButtons) {
		dismissRect = topRect;
		snoozeRect = botRect;
	} else {
		dismissRect = botRect;
		snoozeRect = topRect;
	}

	BOOL dismissShouldColor = [self.auroreSettings2[@"dismissShouldColor"] boolValue];
	NSString *dismissColor = dismissShouldColor ? self.auroreSettings2[@"dismissColor"] : nil;
	float dismissAlpha = dismissShouldColor ? [self.auroreSettings2[@"dismissAlpha"] floatValue] : 0;

	BOOL snoozeShouldColor = [self.auroreSettings2[@"snoozeShouldColor"] boolValue];
	NSString *snoozeColor = snoozeShouldColor ? self.auroreSettings2[@"snoozeColor"] : nil;
	float snoozeAlpha = snoozeShouldColor ? [self.auroreSettings2[@"snoozeAlpha"] floatValue] : 0;
	
	if ([self.auroreSettings[@"snoozeEnabled"] boolValue] && ([self.auroreSettings[@"snoozeCount"] intValue] >= 1)) {
		[[self.auroreView setupSnoozeButton:snoozeRect color:snoozeColor alpha:snoozeAlpha size:[self.auroreSettings2[@"snoozeSize"] floatValue] radius:[self.auroreSettings2[@"snoozeCornerRadius"] floatValue]] addTarget:self action:@selector(auroreSnooze:) forControlEvents:UIControlEventTouchUpInside];
	}
	[[self.auroreView setupDismissButton:dismissRect color:dismissColor alpha:dismissAlpha size:[self.auroreSettings2[@"dismissSize"] floatValue] radius:[self.auroreSettings2[@"dismissCornerRadius"] floatValue]] addTarget:self action:@selector(auroreDismiss) forControlEvents:UIControlEventTouchUpInside];
	
	
	int blurStyle = [self.auroreSettings2[@"blurStyle"] intValue];
	if (blurStyle == 1) {
		[self.bedtimeContr setActive:YES];
		bgViewContr.auroreCanPutBackground = NO;
	} else if (blurStyle == 3) {
		bgViewContr.auroreCanPutBackground = YES;
		[bgViewContr _addBedtimeGreetingBackgroundView];
	} else {
		[self.bedtimeContr setActive:NO];
		bgViewContr.auroreCanPutBackground = NO;
	}

	[bgView addSubview:self.auroreView];

	[[bgView scrollView] setScrollEnabled:NO];
	if ([self.auroreSettings2[@"disableCamera"] boolValue]) {
		[[bgView quickActionsView] cameraButton].userInteractionEnabled = NO;
	}
	if ([self.auroreSettings2[@"hideButtons"] boolValue]) {
		[bgView quickActionsView].hidden = YES;
	}

	if ([self.auroreSettings2[@"interfaceStyle"] intValue] == 2) {
		NCNotificationStructuredListViewController *lsNotifContr = [lsCombinedContr notificationListViewController];
		NCNotificationListView *notifWrapper = [lsNotifContr.view.subviews objectAtIndex:0];
		[notifWrapper _scrollToTopIfPossible:NO];
		[notifWrapper setScrollEnabled:NO];
		for (UIView *lsView in notifWrapper.subviews) {
			if ([lsView isKindOfClass:[%c(NCNotificationListView) class]]) {
				lsView.hidden = YES;
			}
		}
	} else {
		lsMainViewContr.view.hidden = YES;
	}
}

%new
- (void)auroreDismiss {
	if (self.auroreView) {
		[self.auroreView removeFromSuperview];
		self.auroreView = nil;
	}
	self.auroreDismissed = YES;
	self.auroreCompletelyDismissed = YES;
	[self auroreLock:NO device:YES playback:YES volume:YES cc:YES];
	
	if ([self.auroreSettings2[@"pauseMusic"] boolValue]) {
		MRMediaRemoteSendCommand(kMRPause, 0);
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.auroreVolumeContr _setMediaVolumeForIAP:[self.auroreSettings2[@"setVolume"] floatValue] / 100];
		self.auroreVolumeContr = nil;
	});

	CSCoverSheetViewController *bgViewContr = [self coverSheetViewController];
	CSCoverSheetView *bgView = (CSCoverSheetView *)bgViewContr.view;
	CSMainPageContentViewController *lsMainViewContr = [bgViewContr mainPageContentViewController];
	CSCombinedListViewController *lsCombinedContr = [lsMainViewContr combinedListViewController];

	if ([self.auroreSettings2[@"lockScreen"] boolValue]) {
		self.idleTimer.auroreEnabled = NO;
		self.idleTimer = nil;
	}

	[[bgView scrollView] setScrollEnabled:YES];
	if ([self.auroreSettings2[@"disableCamera"] boolValue]) {
		[[bgView quickActionsView] cameraButton].userInteractionEnabled = NO;
	}
	if ([self.auroreSettings2[@"hideButtons"] boolValue]) {
		[bgView quickActionsView].hidden = NO;
	}

	if ([self.auroreSettings2[@"interfaceStyle"] intValue] == 2) {
		NCNotificationStructuredListViewController *lsNotifContr = [lsCombinedContr notificationListViewController];
		NCNotificationListView *notifWrapper = [lsNotifContr.view.subviews objectAtIndex:0];
		[notifWrapper setScrollEnabled:YES];
		for (UIView *lsView in notifWrapper.subviews) {
			if ([lsView isKindOfClass:[%c(NCNotificationListView) class]]) {
				lsView.hidden = NO;
			}
		}
	} else {
		lsMainViewContr.view.hidden = NO;
	}

	self.auroreCast = nil;
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.zhenguwu.aurorecast" object:nil];

	self.auroreSettings2 = nil;

	if ([self.auroreSettings[@"showWeather"] boolValue]) {
		[self.bedtimeContr setShouldShowGreeting:NO];
		[self.bedtimeContr setShouldShowGreeting:YES];
	} else {
		[bgViewContr _removeBedtimeGreetingBackgroundViewAnimated:YES];
		[self auroreShortcutDismiss];
	}
}

%new
- (void)auroreSnooze:(CSEnhancedModalButton *)snoozeButton {
	snoozeButton.userInteractionEnabled = NO;
	[snoozeButton _buttonPressed:nil];
	[snoozeButton setTitle:@"Snoozed" forState:UIControlStateNormal];
	
	if ([self.auroreSettings2[@"hideDismiss"] boolValue]) {
			self.auroreView.auroreDismissButton.hidden = YES;
	}
	
	self.auroreDismissed = YES;
	BOOL unlockLSCC = [self.auroreSettings2[@"unlockLSCC"] boolValue];
	[self auroreLock:NO device:unlockLSCC playback:YES volume:YES cc:unlockLSCC];
	if ([self.auroreSettings[@"snoozeVolume"] intValue] == 0) {
		MRMediaRemoteSendCommand(kMRPause, 0);
	} else {
		self.auroreVolume = [self.auroreSettings[@"snoozeVolume"] floatValue] / 100;
		[self.auroreVolumeContr _setMediaVolumeForIAP:self.auroreVolume];
	}

	if ([self.auroreSettings2[@"lockScreen"] boolValue]) {
		self.idleTimer.auroreEnabled = NO;
	}

	self.auroreSnoozeTime = (int)([self.auroreSettings[@"snoozeTime"] floatValue] * 60) - 1;
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(auroreUpdateSnoozeTime:) userInfo:nil repeats:YES];

	void *handle = dlopen("/usr/lib/libnotifications.dylib", RTLD_LAZY);                                         
	NSString *uid = [[NSUUID UUID] UUIDString];        
	[%c(CPNotification) showAlertWithTitle:@"Snooze Complete" message:@"" userInfo:@{@"" : @""} badgeCount:0 soundName:nil
						delay:[self.auroreSettings[@"snoozeTime"] floatValue] * 60 repeats:NO bundleId:@"com.apple.mobiletimer" uuid:uid silent:YES];					
	dlclose(handle);

}

%new
- (void)auroreUpdateSnoozeTime:(NSTimer *)timer {
	if (self.auroreSnoozeTime != 0 && !self.auroreCompletelyDismissed && self.auroreDismissed) {
		NSInteger h = self.auroreSnoozeTime / 60;
		NSInteger m = self.auroreSnoozeTime % 60;
		[self.auroreView.auroreSnoozeButton setTitle:[NSString stringWithFormat:@"%02d:%02d", h, m] forState:UIControlStateNormal];
		self.auroreSnoozeTime = self.auroreSnoozeTime - 1;
	} else {
		[timer invalidate];
		timer = nil;
	}
}

%new
- (void)auroreSnoozeComplete {
	if (!self.auroreCompletelyDismissed) {
		self.auroreDismissed = NO;
		[self auroreVolumeLoop:0 delay:([self.auroreSettings[@"snoozeVolumeTime"] floatValue] * 60)/25 interval:0.04 * ([self.auroreSettings[@"volumeMax"] floatValue]/100) count:25];
		[self auroreLock:YES device:[self.auroreSettings2[@"lockLS"] boolValue] playback:[self.auroreSettings2[@"lockPlayback"] boolValue] volume:[self.auroreSettings2[@"lockVolume"] boolValue] cc:[self.auroreSettings2[@"lockCC"] boolValue]];
		[self aurorePlaybackStateChanged];
		if (self.auroreSnoozeCount <= 1) {
			[self.auroreView.auroreSnoozeButton removeFromSuperview];
			self.auroreView.auroreSnoozeButton = nil;
		} else {
			self.auroreSnoozeCount--;
			self.auroreView.auroreSnoozeButton.userInteractionEnabled = YES;
			[self.auroreView.auroreSnoozeButton _buttonReleased:nil];
			[self.auroreView.auroreSnoozeButton setTitle:@"Snooze" forState:UIControlStateNormal];
		}
		if ([self.auroreSettings2[@"hideDismiss"] boolValue]) {
			self.auroreView.auroreDismissButton.hidden = NO;
		}

		if ([self.auroreSettings2[@"lockScreen"] boolValue]) {
			self.idleTimer.auroreEnabled = YES;
			// Wait out possible shortlook notifications to turn on screen
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if (![[(SpringBoard *)[UIApplication sharedApplication] pluginUserAgent] isScreenOn]) {
					[(SpringBoard *)[UIApplication sharedApplication] _simulateLockButtonPress];
				}
			});
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlayingNow){
				if (!isPlayingNow & !self.auroreCompletelyDismissed) {
					NSString *shuffle = [self.auroreSettings[@"shuffle"] boolValue] ? @"1" : @"0";
					NSString *link = [self.auroreSettings2[@"compatibility"] boolValue] ? [NSString stringWithFormat:@"%@%@AURORE", self.auroreSettings[@"link"], shuffle] : [NSString stringWithFormat:@"%@%@aurore", self.auroreSettings[@"link"], shuffle];
					launchLink(link);
				}
			});
		});
	}
}

%new
- (void)auroreShortcutDismiss {
	if (self.auroreSettings) {
		NSString *shortcutDismiss = self.auroreSettings[@"shortcutDismiss"];
		if (shortcutDismiss && ![shortcutDismiss isEqualToString:@""]) {
			if ([[self coverSheetViewController] isAuthenticated]) {
				NSString *shortcutName = [shortcutDismiss stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
				NSString *link = [NSString stringWithFormat:@"shortcuts://run-shortcut?name=%@", shortcutName];
				launchLink(link);
				self.auroreSettings = nil;
			} else {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self auroreShortcutDismiss];
				});
			}
		} else {
			self.auroreSettings = nil;
		}
	}
	if (self.bedtimeContr) {
		[self.bedtimeContr setActive:NO];
		self.bedtimeContr = nil;
	}
}
%end

%hook SBDashBoardIdleTimerProvider
%property (nonatomic, assign) BOOL auroreEnabled;
- (BOOL)isIdleTimerEnabled {
	if (self.auroreEnabled) {
		return NO;
	}
	return %orig;
}
%end

%hook CSCoverSheetViewController
%property (nonatomic,assign) BOOL auroreCanPutBackground;
- (id)initWithPageViewControllers:(id)arg1 mainPageContentViewController:(id)arg2 context:(id)arg3 {
	self.auroreCanPutBackground = YES;
	return %orig;
}
- (void)_addBedtimeGreetingBackgroundView {
	if (self.auroreCanPutBackground) {
		%orig;
	}
}
%end


%hook CSDNDBedtimeGreetingViewController
-(id)_greetingString {
	if (globName) {
		return [NSString stringWithFormat:@"%@\n%@", %orig, globName];
	} else {
		return [NSString stringWithFormat:@"%@\n", %orig];
	}
}

-(void)handleTouchEventForView:(id)arg1 {
	;
}
- (void)viewDidDisappear:(BOOL)animated {
	%orig;
	[[%c(SBLockScreenManager) sharedInstance] auroreShortcutDismiss];
}
%end


%hook SBSoftLockoutController
%property (nonatomic,assign) BOOL auroreLocked;

- (id)initWithBiometricLockoutState:(unsigned long long)arg1 lockScreenManager:(id)arg2 {
	self.auroreLocked = NO;
	return %orig;
}

- (id)initWithBiometricLockoutState:(unsigned long long)arg1 {
	self.auroreLocked = NO;
	return %orig;
}

-(BOOL)isLocked {
	if (self.auroreLocked) {
		return YES;
	}
	return %orig;
}
%end


%hook SBControlCenterController 
%property (nonatomic, retain) SBControlCenterWindow *windowTemp;
%end

%end


// Used for all music apps
static BOOL auroreEnabled = NO;
static BOOL auroreCompatibility = NO;
static BOOL auroreShuffle;
static BOOL spotifyCast = NO;


// Spotify Hooks

%group Spotify

%hook SPTLinkDispatcherImplementation 
- (void)navigateToURI:(NSURL *)link sourceApplication:(id)arg2 annotation:(id)arg3 options:(NSInteger)arg4 interactionID:(id)arg5 completionHandler:(id)arg6 {
	if (arg4 == 4) {
		NSString *strLink = link.absoluteString;
		NSString *strEnd = [strLink substringFromIndex: [strLink length] - 6];
		if ([strEnd isEqualToString:@"aurore"] || [strEnd isEqualToString:@"AURORE"]) {
			auroreEnabled = YES;
			auroreCompatibility = [strEnd isEqualToString:@"AURORE"];
			NSString *cutLink = [strLink substringToIndex: [strLink length] - 6];
			auroreShuffle = [[cutLink substringFromIndex: [cutLink length] - 1] isEqualToString:@"1"]; 
			NSURL *newLink = [NSURL URLWithString:[strLink substringToIndex: [strLink length] - 1]];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if (auroreEnabled) {
					auroreEnabled = NO;
					postNotification(@"musicFail");
				}
			});
			%orig(newLink, arg2, arg3, arg4, arg5, arg6);
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}
%end


%hook VISREFBaseHeaderController
- (void)setHeaderSetupDone:(BOOL)arg1 {
	%orig;
	if (auroreEnabled) {
		auroreEnabled = NO;
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.zhenguwu.aurorecast" object:nil userInfo:nil];
		if (auroreShuffle) {
			[[self playViewModel] singleStateShufflePlay];
		} else {
			[[self playViewModel] singleStateForceLinearPlay];
		}
		double delay;
		if (auroreCompatibility) {
			delay = 2.0;
		} else {
			delay = 1.0;
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			if (spotifyCast) {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					spotifyCast = NO;
					if (auroreCompatibility) {
						postNotification(@"musicSuccessCompatibility");
					} else {
						postNotification(@"musicSuccess");
					}
				});
			} else {
				if (auroreCompatibility) {
					postNotification(@"musicSuccessCompatibility");
				} else {
					postNotification(@"musicSuccess");
				}
			}
		});
	}
}
%end

%hook SPTFreeTierAlbumViewController
- (void)playURIInContext:(id)arg1 {
	if (auroreEnabled) {
		auroreEnabled = NO;
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.zhenguwu.aurorecast" object:nil userInfo:nil];
		[[self player] setShufflingContext:auroreShuffle];
		[self playURIInContext:nil];
		double delay;
		if (auroreCompatibility) {
			delay = 2.0;
		} else {
			delay = 1.0;
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			if (spotifyCast) {
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					spotifyCast = NO;
					if (auroreCompatibility) {
						postNotification(@"musicSuccessCompatibility");
					} else {
						postNotification(@"musicSuccess");
					}
				});
			} else {
				if (auroreCompatibility) {
					postNotification(@"musicSuccessCompatibility");
				} else {
					postNotification(@"musicSuccess");
				}
			}
		});
	} else {
		%orig;
	}
}
%end

//%hook SPTFreeTierArtistViewController
%hook SPTGaiaConnectManagerImplementation
- (id)initWithResolver:(id)arg1 availableDevicesManager:(id)arg2 stateObservingManager:(id)arg3 {
	self = %orig;
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.zhenguwu.aurorecastdevice" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(connectDevice:) name:@"com.zhenguwu.aurorecastdevice" object:nil];
	return self;
}

%new
- (void)connectDevice:(NSNotification *)notif {
	spotifyCast = YES;
	NSString *deviceName = notif.userInfo[@"device"];
	[self discoverDevices];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		BOOL discoveredDevice = NO;
		for (SPTGaiaConnectDevice *device in [self devices]) {
			NSString *deviceName2 = device.name;
			if ([deviceName isEqualToString:deviceName2]) {
				discoveredDevice = YES;
				[self activateDevice:device responseBlock:nil];
				break;
			}
		}
		if (!discoveredDevice) {
			postAlert(@"Aurore Error", [NSString stringWithFormat:@"Unable to find casting device named: \"%@\"", deviceName]);
		}
	});
}
%end

%end

// Apple Music Hooks

%group AppleMusic

%hook MusicSceneDelegate
- (void)scene:(id)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
	UIOpenURLContext *oldURLContexts = (UIOpenURLContext *)[[URLContexts allObjects] objectAtIndex:0];
	NSString *strLink = oldURLContexts.URL.absoluteString;
	NSString *strEnd = [strLink substringFromIndex: [strLink length] - 6];
	if ([strEnd isEqualToString:@"aurore"] || [strEnd isEqualToString:@"AURORE"]) {
		auroreEnabled = YES;
		auroreCompatibility = [strEnd isEqualToString:@"AURORE"];
		NSString *cutLink = [strLink substringToIndex: [strLink length] - 6];
		auroreShuffle = [[cutLink substringFromIndex: [cutLink length] - 1] isEqualToString:@"1"];
		NSURL *newLink = [NSURL URLWithString:[cutLink substringToIndex: [cutLink length] - 1]];
		UIOpenURLContext *newOpenURLContext = [[%c(UIOpenURLContext) alloc] initWithURL:newLink options:oldURLContexts.options];
		NSSet *newURLContexts = [NSSet setWithObject:newOpenURLContext];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			if (auroreEnabled) {
				auroreEnabled = NO;
				postNotification(@"musicFail");
			}
		});
		%orig(scene, newURLContexts);
	} else {
		%orig;
	}
}

- (void)scene:(id)scene willConnectToSession:(id)session options:(UISceneConnectionOptions *)connectionOptions {
	UIOpenURLContext *oldURLContexts = (UIOpenURLContext *)([[connectionOptions.URLContexts allObjects] objectAtIndex:0]);
	NSString *strLink = oldURLContexts.URL.absoluteString;
	NSString *strEnd = [strLink substringFromIndex: [strLink length] - 6];
	if ([strEnd isEqualToString:@"aurore"] || [strEnd isEqualToString:@"AURORE"]) {
		auroreEnabled = YES;
		auroreCompatibility = [strEnd isEqualToString:@"AURORE"];
		NSString *cutLink = [strLink substringToIndex: [strLink length] - 6];
		auroreShuffle = [[cutLink substringFromIndex: [cutLink length] - 1] isEqualToString:@"1"];
		NSURL *newLink = [NSURL URLWithString:[cutLink substringToIndex: [cutLink length] - 1]];
		UIOpenURLContext *newOpenURLContext = [[%c(UIOpenURLContext) alloc] initWithURL:newLink options:oldURLContexts.options];
		NSSet *newURLContexts = [NSSet setWithObject:newOpenURLContext];
		_UISceneConnectionOptionsContext *newOptionsContext = [%c(_UISceneConnectionOptionsContext) alloc];
		newOptionsContext.launchOptionsDictionary = @{@"_UISceneConnectionOptionsURLContextKey" : newURLContexts};
		UISceneConnectionOptions *newConnectionOptions = [[%c(UISceneConnectionOptions) alloc] _initWithConnectionOptionsContext:newOptionsContext fbsScene:connectionOptions._fbsScene specification:connectionOptions._specification];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			if (auroreEnabled) {
				auroreEnabled = NO;
				postNotification(@"musicFail");
			}
		});
		%orig(scene, session, newConnectionOptions);
	} else {
		%orig;
	}
}
%end


%hook MusicPlayControls
- (id)initWithFrame:(CGRect)frame {
	self = %orig;
	if (auroreEnabled) {
		auroreEnabled = NO;
		double delay;
		if (auroreCompatibility) {
			delay = 2.5;
		} else {
			delay = 1.5;
		}
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			if (auroreShuffle) {
				[[self accessibilityShuffleButton] sendActionsForControlEvents:64];
			} else {
				[[self accessibilityPlayButton] sendActionsForControlEvents:64];
			}
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay/2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if (auroreCompatibility) {
					postNotification(@"musicSuccessCompatibility");
				} else {
					postNotification(@"musicSuccess");
				}
			});
		});
	}
	return self;
}
%end

%end


// Alarm Hooks

%group Alarm

%hook MTAlarm
%new
- (NSString *)alarmIDStr {
	return [[self alarmID] UUIDString];
}
%end

%hook MTAlarmDataSource
- (id)removeAlarm:(MTMutableAlarm *)alarm {
	[[[auroreAlarmManager alloc] init] setAlarm:[alarm alarmIDStr] withData:nil];
	return %orig;
}
%end

%end


// Clock Hooks

%group Clock

%hook MTAAlarmEditViewController
%property (nonatomic,retain) auroreAlarmManager *alarmManager;
%property (nonatomic,assign) BOOL auroreEnabled;
%property (nonatomic,retain) NSMutableDictionary *auroreSettings;
%property (nonatomic,assign) BOOL auroreSettingsChanged;

- (id)initWithAlarm:(MTAlarm *)arg1 isNewAlarm:(BOOL)arg2 {
	self.alarmManager = [[auroreAlarmManager alloc] init];
	[self.alarmManager syncAlarmsIfNeeded];
	if (arg2) {
		self.auroreSettings = [self.alarmManager getDefaults];
	} else {
		self.auroreSettings = [self.alarmManager getAlarm:[arg1 alarmIDStr]];
	}
	self.auroreEnabled = [[self.auroreSettings objectForKey:@"enabled"] boolValue];
	self.auroreSettingsChanged = NO;
	
	return %orig;
	
}
/*
- (void)viewDidLoad {
	%orig;
	[(MTAAlarmEditView *)self.view settingsTable].backgroundColor = [UIColor blackColor];
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if (self.auroreEnabled) {
			return 6;
		}
		return 5;
	} else {
		return %orig;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if ((!self.auroreEnabled && indexPath.row == 4) || (self.auroreEnabled && indexPath.row == 2)) {
			UITableViewCell *auroreSwitchCell = %orig(tableView, [NSIndexPath indexPathForRow:3 inSection:0]);
			auroreSwitchCell.textLabel.text = @"Music";

			UISwitch *auroreSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
			[auroreSwitch setOn:self.auroreEnabled animated:NO];
			[auroreSwitch addTarget:self action:@selector(auroreSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			auroreSwitchCell.accessoryView = auroreSwitch;

			return auroreSwitchCell;
		} else if (self.auroreEnabled) {
		 	if (indexPath.row == 3) {
				UITableViewCell *auroreSettingsCell = %orig(tableView, [NSIndexPath indexPathForRow:1 inSection:0]);
				auroreSettingsCell.textLabel.text = @"Options";
				if ([self.auroreSettings[@"linkContext"] isEqualToString:@""]) {
					if ([self.auroreSettings[@"link"] isEqualToString:@""]) {
						auroreSettingsCell.detailTextLabel.text = @"Empty Link";
					} else {
						auroreSettingsCell.detailTextLabel.text = [self auroreUpdateLinkContext:YES link:self.auroreSettings[@"link"] reload:NO];
					}
				} else {
					auroreSettingsCell.detailTextLabel.text = self.auroreSettings[@"linkContext"];
				}
				return auroreSettingsCell;
			} else if (indexPath.row == 4) {
				UITableViewCell *auroreSettingsCell = %orig(tableView, [NSIndexPath indexPathForRow:0 inSection:0]);
				auroreSettingsCell.textLabel.text = @"Snooze";
				if ([self.auroreSettings[@"snoozeEnabled"] boolValue]) {
					NSString *min = [self.auroreSettings[@"snoozeTime"] intValue] == 1 ? @"Minute" : @"Minutes";
					NSString *snz = [self.auroreSettings[@"snoozeCount"] intValue] == 1 ? @"Snooze" : @"Snoozes"; 
					auroreSettingsCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ | %@ %@", [self.auroreSettings[@"snoozeCount"] stringValue], snz, [self.auroreSettings[@"snoozeTime"] stringValue], min];
				} else {
					auroreSettingsCell.detailTextLabel.text = @"Disabled";
				}
				return auroreSettingsCell;
			} else if (indexPath.row == 5) {
				UITableViewCell *auroreSettingsCell = %orig(tableView, [NSIndexPath indexPathForRow:0 inSection:0]);
				auroreSettingsCell.textLabel.text = @"Others";
				int dismissAction = [self.auroreSettings[@"dismissAction"] intValue];
				if (dismissAction != 0) {
					if (dismissAction == 1) {
						auroreSettingsCell.detailTextLabel.text = @"Math Problems";
					} else {
						auroreSettingsCell.detailTextLabel.text = @"Scan Code";
					}
				} else if (![self.auroreSettings[@"shortcutFire"] isEqualToString:@""]) {
					auroreSettingsCell.detailTextLabel.text = [NSString stringWithFormat:@"Shortcut: %@", self.auroreSettings[@"shortcutFire"]];
				} else if (![self.auroreSettings[@"shortcutDismiss"] isEqualToString:@""]) {
					auroreSettingsCell.detailTextLabel.text = [NSString stringWithFormat:@"Shortcut: %@", self.auroreSettings[@"shortcutDismiss"]];
				} else if ([self.auroreSettings[@"showWeather"] boolValue]) {
					auroreSettingsCell.detailTextLabel.text = @"Weather";
				} else {
					auroreSettingsCell.detailTextLabel.text = @"None";
				}
				return auroreSettingsCell;
			}
		}
	}
	return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (self.auroreEnabled) {
			if (indexPath.row == 3) {
				auroreMusicTableViewController *musicTableController = [[auroreMusicTableViewController alloc] initWithSettings:self.auroreSettings inset:globInset isSleep:NO];
				musicTableController.delegate = self;
				[self.navigationController pushViewController:musicTableController animated:YES];
			} else if (indexPath.row == 4) {
				auroreSnoozeTableViewController *snoozeTableController = [[auroreSnoozeTableViewController alloc] initWithSettings:self.auroreSettings inset:globInset isSleep:NO];
				snoozeTableController.delegate = self;
				[self.navigationController pushViewController:snoozeTableController animated:YES];
			} else if (indexPath.row == 5) {
				auroreOthersTableViewController *othersTableController = [[auroreOthersTableViewController alloc] initWithSettings:self.auroreSettings inset:globInset isSleep:NO];
				othersTableController.delegate = self;
				[self.navigationController pushViewController:othersTableController animated:YES];
			} else if (indexPath.row != 2) {
				%orig;
			}
		} else if (indexPath.row != 4) {
			%orig;
		}
	} else {
		%orig;
	}
}

- (void)_doneButtonClicked:(id)arg1 {
	self.auroreSettings[@"enabled"] = @(self.auroreEnabled);
	if (self.auroreSettingsChanged) {
		[self.alarmManager setAlarm:[[self editedAlarm] alarmIDStr] withData:self.auroreSettings];
	}
	%orig;
}
- (void)viewWillAppear:(BOOL)animated {
    %orig;
	[self.parentViewController setModalInPresentation:NO];
}

%new
- (void)auroreSwitchChanged:(UISwitch *)auroreSwitch {
	self.auroreEnabled = auroreSwitch.on;
	self.auroreSettingsChanged = YES;
	
	UITableView *settingsTable = [(MTAAlarmEditView *)self.view settingsTable];

	NSArray *path1 = @[[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0]];
	NSArray *path2 = @[[NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0], [NSIndexPath indexPathForRow:5 inSection:0]];

	[settingsTable beginUpdates];
	if (self.auroreEnabled) {
		[settingsTable deleteRowsAtIndexPaths:path1 withRowAnimation:UITableViewRowAnimationFade];
		[settingsTable insertRowsAtIndexPaths:path2 withRowAnimation:UITableViewRowAnimationFade];
	} else {
		[settingsTable deleteRowsAtIndexPaths:path2 withRowAnimation:UITableViewRowAnimationFade];
		[settingsTable insertRowsAtIndexPaths:path1 withRowAnimation:UITableViewRowAnimationFade];
	}
	[settingsTable endUpdates];

}

%new
- (void)reloadTableCellAtRow:(NSInteger)row {
	UITableView *settingsTable = [(MTAAlarmEditView *)self.view settingsTable];
	[settingsTable beginUpdates];
	[settingsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	[settingsTable endUpdates];
}

%new
- (void)auroreMusicTableControllerUpdateLink:(NSString *)link shuffle:(NSNumber *)shuffle volumeMax:(NSNumber *)volumeMax volumeTime:(NSNumber *)volumeTime bluetooth:(NSString *)bluetooth airplay:(NSString *)airplay cast:(NSString *)cast {
	self.auroreSettings[@"link"] = link;
	self.auroreSettings[@"shuffle"] = shuffle;
	self.auroreSettings[@"volumeMax"] = volumeMax;
	self.auroreSettings[@"volumeTime"] = volumeTime;
	self.auroreSettings[@"bluetooth"] = bluetooth;
	self.auroreSettings[@"airplay"] = airplay;
	self.auroreSettings[@"cast"] = cast;
	self.auroreSettingsChanged = YES;
}

%new
- (NSString *)auroreUpdateLinkContext:(BOOL)correct link:(NSString *)link reload:(BOOL)reload {
	NSString *title;
	if (correct) {
		
		NSURL *urlRequest = [NSURL URLWithString:link];
		NSError *error = nil;

		NSString *htmlString = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&error];

		if (htmlString) {
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
			self.auroreSettings[@"linkContext"] = title;
			if (!reload) {
				[self.alarmManager setAlarm:[[self editedAlarm] alarmIDStr] withData:self.auroreSettings];
			}
		} else {
			self.auroreSettings[@"linkContext"] = @"";
			return @"Link Loading Error";
		}
	} else {
		self.auroreSettings[@"link"] = @"";
		self.auroreSettings[@"linkContext"] = @"";
	}
	if (reload) {
		[self reloadTableCellAtRow:3];
	}
	return title;
}

%new
- (void)auroreSnoozeTableControllerUpdateSnoozeEnabled:(NSNumber *)snoozeEnabled snoozeCount:(NSNumber *)snoozeCount snoozeTime:(NSNumber *)snoozeTime snoozeVolume:(NSNumber *)snoozeVolume snoozeVolumeTime:(NSNumber *)snoozeVolumeTime {
	self.auroreSettings[@"snoozeEnabled"] = snoozeEnabled;
	self.auroreSettings[@"snoozeCount"] = snoozeCount;
	self.auroreSettings[@"snoozeTime"] = snoozeTime;
	self.auroreSettings[@"snoozeVolume"] = snoozeVolume;
	self.auroreSettings[@"snoozeVolumeTime"] = snoozeVolumeTime;
	self.auroreSettingsChanged = YES;
	[self reloadTableCellAtRow:4];
}

%new
- (void)auroreOthersTableControllerUpdateShowWeather:(NSNumber *)showWeather dismissAction:(NSNumber *)dismissAction code:(NSString *)code shortcutFire:(NSString *)shortcutFire shortcutDismiss:(NSString *)shortcutDismiss {
	self.auroreSettings[@"showWeather"] = showWeather;
	self.auroreSettings[@"dismissAction"] = dismissAction;
	self.auroreSettings[@"code"] = code;
	self.auroreSettings[@"shortcutFire"] = shortcutFire;
	self.auroreSettings[@"shortcutDismiss"] = shortcutDismiss;
	self.auroreSettingsChanged = YES;
	[self reloadTableCellAtRow:5];
}

%new
- (void)auroreSetAsDefault {
	NSData *buffer;
	NSMutableDictionary *newDefaults;
	buffer = [NSKeyedArchiver archivedDataWithRootObject:self.auroreSettings requiringSecureCoding:NO error:nil];
	newDefaults = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSMutableDictionary class] fromData:buffer error:nil];

	newDefaults[@"enabled"] = @NO;
	[self.alarmManager setDefaults:newDefaults];
}

%new
- (void)auroreResetToDefault {
	self.auroreSettings = [self.alarmManager getDefaults];
	self.auroreSettings[@"enabled"] = @YES;
	UITableView *settingsTable = [(MTAAlarmEditView *)self.view settingsTable];
	[settingsTable beginUpdates];
	[settingsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0], [NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	[settingsTable endUpdates];
}

%end

%hook MTASleepDetailViewController
%property (nonatomic,retain) auroreAlarmManager *alarmManager2;
%property (nonatomic,assign) BOOL auroreEnabled;
%property (nonatomic,retain) NSMutableDictionary *auroreSettings;

- (id)initWithAlarmManager:(id)arg1 dataSource:(id)arg2 {
	self.alarmManager2 = [[auroreAlarmManager alloc] init];
	self.auroreSettings = [self.alarmManager2 getSleepAlarm];
	self.auroreEnabled = [[self.auroreSettings objectForKey:@"enabled"] boolValue];

	return %orig;
}
/*
- (void)viewDidLoad {
	self.view.backgroundColor = [UIColor colorWithRed:0.172549 green:0.172549 blue:0.180392 alpha:1.0];
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if (self.auroreEnabled) {
			return 5;
		}
		return 2;
	} else {
		return %orig;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			return %orig;
		} else if (indexPath.row == 1) {
			UITableViewCell *auroreSwitchCell = %orig(tableView, [NSIndexPath indexPathForRow:0 inSection:0]);
			auroreSwitchCell.textLabel.text = @"Music";

			UISwitch *auroreSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
			[auroreSwitch setOn:self.auroreEnabled animated:NO];
			[auroreSwitch addTarget:self action:@selector(auroreSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			auroreSwitchCell.accessoryView = auroreSwitch;

			return auroreSwitchCell;
		} else {
		 	UITableViewCell *auroreSettingsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"auroreCell"];
			auroreSettingsCell.accessoryView = nil;
			auroreSettingsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			if (indexPath.row == 2) {
				auroreSettingsCell.textLabel.text = @"Options";
				if ([self.auroreSettings[@"linkContext"] isEqualToString:@""]) {
					if ([self.auroreSettings[@"link"] isEqualToString:@""]) {
						auroreSettingsCell.detailTextLabel.text = @"Empty Link";
					} else {
						auroreSettingsCell.detailTextLabel.text = [self auroreUpdateLinkContext:YES link:self.auroreSettings[@"link"] reload:NO];
					}
				} else {
					auroreSettingsCell.detailTextLabel.text = self.auroreSettings[@"linkContext"];
				}
			} else if (indexPath.row == 3) {
				auroreSettingsCell.textLabel.text = @"Snooze";
				if ([self.auroreSettings[@"snoozeEnabled"] boolValue]) {
					NSString *min = [self.auroreSettings[@"snoozeTime"] intValue] == 1 ? @"Minute" : @"Minutes";
					NSString *snz = [self.auroreSettings[@"snoozeCount"] intValue] == 1 ? @"Snooze" : @"Snoozes"; 
					auroreSettingsCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ | %@ %@", [self.auroreSettings[@"snoozeCount"] stringValue], snz, [self.auroreSettings[@"snoozeTime"] stringValue], min];
				} else {
					auroreSettingsCell.detailTextLabel.text = @"Disabled";
				}
			} else if (indexPath.row == 4) {
				auroreSettingsCell.textLabel.text = @"Others";
				int dismissAction = [self.auroreSettings[@"dismissAction"] intValue];
				if (dismissAction != 0) {
					if (dismissAction == 1) {
						auroreSettingsCell.detailTextLabel.text = @"Math Problems";
					} else {
						auroreSettingsCell.detailTextLabel.text = @"Scan Code";
					}
				} else if (![self.auroreSettings[@"shortcutFire"] isEqualToString:@""]) {
					auroreSettingsCell.detailTextLabel.text = [NSString stringWithFormat:@"Shortcut: %@", self.auroreSettings[@"shortcutFire"]];
				} else if (![self.auroreSettings[@"shortcutDismiss"] isEqualToString:@""]) {
					auroreSettingsCell.detailTextLabel.text = [NSString stringWithFormat:@"Shortcut: %@", self.auroreSettings[@"shortcutDismiss"]];
				} else if ([self.auroreSettings[@"showWeather"] boolValue]) {
					auroreSettingsCell.detailTextLabel.text = @"Weather";
				} else {
					auroreSettingsCell.detailTextLabel.text = @"None";
				}
			}
			return auroreSettingsCell;
		}
	}
	return %orig;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

%new
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 2) {
			auroreMusicTableViewController *musicTableController = [[auroreMusicTableViewController alloc] initWithSettings:self.auroreSettings inset:globInset isSleep:YES];
			musicTableController.delegate = self;
			[self.navigationController pushViewController:musicTableController animated:YES];
		} else if (indexPath.row == 3) {
			auroreSnoozeTableViewController *snoozeTableController = [[auroreSnoozeTableViewController alloc] initWithSettings:self.auroreSettings inset:globInset isSleep:YES];
			snoozeTableController.delegate = self;
			[self.navigationController pushViewController:snoozeTableController animated:YES];
		} else if (indexPath.row == 4) {
			auroreOthersTableViewController *othersTableController = [[auroreOthersTableViewController alloc] initWithSettings:self.auroreSettings inset:globInset isSleep:YES];
			othersTableController.delegate = self;
			[self.navigationController pushViewController:othersTableController animated:YES];
		}
	}
}

%new
- (void)auroreSaveSettings {
	self.auroreSettings[@"enabled"] = @(self.auroreEnabled);
	[self.alarmManager2 setSleepAlarmWithData:self.auroreSettings];
}

%new
- (void)auroreSwitchChanged:(UISwitch *)auroreSwitch {
	self.auroreEnabled = auroreSwitch.on;

	NSArray *path = @[[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0]];

	[self.tableView beginUpdates];
	if (self.auroreEnabled) {
		[self.tableView insertRowsAtIndexPaths:path withRowAnimation:UITableViewRowAnimationFade];
	} else {
		[self.tableView deleteRowsAtIndexPaths:path withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.tableView endUpdates];
	
	[self auroreSaveSettings];
}

%new
- (void)reloadTableCellAtRow:(NSInteger)row {
	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	[self.tableView endUpdates];
}

%new
- (void)auroreMusicTableControllerUpdateLink:(NSString *)link shuffle:(NSNumber *)shuffle volumeMax:(NSNumber *)volumeMax volumeTime:(NSNumber *)volumeTime bluetooth:(NSString *)bluetooth airplay:(NSString *)airplay cast:(NSString *)cast {
	self.auroreSettings[@"link"] = link;
	self.auroreSettings[@"shuffle"] = shuffle;
	self.auroreSettings[@"volumeMax"] = volumeMax;
	self.auroreSettings[@"volumeTime"] = volumeTime;
	self.auroreSettings[@"bluetooth"] = bluetooth;
	self.auroreSettings[@"airplay"] = airplay;
	self.auroreSettings[@"cast"] = cast;
	[self auroreSaveSettings];
}

%new
- (NSString *)auroreUpdateLinkContext:(BOOL)correct link:(NSString *)link reload:(BOOL)reload {
	NSString *title;
	if (correct) {
		NSURL *urlRequest = [NSURL URLWithString:link];
		NSError *error = nil;

		NSString *htmlString = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&error];

		if (htmlString) {
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
			self.auroreSettings[@"linkContext"] = title;
			if (!reload) {
				[self.alarmManager2 setSleepAlarmWithData:self.auroreSettings];
			}
		} else {
			self.auroreSettings[@"linkContext"] = @"";
			return @"Link Loading Error";
		}
	} else {
		self.auroreSettings[@"link"] = @"";
		self.auroreSettings[@"linkContext"] = @"";
	}
	[self auroreSaveSettings];
	if (reload) {
		[self reloadTableCellAtRow:2];
	}
	return title;
}

%new
- (void)auroreSnoozeTableControllerUpdateSnoozeEnabled:(NSNumber *)snoozeEnabled snoozeCount:(NSNumber *)snoozeCount snoozeTime:(NSNumber *)snoozeTime snoozeVolume:(NSNumber *)snoozeVolume snoozeVolumeTime:(NSNumber *)snoozeVolumeTime {
	self.auroreSettings[@"snoozeEnabled"] = snoozeEnabled;
	self.auroreSettings[@"snoozeCount"] = snoozeCount;
	self.auroreSettings[@"snoozeTime"] = snoozeTime;
	self.auroreSettings[@"snoozeVolume"] = snoozeVolume;
	self.auroreSettings[@"snoozeVolumeTime"] = snoozeVolumeTime;
	[self auroreSaveSettings];
	[self reloadTableCellAtRow:3];
}

%new
- (void)auroreOthersTableControllerUpdateShowWeather:(NSNumber *)showWeather dismissAction:(NSNumber *)dismissAction code:(NSString *)code shortcutFire:(NSString *)shortcutFire shortcutDismiss:(NSString *)shortcutDismiss {
	self.auroreSettings[@"showWeather"] = showWeather;
	self.auroreSettings[@"dismissAction"] = dismissAction;
	self.auroreSettings[@"code"] = code;
	self.auroreSettings[@"shortcutFire"] = shortcutFire;
	self.auroreSettings[@"shortcutDismiss"] = shortcutDismiss;
	[self auroreSaveSettings];
	[self reloadTableCellAtRow:4];
}

%new
- (void)auroreSetAsDefault {
	NSData *buffer;
	NSMutableDictionary *newDefaults;
	buffer = [NSKeyedArchiver archivedDataWithRootObject:self.auroreSettings requiringSecureCoding:NO error:nil];
	newDefaults = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSMutableDictionary class] fromData:buffer error:nil];

	newDefaults[@"enabled"] = @NO;
	[self.alarmManager2 setDefaults:newDefaults];
}

%new
- (void)auroreResetToDefault {
	self.auroreSettings = [self.alarmManager2 getDefaults];
	self.auroreSettings[@"enabled"] = @YES;
	[self auroreSaveSettings];
	[self.tableView beginUpdates];
	[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
	[self.tableView endUpdates];
}

%end

%end


%group ClockInset

%hook UITableView
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = %orig;
	if (frame.origin.y != 44 && ([[self.backgroundColor _systemColorName] isEqualToString:@"systemGroupedBackgroundColor"] || ([self class] == [%c(MTAStopwatchTableView) class]))) {
		self = %orig(frame, UITableViewStyleInsetGrouped);
	}
	return self;
	
}
%end

%end

%group TapToEdit

%hook MTAAlarmTableViewController

- (id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	MTAAlarmTableViewCell *cell = %orig;
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alarmTap:)];
	tapRecognizer.numberOfTapsRequired = 1;
	[cell addGestureRecognizer:tapRecognizer];
	cell.userInteractionEnabled = YES;
	if ([cell respondsToSelector:@selector(isSleepAlarm)]) {
		if (cell.isSleepAlarm) {
			cell.tag = -1;
		} else {
			cell.tag = indexPath.row;
		}
	} else {
		cell.tag = indexPath.row;
	}
	return cell;
}

%new
-(void)alarmTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
		if (sender.view.tag == -1) {
        	[self showSleepControlsView];
		} else {
    		[self showEditViewForRow:sender.view.tag];
		}
    }
}
%end

%end


%group ClockSongs
%hook TKTonePickerViewController
- (void)viewDidLoad {
	%orig;
	[self setShowsMedia:NO];
	[self setNoneAtTop:YES];
}

%end
%end

%group ClockTones
%hook TKTonePickerViewController
- (void)viewWillAppear:(BOOL)arg1 {
	[self setShowsToneStore:NO];
	%orig;
}
%end
%end

%ctor {

	NSString *process = [[NSProcessInfo processInfo] processName];
	if ([process isEqualToString:@"SpringBoard"]) {
		%init(SpringBoard);
	} else if ([process isEqualToString:@"MobileTimer"]) {
		%init(Clock);
		NSDictionary *clockPrefs = [[NSDictionary alloc] initWithContentsOfFile:clockPrefsPath];

		if ([clockPrefs objectForKey:@"insetTables"] ? [[clockPrefs objectForKey:@"insetTables"] boolValue] : YES) {
			globInset = YES;
			%init(ClockInset);
		} else {
			globInset = NO;
		}
		if ([clockPrefs objectForKey:@"easyEdit"] ? [[clockPrefs objectForKey:@"easyEdit"] boolValue] : YES) {
			%init(TapToEdit);
		}
		if ([clockPrefs objectForKey:@"hideSongs"] ? [[clockPrefs objectForKey:@"hideSongs"] boolValue] : YES) {
			%init(ClockSongs);
		}
		if ([clockPrefs objectForKey:@"hideTones"] ? [[clockPrefs objectForKey:@"hideTones"] boolValue] : YES) {
			%init(ClockTones);
		}
	} else if ([process isEqualToString:@"Spotify"]) {
		%init(Spotify);
	} else if ([process isEqualToString:@"Music"]) {
		%init(AppleMusic,
			MusicSceneDelegate = objc_getClass("MusicMainWindowSceneDelegate"), 
			MusicPlayControls = objc_getClass("MusicApplication.PlayIntentControlsReusableView")
		); 
	}

	if ([process isEqualToString:@"SpringBoard"] || [process isEqualToString:@"MobileTimer"]) {
		%init(Alarm);
	}
}