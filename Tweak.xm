#import <spawn.h>
#import <dlfcn.h>
#import <RemoteLog3.h>
#import <Cephei/HBPreferences.h>
#import "tools/constants.h"
#import "tools/helpers.h"
#import "tools/MediaRemote.h"
#import "tools/crypto.h"
#import "interfaces.h"
#import "views/auroreModal.h"
#import "tools/auroreAlarmManager.h"
#import "views/auroreView.h"
#import "scanner/auroreScanner.h"
#import "clockviewcontrollers/auroreMusicTableViewController.h"
#import "clockviewcontrollers/auroreSnoozeTableViewController.h"


%group SpringBoard

%hook NCNotificationDispatcher
-(BOOL)_shouldPostNotificationRequest:(NCNotificationRequest *)req {
	if ([[req sectionIdentifier] isEqualToString:@"com.apple.mobiletimer"]) {
		RLog(@"%@", req);
		NSDictionary *settings = [self auroreAlarmCheck:[req notificationIdentifier]];
		if (settings) {
			if ([[%c(SBLockScreenManager) sharedInstance] auroreUnlock:@"XyQO1pAhDniJ5m7EUjglnN5TCE5NmJ7e"]) {
				[[%c(SBLockScreenManager) sharedInstance] auroreMain:settings];
				return NO;
			}
		} else if ([[[req content] title] isEqualToString:@"Aurore Snooze"]) {
			[[%c(SBLockScreenManager) sharedInstance] auroreSnoozeComplete];
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
%property (nonatomic,retain) auroreView *auroreView;
%property (nonatomic,assign) BOOL auroreDismissed;
%property (nonatomic,retain) SBVolumeControl *auroreVolumeContr;
%property (nonatomic,retain) CSEnhancedModalButton *snoozeButton;
%property (nonatomic,assign) float auroreVolume;
%property (nonatomic,assign) int auroreSnoozeCount;

- (id)init {
	id org = %orig;
	self.auroreDismissed = YES;

	NSString *versionPath = @"/var/mobile/Library/Preferences/Aurore/version.txt";
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:versionPath]) {
		NSString *versionInstalled = [NSString stringWithContentsOfFile:versionPath encoding:NSUTF8StringEncoding error:nil];
		if (![versionInstalled isEqualToString:auroreVersion]) {
			;
			// For future versions
			self.auroreOldVersion = versionInstalled;
			self.showAuroreModal = YES;
			self.auroreIsUpdate = YES;
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
		} else {
			self.auroreSuccessful = NO;
			self.aurorePirate = YES;
		}
		self.alarmManager = nil;
	}

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.zhenguwu.aurore" object:nil];
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(auroreProcessNotif:) name:@"com.zhenguwu.aurore" object:nil];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(auroreLog:) name:nil object:nil];
	return org;
}

%new
- (void)auroreLog:(NSNotification *)notif {
	RLog(@"%@", notif);
}

// Modal Methods

