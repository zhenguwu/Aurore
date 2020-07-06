static NSString *globName = @"";
static BOOL globInset;

@class auroreModal;
@class auroreAlarmManager;
@class auroreView;
@class CSEnhancedModalButton;
@class MTAlarm;
@class auroreMusicTableViewController;
@class auroreSnoozeTableViewController;
@class auroreOthersTableViewController;

@interface UIApplication (Aurore)
- (BOOL)launchApplicationWithIdentifier: (NSString *)identifier suspended: (BOOL)suspended;
@end

@interface UIColor (Aurore)
- (id)_systemColorName;
@end

@interface CPNotification
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message userInfo:(NSDictionary *)userInfo badgeCount:(int)badgeCount soundName:(NSString *)soundName delay:(double)delay repeats:(BOOL)repeats bundleId:(NSString *)bundleId uuid:(NSString *)uuid silent:(BOOL)silent;
@end

@interface NCNotificationContent
- (NSString *)title;
@end

@interface NCNotificationRequest
- (NCNotificationContent *)content;
- (NSString *)sectionIdentifier;
- (NSString *)notificationIdentifier;
@end

@interface NCNotificationDispatcher
- (BOOL)_shouldPostNotificationRequest:(NCNotificationRequest *)req;

- (NSDictionary *)auroreAlarmCheck:(NSString *)identifier;
@end

@interface CSDNDBedtimeController
- (void)setActive:(BOOL)arg1;
- (void)setShouldShowGreeting:(BOOL)arg1;
@end

@interface CSDNDBedtimeGreetingViewController : UIViewController
-(id)_greetingString;
-(void)handleTouchEventForView:(id)arg1;
@end

@interface NCNotificationListView : UIScrollView
- (void)_scrollToTopIfPossible:(BOOL)arg1;
@end

@interface NCNotificationStructuredListViewController : UIViewController
@end

@interface CSCombinedListViewController : UIViewController {
    CSDNDBedtimeController *_dndBedtimeController;
}
- (NCNotificationStructuredListViewController *)notificationListViewController;
@end

@interface CSMainPageContentViewController : UIViewController
- (CSCombinedListViewController *)combinedListViewController;
@end

@interface SBFPagedScrollView : UIScrollView
@end

@interface CSQuickActionsButton : UIView
@end

@interface CSQuickActionsView : UIView
- (CSQuickActionsButton *)cameraButton;
@end

@interface CSCoverSheetView : UIView
- (SBFPagedScrollView *)scrollView;
- (CSQuickActionsView *)quickActionsView;
@end

@interface CSCoverSheetViewController : UIViewController
- (CSMainPageContentViewController *)mainPageContentViewController;
- (BOOL)isAuthenticated;
- (void)_addBedtimeGreetingBackgroundView;
- (void)_removeBedtimeGreetingBackgroundViewAnimated:(BOOL)arg1;

- (void)auroreDismissModal;
@end

@interface SBVolumeControl
- (void)_setMediaVolumeForIAP:(float)arg1;
- (float)_getMediaVolumeForIAP;
@end

@interface SBMediaController {
    SBVolumeControl *_volumeControl;
}
+ (id)sharedInstance;
@end

@interface SBSoftLockoutController
@property (nonatomic,assign) BOOL auroreLocked;
- (id)initWithBiometricLockoutState:(unsigned long long)arg1 lockScreenManager:(id)arg2;
- (id)initWithBiometricLockoutState:(unsigned long long)arg1;
- (BOOL)isLocked;
@end

@interface SBiCloudPasscodeRequirementLockoutController {
    SBSoftLockoutController *_lockOutController;
}
@end

@interface SBDefaultAuthenticationPolicy
- (SBiCloudPasscodeRequirementLockoutController *)iCloudPasscodeRequirementLockoutController;
@end

@interface SBFUserAuthenticationController
- (SBDefaultAuthenticationPolicy *)_policy;
@end

@interface SBLockScreenManager
@property (nonatomic,assign) BOOL showAuroreModal;
@property (nonatomic,assign) BOOL auroreIsUpdate;
@property (nonatomic,assign) BOOL auroreSuccessful;
@property (nonatomic,assign) NSInteger auroreError;
@property (nonatomic,assign) BOOL aurorePirate;
@property (nonatomic,retain) NSString *auroreOldVersion;
@property (nonatomic,retain) auroreAlarmManager *alarmManager;
@property (nonatomic,retain) NSDictionary *auroreSettings;
@property (nonatomic,retain) NSDictionary *auroreSettings2;
@property (nonatomic,retain) MTAlarm *backupAlarm;
@property (nonatomic,retain) auroreModal *auroreModal;
@property (nonatomic,retain) auroreView *auroreView;
@property (nonatomic,assign) BOOL auroreDismissed;
@property (nonatomic,assign) BOOL auroreCompletelyDismissed;
@property (nonatomic,retain) SBVolumeControl *auroreVolumeContr;
@property (nonatomic,assign) float auroreVolume;
@property (nonatomic,assign) int auroreSnoozeCount;
+ (id)sharedInstance;
- (id)init;
- (void)auroreLog:(NSNotification *)notif;
- (SBFUserAuthenticationController *)_userAuthController;
- (CSCoverSheetViewController *)coverSheetViewController;
- (BOOL)_attemptUnlockWithPasscode:(id)arg1 finishUIUnlock:(BOOL)arg2;
- (void)remoteLock:(BOOL)arg1;
- (void)lockScreenViewControllerDidDismiss;

