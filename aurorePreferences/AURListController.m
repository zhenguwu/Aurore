#import "AURListController.h"
#import "../tools/constants.h"

@implementation AURListController
- (NSString *)topTitle {
    return nil;
}

- (NSString *)plistName {
    return nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:[self plistName] target:self];
	}
	[(UINavigationItem *)self.navigationItem setTitle:[self topTitle]];
	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self table].keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
	[[UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self class]]] setOnTintColor:[UIColor colorWithRed: 0.63 green: 0.62 blue: 0.57 alpha: 1.00]];
}
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[UIApplication sharedApplication].keyWindow.tintColor = [UIColor colorWithRed:0.63 green:0.62 blue:0.57 alpha:1.00];
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}
@end