- (void)lockScreenViewControllerDidDismiss {
	if (self.showAuroreModal) {
		self.showAuroreModal = NO;
		NSArray *listTitles;
		NSArray *listContents;
		if (self.auroreIsUpdate) {
			if (self.auroreSuccessful) {
				;
			} else {
				;
			}
			listTitles = @[@"Error"];
			listContents = @[@"There have not been any updates to Aurore. Please reset using the button below."];
			[self aurorePresentModal:@"Aurore" subTitle:[NSString stringWithFormat:@"What's new in v%@", self.auroreOldVersion] listTitles:listTitles listContents:listContents listImages:nil style:3];
		} else {
			if (self.auroreSuccessful) {
				listTitles = @[@"Settings", @"Clock", @"Music"];
				listContents = @[@"The alarm layout can be adjusted in the settings app. The device password must be setup there prior to use.", @"Each alarm can be individually be configured to your liking. Enabling Aurore within the editing pane will reveal further options.", @"Aurore currently supports the following links:\n- Apple Music playlist\n- Spotify playlist"];
				[self aurorePresentModal:@"Welcome to Aurore" subTitle:nil listTitles:listTitles listContents:listContents listImages:nil style:0];
			} else {
				if (self.aurorePirate) {
					listTitles = @[@"Ahoy, Matey"];
					listContents = @[@"Please purchase the official verison of Aurore at the link below"];
					[self aurorePresentModal:@"Aye Aye Pirate" subTitle:nil listTitles:listTitles listContents:listContents listImages:nil style:2];
				} else {
					listTitles = @[@"Retry", @"Reset", @"Contact"];
					listContents = @[@"Respring to retry the setup", @"Reset the filesystem if respringing does not fix the issue", @"Shoot me an email at Michaelwu21@gmail.com if neither options work"];
					[self aurorePresentModal:@"Error in Aurore Setup" subTitle:nil listTitles:listTitles listContents:listContents listImages:nil style:3];
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
		[self.auroreModal addBulletedListItemWithTitle:listTitles[x] description:listContents[x] image:nil];
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
	launchLink(@"https://repo.twickd.com/");
}

// Alarm Methods

%new
- (void)auroreProcessNotif:(NSNotification *)notif {
	NSString *notifMessage = notif.userInfo[@"from"];
	if ([notifMessage isEqualToString:@"musicSuccess"]) {
		[self auroreMusicBegan];
	} else if ([notifMessage isEqualToString:@"settings"]) {
		//if (!auroreErrorCheck()) {
			[self auroreMain:[[[auroreAlarmManager alloc] init] getDefaults]];
		//}
	}
}

%new
- (BOOL)auroreUnlock:(NSString *)key {
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
- (void)auroreMain:(NSDictionary *)settings {
	self.auroreSettings = settings;
	RLog(@"%@", self.auroreSettings);
	[self auroreVolumeSetup];
	self.auroreSnoozeCount = (int)prefsSnoozeCount;
	NSString *link = [NSString stringWithFormat:@"%@aurore", prefsLink];
	launchLink(link);
}

%new
- (void)auroreMusicBegan {
	self.auroreDismissed = NO;
	[self remoteLock:YES];
	[self auroreVolumeLoop:0 delay:prefsVolumeTime/20 interval:0.05 count:20];
	[self auroreLock:YES device:YES playback:YES volume:YES cc:YES];
	[self aurorePlaybackStateChanged];
	[self auroreOverlay];
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
- (void)auroreVolumeSetup {
	self.auroreVolume = 0;
	self.auroreVolumeContr = MSHookIvar<SBVolumeControl *>([%c(SBMediaController) sharedInstance], "_volumeControl");
	[self.auroreVolumeContr _setMediaVolumeForIAP:0];
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
	NCNotificationStructuredListViewController *lsNotifContr = [[lsMainViewContr combinedListViewController] notificationListViewController];

	self.auroreView = [[auroreView alloc] initWithFrame:lsMainViewContr.view.bounds];

	[[self.auroreView setupSnoozeButton:CGRectMake(80, 650, 130, 50) alignment:0] addTarget:self action:@selector(auroreSnooze:) forControlEvents:UIControlEventTouchUpInside];
	[[self.auroreView setupDismissButton:CGRectMake(80, 710, 130, 50) alignment:0] addTarget:self action:@selector(auroreDismiss) forControlEvents:UIControlEventTouchUpInside];

	[bgViewContr _addBedtimeGreetingBackgroundView];
	[lsMainViewContr.view addSubview:self.auroreView];

	[[bgView scrollView] setScrollEnabled:NO];
	[[bgView quickActionsView] cameraButton].userInteractionEnabled = NO;


	NCNotificationListView *notifWrapper = [lsNotifContr.view.subviews objectAtIndex:0];
	[notifWrapper _scrollToTopIfPossible:YES];
	[notifWrapper setScrollEnabled:NO];
	for (UIView *lsView in notifWrapper.subviews) {
		if ([lsView isKindOfClass:[%c(NCNotificationListView) class]]) {
			//lsView.hidden = YES;
		}
	}
}

%new
- (void)auroreDismiss {
	if (self.auroreView) {
		[self.auroreView removeFromSuperview];
		self.auroreView = nil;
	}
	self.auroreDismissed = YES;
	[self auroreLock:NO device:YES playback:YES volume:YES cc:YES];
		
	MRMediaRemoteSendCommand(kMRPause, 0);
	[self.auroreVolumeContr _setMediaVolumeForIAP:0];
	self.auroreVolumeContr = nil;

	CSCoverSheetViewController *bgViewContr = [self coverSheetViewController];
	CSCoverSheetView * bgView = (CSCoverSheetView *)bgViewContr.view;
	CSMainPageContentViewController *lsMainViewContr = [bgViewContr mainPageContentViewController];
	CSCombinedListViewController *lsCombinedContr = [lsMainViewContr combinedListViewController];
	NCNotificationStructuredListViewController *lsNotifContr = [lsCombinedContr notificationListViewController];
	CSDNDBedtimeController *bedtimeContr = MSHookIvar<CSDNDBedtimeController *>(lsCombinedContr, "_dndBedtimeController");

	[[bgView scrollView] setScrollEnabled:YES];
	[[bgView quickActionsView] cameraButton].userInteractionEnabled = YES;

	[bedtimeContr setShouldShowGreeting:NO];
	[bedtimeContr setShouldShowGreeting:YES];

	NCNotificationListView *notifWrapper = [lsNotifContr.view.subviews objectAtIndex:0];
	[notifWrapper setScrollEnabled:YES];
	for (UIView *lsView in notifWrapper.subviews) {
		if ([lsView isKindOfClass:[%c(NCNotificationListView) class]]) {
			//lsView.hidden = NO;
		}
	}	
}

%new
- (void)auroreSnooze:(CSEnhancedModalButton *)snoozeButton {
	snoozeButton.userInteractionEnabled = NO;
	[snoozeButton _buttonPressed:nil];
	[snoozeButton setTitle:@"Snoozed" forState:UIControlStateNormal];	
	self.auroreView.auroreDismissButton.hidden = YES;
	
	self.auroreDismissed = YES;
	[self auroreLock:NO device:NO playback:YES volume:YES cc:NO];
	if (prefsSnoozeVolume == 0) {
		MRMediaRemoteSendCommand(kMRPause, 0);
	} else {
		self.auroreVolume = prefsSnoozeVolume / 100;
		[self.auroreVolumeContr _setMediaVolumeForIAP:self.auroreVolume];
	}

	void *handle = dlopen("/usr/lib/libnotifications.dylib", RTLD_LAZY);                                         
	NSString *uid = [[NSUUID UUID] UUIDString];        
	[%c(CPNotification) showAlertWithTitle:@"Aurore Snooze" message:@"" userInfo:@{@"" : @""} badgeCount:0 soundName:nil
						delay:10 repeats:NO bundleId:@"com.apple.mobiletimer" uuid:uid silent:YES];					
	dlclose(handle);

	

}

%new
- (void)auroreSnoozeComplete {
	self.auroreDismissed = NO;
	[self auroreVolumeLoop:0 delay:prefsVolumeTime/20 interval:0.05 count:20];
	MRMediaRemoteSendCommand(kMRPlay, 0);
	[self auroreLock:YES device:NO playback:YES volume:YES cc:NO];
	if (self.auroreSnoozeCount == 1) {
		[self.auroreView.auroreSnoozeButton removeFromSuperview];
		self.auroreView.auroreSnoozeButton = nil;
	} else {
		self.auroreSnoozeCount--;
		self.auroreView.auroreSnoozeButton.userInteractionEnabled = YES;
		[self.auroreView.auroreSnoozeButton _buttonReleased:nil];
		[self.auroreView.auroreSnoozeButton setTitle:@"Snooze" forState:UIControlStateNormal];
	}
	self.auroreView.auroreDismissButton.hidden = NO;
}
%end


%hook CSDNDBedtimeGreetingViewController
-(id)_greetingString {
	return [NSString stringWithFormat:@"%@\n", %orig];
}

-(void)handleTouchEventForView:(id)arg1 {
	;
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


// Spotify Hooks

%group Spotify

%hook SPTLinkDispatcherImplementation 
- (void)navigateToURI:(NSURL *)link sourceApplication:(id)arg2 annotation:(id)arg3 options:(NSInteger)arg4 interactionID:(id)arg5 completionHandler:(id)arg6 {
	if (arg4 == 4) {
		NSString *strLink = link.absoluteString;
		if ([[strLink substringFromIndex: [strLink length] - 6] isEqualToString:@"aurore"]) {
			auroreEnabled = YES;
			NSURL *newLink = [NSURL URLWithString:[strLink substringToIndex: [strLink length] - 6]];
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
		[[self playViewModel] singleStateShufflePlay];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			postNotification(@"musicSuccess");
		});
	}
}
%end

%hook SPTFreeTierAlbumViewController
- (void)playURIInContext:(id)arg1 {
	if (auroreEnabled) {
		auroreEnabled = NO;
		[[self player] setShufflingContext:YES];
		[self playURIInContext:nil];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			postNotification(@"musicSuccess");
		});
	} else {
		%orig;
	}
}
%end

//%hook SPTFreeTierArtistViewController


%end

// Apple Music Hooks

%group AppleMusic

%hook MusicSceneDelegate
- (void)scene:(id)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
	UIOpenURLContext *oldURLContexts = (UIOpenURLContext *)[[URLContexts allObjects] objectAtIndex:0];
	NSString *strLink = oldURLContexts.URL.absoluteString;
	if ([[strLink substringFromIndex: [strLink length] - 6] isEqualToString:@"aurore"]) {
		auroreEnabled = YES;
		NSURL *newLink = [NSURL URLWithString:[strLink substringToIndex: [strLink length] - 6]];
		UIOpenURLContext *newOpenURLContext = [[%c(UIOpenURLContext) alloc] initWithURL:newLink options:oldURLContexts.options];
		NSSet *newURLContexts = [NSSet setWithObject:newOpenURLContext];
		%orig(scene, newURLContexts);
	} else {
		%orig;
	}
}

- (void)scene:(id)scene willConnectToSession:(id)session options:(UISceneConnectionOptions *)connectionOptions {
	UIOpenURLContext *oldURLContexts = (UIOpenURLContext *)([[connectionOptions.URLContexts allObjects] objectAtIndex:0]);
	NSString *strLink = oldURLContexts.URL.absoluteString;
	if ([[strLink substringFromIndex: [strLink length] - 6] isEqualToString:@"aurore"]) {
		auroreEnabled = YES;
		NSURL *newLink = [NSURL URLWithString:[strLink substringToIndex: [strLink length] - 6]];
		UIOpenURLContext *newOpenURLContext = [[%c(UIOpenURLContext) alloc] initWithURL:newLink options:oldURLContexts.options];
		NSSet *newURLContexts = [NSSet setWithObject:newOpenURLContext];
		_UISceneConnectionOptionsContext *newOptionsContext = [%c(_UISceneConnectionOptionsContext) alloc];
		newOptionsContext.launchOptionsDictionary = @{@"_UISceneConnectionOptionsURLContextKey" : newURLContexts};
		UISceneConnectionOptions *newConnectionOptions = [[%c(UISceneConnectionOptions) alloc] _initWithConnectionOptionsContext:newOptionsContext fbsScene:connectionOptions._fbsScene specification:connectionOptions._specification];
		%orig(scene, session, newConnectionOptions);
	} else {
		%orig;
	}
}
%end


%hook MusicPlayControls
- (id)initWithFrame:(CGRect)frame {
	id x = %orig;
	if (auroreEnabled) {
		auroreEnabled = NO;
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[(UIButton *)[self accessibilityShuffleButton] sendActionsForControlEvents:64];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				postNotification(@"musicSuccess");
			});
		});
	}
	return x;
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
	RLog(@"alarm removed");
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

