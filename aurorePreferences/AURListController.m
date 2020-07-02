#import "AURListController.h"

@implementation AURListController
- (NSString *)topTitle {
    return nil;
}

- (NSString *)plistName {
    return nil;
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSString* plistName = [self plistName];

		if(plistName)
		{
			_specifiers = [self loadSpecifiersFromPlistName:plistName target:self];
		}
	}
	NSString* title = [self topTitle];
	if (title) {
		[(UINavigationItem *)self.navigationItem setTitle:title];
	}
	return _specifiers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	((UITableView *)[self table]).keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}
@end