- (void)aurorePresentModal:(NSString *)title subTitle:(NSString *)subTitle listTitles:(NSArray *)listTitles listContents:(NSArray *)listContents listImages:(NSArray *)listImages style:(NSInteger)style;
- (void)auroreDismissModal:(BOOL)openSettings;
- (void)auroreModalSetup;
- (void)auroreModalUpdate;
- (void)auroreModalPurchase;
- (void)auroreProcessNotif:(NSNotification *)notif;
- (BOOL)auroreUnlock:(NSString *)key;
- (void)auroreMain:(NSDictionary *)settings compatibility:(BOOL)compatibility;
- (void)auroreMusicBegan:(BOOL)retry;
- (void)auroreLock:(BOOL)arg1 device:(BOOL)arg2 playback:(BOOL)arg3 volume:(BOOL)arg4 cc:(BOOL)arg5;
- (void)auroreVolumeSetup;
- (void)auroreConnectBluetooth:(NSString *)device loop:(BOOL)loop;
- (void)auroreVolumeLoop:(int)counter delay:(double)delay interval:(float)interval count:(int)count;
- (void)aurorePlaybackStateChanged;
- (void)auroreVolumeChanged;
- (void)auroreOverlay;
- (void)auroreClear;
- (void)auroreDismiss;
- (void)auroreSnooze:(CSEnhancedModalButton *)snoozeButton;
- (void)auroreSnoozeComplete;
@end

/*
@interface SpringBoard
//- (void) _simulateLockButtonPress;
@end*/

@interface SBBacklightController
+ (id)sharedInstance;
- (void)setBacklightFactor:(float)arg1 source:(long long)arg2;
- (void)_startFadeOutAnimationFromLockSource:(int)arg1;
- (void)_animateBacklightToFactor:(float)arg1 duration:(double)arg2 source:(long long)arg3 silently:(BOOL)arg4 completion:(/*^block*/id)arg5 ;
@end

@interface SBControlCenterWindow
+ (id)sharedInstance;
@end

@interface SBControlCenterController
@property (nonatomic,retain) SBControlCenterWindow *window;
@property (nonatomic,retain) SBControlCenterWindow *windowTemp;
+ (id)sharedInstance;
- (void)setWindow:(SBControlCenterWindow *)arg1;
@end

@interface BluetoothDevice
- (NSString *)name;
- (BOOL)connected;
- (void)disconnect;
- (void)connect;
@end

@interface BluetoothManager
+ (id)sharedInstance;
- (NSArray *)pairedDevices;
@end


// Spotify Headers


@interface SPTFreeTierPlaylistViewModelImplementation
- (void)singleStateShufflePlay;
- (void)singleStateForceLinearPlay;
@end

@interface VISREFBaseHeaderController
- (void)setHeaderSetupDone:(BOOL)arg1;
- (SPTFreeTierPlaylistViewModelImplementation *)playViewModel;
@end 

@interface SPTPlayerImpl
- (id)setShufflingContext:(BOOL)arg1;
@end

@interface SPTFreeTierAlbumViewController : UIViewController
- (SPTPlayerImpl *)player;
- (void)playURIInContext:(id)arg1;
@end

@interface SPTLinkDispatcherImplementation
- (void)navigateToURI:(NSURL *)link sourceApplication:(id)arg2 annotation:(id)arg3 options:(NSInteger)arg4 interactionID:(id)arg5 completionHandler:(id)arg6;
@end


// Apple Music Headers

/*
@interface UISceneOpenURLOptions
@end*/


@interface UIOpenURLContext (Aurore)
@property(nonatomic,copy) NSURL *URL;
@property (nonatomic,readonly) UISceneOpenURLOptions *options;
- (id)initWithURL:(id)arg1 options:(id)arg2;
@end

@interface FBSScene
@end

@interface FBSSceneSpecification
@end


@interface _UISceneConnectionOptionsContext
@property (nonatomic,retain) NSDictionary * launchOptionsDictionary;
@end


@interface UISceneConnectionOptions (Aurore)
@property (nonatomic,weak,readonly) FBSScene * _fbsScene;
@property (nonatomic,weak,readonly) FBSSceneSpecification * _specification;
@property(nonatomic,readonly,copy) NSSet<UIOpenURLContext *> *URLContexts;
- (id)_initWithConnectionOptionsContext:(_UISceneConnectionOptionsContext *)arg1 fbsScene:(FBSScene *)arg2 specification:(FBSSceneSpecification *)arg3;
@end