- (id)initWithAlarm:(MTAlarm *)arg1 isNewAlarm:(BOOL)arg2 {
	self.alarmManager = [[auroreAlarmManager alloc] init];
	[self.alarmManager syncAlarmsIfNeeded];
	if (arg2) {
		self.auroreSettings = [self.alarmManager getDefaults];
	} else {
		self.auroreSettings = [self.alarmManager getAlarm:[arg1 alarmIDStr]];
	}
	self.auroreEnabled = [[self.auroreSettings objectForKey:@"enabled"] boolValue];

	/*NSString* link = @"https://open.spotify.com/playlist/5bFqxODjPiAOUMK12T3xrD?si=bq6KgfN1RaqHE2PSXDYDPw";
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:link] cachePolicy:0 timeoutInterval:5];
	NSURLResponse *response=nil;
	NSError *error=nil;
	NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *htmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	//NSString *htmlString = [NSString stringWithContentsOfURL:myURL encoding: NSUTF8StringEncoding error:nil];
	NSRegularExpression *regex = [NSRegularExpression
                              regularExpressionWithPattern:@"<title[^>]*>(.*?)</title>"
                              options:0
                              error:&error];
	NSTextCheckingResult *result = [regex firstMatchInString:htmlString options:NSMatchingReportProgress range:NSMakeRange(0, [htmlString length])];
	NSRange titleRange = [result rangeAtIndex:1];
	NSString *title = [htmlString substringWithRange:titleRange];
	RLog(title);*/
	return %orig;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if (self.auroreEnabled) {
			return 6;
		}
		return 5;
	} else {
		return 1;
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
				UITableViewCell *auroreSettingsCell = %orig(tableView, [NSIndexPath indexPathForRow:0 inSection:0]);
				auroreSettingsCell.textLabel.text = @"Music Options";
				auroreSettingsCell.detailTextLabel.text = @"Spotify";
				return auroreSettingsCell;
			} else if (indexPath.row == 4) {
				UITableViewCell *auroreSettingsCell = %orig(tableView, [NSIndexPath indexPathForRow:0 inSection:0]);
				auroreSettingsCell.textLabel.text = @"Snooze Options";
				auroreSettingsCell.detailTextLabel.text = @"";
				return auroreSettingsCell;
			} else if (indexPath.row == 5) {
				UITableViewCell *auroreSettingsCell = %orig(tableView, [NSIndexPath indexPathForRow:0 inSection:0]);
				auroreSettingsCell.textLabel.text = @"Other Options";
				auroreSettingsCell.detailTextLabel.text = @"";
				return auroreSettingsCell;
			}
		}
	}
	return %orig;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (self.auroreEnabled) {
			if (indexPath.row == 0 || indexPath.row == 1) {
				%orig;
			} else if (indexPath.row == 3) {
				auroreMusicTableViewController *musicTableController = [[auroreMusicTableViewController alloc] initWithSettings:self.auroreSettings];

				[self.navigationController pushViewController:musicTableController animated:YES];
			} else if (indexPath.row == 4) {
				auroreSnoozeTableViewController *snoozeTableController = [[auroreSnoozeTableViewController alloc] initWithSettings:self.auroreSettings];

				[self.navigationController pushViewController:snoozeTableController animated:YES];
			} else if (indexPath.row == 5) {
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
	[self.alarmManager setAlarm:[[self editedAlarm] alarmIDStr] withData:self.auroreSettings];
	%orig;
}

%new
- (void)auroreSwitchChanged:(UISwitch *)auroreSwitch {
	self.auroreEnabled = auroreSwitch.on;
	
	UITableView *settingsTable = [(MTAAlarmEditView *)self.view settingsTable];

	NSArray *deleteIndexPaths;
	NSArray *insertIndexPaths;
	if (self.auroreEnabled) {
		deleteIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0], nil];
		insertIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0], [NSIndexPath indexPathForRow:5 inSection:0], nil];
	} else {
		deleteIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], [NSIndexPath indexPathForRow:4 inSection:0], [NSIndexPath indexPathForRow:5 inSection:0], nil];
		insertIndexPaths = [NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], [NSIndexPath indexPathForRow:3 inSection:0], nil];
	}

	[settingsTable beginUpdates];
	[settingsTable deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
	[settingsTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
	[settingsTable endUpdates];

}
%end

%end


%group ClockInset

%hook UITableView
- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	id x = %orig;
	if (frame.origin.y != 44 && ([[self.backgroundColor _systemColorName] isEqualToString:@"systemGroupedBackgroundColor"] || ([self class] == [%c(MTAStopwatchTableView) class]))) {
		self = %orig(frame, UITableViewStyleInsetGrouped);
		return self;
	}
	return x;
	
}
%end

