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

- (void)applySettings {
	respring();
}

- (void)viewDidLoad {
    [super viewDidLoad];
	((UITableView *)[self table]).keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(applySettings)];
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	//self.navigationController.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: 0.62 green: 0.67 blue: 0.98 alpha: 1.00];
	//self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    //[self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
}
@end

