#import "AURRootListController.h"
#import "../tools/helpers.h"

@implementation AURRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}
- (void)auroreTest {
	postNotification(@"settings");
}
- (void)auroreReset {
	reset();
}
- (void)auroreDonate {
	launchLink(@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VRUFKHFCJ9UE8&item_name=Tweak+Development&currency_code=USD&source=url");
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self table].keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self table].contentInset = UIEdgeInsetsMake(44,0,0,0);
	[[self table] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:self action:@selector(auroreTest)];

	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,200,100)];
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,200,100)];
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerImageView.image = [UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AurorePrefs.bundle/banner.png"];
    headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    headerImageView.clipsToBounds = YES;

    [headerView addSubview:headerImageView];
    [NSLayoutConstraint activateConstraints:@[
        [headerImageView.topAnchor constraintEqualToAnchor:headerView.topAnchor],
        [headerImageView.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [headerImageView.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        [headerImageView.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor],
    ]];
	[self table].tableHeaderView = headerView;

	[[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setOnTintColor:[UIColor colorWithRed: 0.63 green: 0.62 blue: 0.57 alpha: 1.00]];
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//UIView *statusBar = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager.statusBarFrame] ;
	//statusBar.backgroundColor = [UIColor colorWithRed: 0.18 green: 0.25 blue: 0.30 alpha: 1.00];;
	//[[UIApplication sharedApplication].keyWindow addSubview:statusBar];
	self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.18 green: 0.25 blue: 0.30 alpha: 1.00];
	[UIApplication sharedApplication].keyWindow.tintColor = [UIColor colorWithRed:0.63 green:0.62 blue:0.57 alpha:1.00];
	[self.navigationController.navigationController.navigationBar setShadowImage: [UIImage new]];
	self.navigationController.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

	self.navigationController.navigationController.navigationBar.barTintColor = nil;
	self.navigationController.navigationController.navigationBar.translucent = YES;
	[UIApplication sharedApplication].keyWindow.tintColor = nil;
}

@end