%end

/*
%new


%new
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 30;
}*/

%group ClockSound

%hook TKTonePickerViewController
- (void)viewDidLoad {
	%orig;
	[self setShowsMedia:NO];
	[self setNoneAtTop:YES];
}

- (void)viewWillAppear:(BOOL)arg1 {
	[self setShowsToneStore:NO];
	%orig;
}
%end

%end


%ctor {

	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"com.zhenguwu.aurorepreferences"];
	[prefs registerObject:&prefsLink default:nil forKey:@"link"];
	[prefs registerDouble:&prefsVolumeTime default:180 forKey:@"volumeTime"];
	[prefs registerDouble:&prefsSnoozeTime default:300 forKey:@"snoozeTime"];
	[prefs registerFloat:&prefsSnoozeVolume default:0 forKey:@"snoozeVolume"];
	[prefs registerInteger:&prefsSnoozeCount default:1 forKey:@"snoozeCount"];
	[prefs registerInteger:&prefsBlurStyle default:2 forKey:@"blurStyle"];

	/*NSString *bundlePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"Frameworks/MusicApplication.framework"];
	[[NSBundle bundleWithPath:bundlePath] load];
	RLog(bundlePath);
	RLog(@"cls: %@", objc_getClass("MusicApplication.PlaylistDetailSongsViewController"));*/

	NSString *process = [[NSProcessInfo processInfo] processName];
	RLog(process);
	if ([process isEqualToString:@"SpringBoard"]) {
		%init(SpringBoard);
	} else if ([process isEqualToString:@"MobileTimer"]) {
		%init(Clock);
		if (YES) {
			%init(ClockInset);
		}
		if (YES) {
			%init(ClockSound);
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