@interface MusicSceneDelegate
- (void)scene:(id)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)scene:(id)scene willConnectToSession:(id)session options:(id)connectionOptions;
@end

@interface MusicPlayControls
- (UIButton *)accessibilityPlayButton;
- (UIButton *)accessibilityShuffleButton;
@end


// Clock Headers

@class MTAlarm;
@class MTMutableAlarm;

@interface MTAlarmManager
- (id)addAlarm:(MTAlarm *)arg1;
- (id)removeAlarm:(MTAlarm *)arg1;
@end

@interface SBScheduledAlarmObserver {
    MTAlarmManager *_alarmManager;
}
+ (id)sharedInstance;
@end

@interface MTAlarmDataSource
- (id)removeAlarm:(MTMutableAlarm *)alarm;
@end

@interface MTAAlarmEditView
- (UITableView *)settingsTable;
@end

@interface MTAAlarmEditViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, auroreMusicDelegate, auroreSnoozeDelegate, auroreOthersDelegate>
@property (nonatomic,retain) auroreAlarmManager *alarmManager;
@property (nonatomic,assign) BOOL auroreEnabled;
@property (nonatomic,retain) NSMutableDictionary *auroreSettings;
@property (nonatomic,assign) BOOL auroreSettingsChanged;

- (id)initWithAlarm:(MTAlarm *)arg1 isNewAlarm:(BOOL)arg2;
- (MTMutableAlarm *)editedAlarm;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)_cancelButtonClicked:(BOOL)arg1;
- (void)_doneButtonClicked:(id)arg1;

- (void)auroreSwitchChanged:(UISwitch *)sender;
- (void)reloadTableCellAtRow:(NSInteger)row;
- (void)auroreMusicTableControllerUpdateLink:(NSString *)link shuffle:(NSNumber *)shuffle volumeMax:(NSNumber *)volumeMax volumeTime:(NSNumber *)volumeTime bluetooth:(NSString *)bluetooth airplay:(NSString *)airplay;
- (NSString *)auroreUpdateLinkContext:(BOOL)correct link:(NSString *)link reload:(BOOL)reload;
- (void)auroreSnoozeTableControllerUpdateSnoozeEnabled:(NSNumber *)snoozeEnabled snoozeCount:(NSNumber *)snoozeCount snoozeTime:(NSNumber *)snoozeTime snoozeVolume:(NSNumber *)snoozeVolume snoozeVolumeTime:(NSNumber *)snoozeVolumeTime;
- (void)auroreOthersTableControllerUpdateShowWeather:(NSNumber *)showWeather dismissAction:(NSNumber *)dismissAction shortcutFire:(NSString *)shortcutFire shortcutSnooze:(NSString *)shortcutSnooze shortcutDismiss:(NSString *)shortcutDismiss;
@end

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
*/

@interface MTASleepDetailViewController : UITableViewController <auroreMusicDelegate, auroreSnoozeDelegate, auroreOthersDelegate>
@property (nonatomic,retain) auroreAlarmManager *alarmManager2;
@property (nonatomic,assign) BOOL auroreEnabled;
@property (nonatomic,retain) NSMutableDictionary *auroreSettings;

- (id)initWithAlarmManager:(id)arg1 dataSource:(id)arg2;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)auroreSaveSettings;
- (void)auroreSwitchChanged:(UISwitch *)sender;
- (void)reloadTableCellAtRow:(NSInteger)row;
- (void)auroreMusicTableControllerUpdateLink:(NSString *)link shuffle:(NSNumber *)shuffle volumeMax:(NSNumber *)volumeMax volumeTime:(NSNumber *)volumeTime bluetooth:(NSString *)bluetooth airplay:(NSString *)airplay;
- (NSString *)auroreUpdateLinkContext:(BOOL)correct link:(NSString *)link reload:(BOOL)reload;
- (void)auroreSnoozeTableControllerUpdateSnoozeEnabled:(NSNumber *)snoozeEnabled snoozeCount:(NSNumber *)snoozeCount snoozeTime:(NSNumber *)snoozeTime snoozeVolume:(NSNumber *)snoozeVolume snoozeVolumeTime:(NSNumber *)snoozeVolumeTime;
- (void)auroreOthersTableControllerUpdateShowWeather:(NSNumber *)showWeather dismissAction:(NSNumber *)dismissAction shortcutFire:(NSString *)shortcutFire shortcutSnooze:(NSString *)shortcutSnooze shortcutDismiss:(NSString *)shortcutDismiss;
@end

@interface MTUISwitchTableViewCell : UIView
@end

@interface TKTonePickerViewController : UIViewController
- (void)setShowsToneStore:(BOOL)arg1;
- (void)setShowsMedia:(BOOL)arg1;
- (void)setNoneAtTop:(BOOL)arg1;
@end

