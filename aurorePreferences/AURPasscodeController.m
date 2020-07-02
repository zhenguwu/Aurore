#import "AURPasscodeController.h"
#import "../tools/helpers.h"

@implementation AURPasscodeController
- (NSString *)topTitle {
    return @"Passcode";
}

- (NSString *)plistName {
	return @"Passcode";
}

-(BOOL)shouldSelectResponderOnAppearance {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ((UITableView *)[self table]).keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
}

-(void)_returnKeyPressed:(id)arg1 {}

- (void)savePasscode {
    NSString *passcodeRaw = [(PSTableCell *)[self tableView:[self table] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] value];
    NSData *passcodeEncrypted = AES128Encrypt(passcodeRaw);
    NSString *path = @"/var/mobile/Library/Preferences/Aurore/pass.txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
    if (file == nil) {
        postAlert(@"Aurore Error", @"Error Saving Passcode");
    } else {
        [file truncateFileAtOffset:0];
        [file writeData:passcodeEncrypted];
        [file closeFile];
        postAlert(@"Aurore", [NSString stringWithFormat:@"Passcode: %@ Saved Securely", passcodeRaw]);
    }
}
@end