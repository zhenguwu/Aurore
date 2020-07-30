#import "auroreOthersTableViewController.h"

@implementation auroreOthersTableViewController
- (id)initWithSettings:(NSDictionary *)settings inset:(BOOL)inset isSleep:(BOOL)isSleep{
    if (inset & !isSleep) {
        self = [super initWithStyle:UITableViewStyleInsetGrouped];
    } else {
        self = [super initWithStyle:UITableViewStyleGrouped];
    }
    self.isSleep = isSleep;
    self.showWeather = settings[@"showWeather"];
    self.dismissAction = settings[@"dismissAction"];
    self.code = settings[@"code"];
    self.shortcutFire = settings[@"shortcutFire"];
    self.shortcutDismiss = settings[@"shortcutDismiss"];
    self.othersSettingsChanged = NO;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Other Options";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (self.isSleep) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(returnAndSave)];
    }
}

- (void)returnAndSave {
    if (self.othersSettingsChanged) {
        [self.delegate auroreOthersTableControllerUpdateShowWeather:self.showWeather dismissAction:self.dismissAction code:self.code shortcutFire:self.shortcutFire shortcutDismiss:self.shortcutDismiss];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveState {
    // No idea why I have to add this, but stops crashes
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (!self.isSleep) {
        if (parent) {
            [parent setModalInPresentation:YES];
        } else if (self.othersSettingsChanged) {
            [self.delegate auroreOthersTableControllerUpdateShowWeather:self.showWeather dismissAction:self.dismissAction code:self.code shortcutFire:self.shortcutFire shortcutDismiss:self.shortcutDismiss];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3 || section == 2) {
        return 2;
    }
    if (section == 1) {
        if ([self.dismissAction intValue] == 1) {
            return 1;
        }
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *othersCell = [tableView dequeueReusableCellWithIdentifier:@"auroreCell"];
    if (othersCell == nil) {
        othersCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"auroreCell"];
        if (self.isSleep) {
            othersCell.backgroundColor = [UIColor blackColor];
        } else {
            othersCell.backgroundColor = [UIColor colorWithRed:0.172549 green:0.172549 blue:0.180392 alpha:1.0];
        }
        othersCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView *badView in othersCell.contentView.subviews) {
        [badView removeFromSuperview];
    }
    othersCell.accessoryView = nil;
    othersCell.textLabel.text = @"";

    if (indexPath.section == 0) {
        othersCell.textLabel.text = @"Show Weather Summary";
        UISwitch *weatherSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [weatherSwitch setOn:[self.showWeather boolValue] animated:NO];
        [weatherSwitch addTarget:self action:@selector(weatherSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        othersCell.accessoryView = weatherSwitch;
    } else if (indexPath.section == 1) {
        int dismissAction = [self.dismissAction intValue];
        if (dismissAction == 0) {
            if (indexPath.row == 0) {
                othersCell.textLabel.text = @"Math Problems to Dismiss";
                UISwitch *mathSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                [mathSwitch setOn:NO animated:NO];
                [mathSwitch addTarget:self action:@selector(mathActionSwitchChanged: )forControlEvents:UIControlEventValueChanged];
                othersCell.accessoryView = mathSwitch;
            } else {
                othersCell.textLabel.text = @"Scan Code to Dismiss";
                UISwitch *barcodeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                [barcodeSwitch setOn:NO animated:NO];
                [barcodeSwitch addTarget:self action:@selector(barcodeActionSwitchChanged:)forControlEvents:UIControlEventValueChanged];
                othersCell.accessoryView = barcodeSwitch;
            }
        } else if (dismissAction == 1) {
            othersCell.textLabel.text = @"Math Problems to Dismiss";
            UISwitch *mathSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [mathSwitch setOn:YES animated:NO];
            [mathSwitch addTarget:self action:@selector(mathActionSwitchChanged: )forControlEvents:UIControlEventValueChanged];
            othersCell.accessoryView = mathSwitch;
        } else {
            if (indexPath.row == 0) {
                othersCell.textLabel.text = @"Scan Code to Dismiss";
                UISwitch *barcodeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                [barcodeSwitch setOn:YES animated:NO];
                [barcodeSwitch addTarget:self action:@selector(barcodeActionSwitchChanged:)forControlEvents:UIControlEventValueChanged];
                othersCell.accessoryView = barcodeSwitch;
            } else {
                othersCell.textLabel.text = @"Barcode / QR Code";
                UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(180, 12, 200, 21)];
                [textField setReturnKeyType:UIReturnKeyDone];
                [textField setFont:[UIFont systemFontOfSize:16]];
                textField.keyboardType = UIKeyboardTypeAlphabet;
                textField.placeholder = @"Code";
                textField.text = self.code;
                textField.delegate = self;

                [textField addTarget:self action:@selector(codeTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
                [othersCell.contentView addSubview:textField];
            }
        }
    } else if (indexPath.section == 2) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(180, 12, 200, 21)];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setFont:[UIFont systemFontOfSize:16]];
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.placeholder = @"Shortcut Name";
        textField.delegate = self;

        if (indexPath.row == 0) {
            othersCell.textLabel.text = @"Shortcut on Fire";
            textField.text = self.shortcutFire;
            [textField addTarget:self action:@selector(shortcutFireTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        } else {
            othersCell.textLabel.text = @"Shortcut on Dismiss";
            textField.text = self.shortcutDismiss;
            [textField addTarget:self action:@selector(shortcutDismissTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        }
        [othersCell.contentView addSubview:textField];
    } else {
        othersCell.selectionStyle = UITableViewCellSelectionStyleGray;
        if (indexPath.row == 0) {
            othersCell.textLabel.text = @"Save as Default";
            othersCell.textLabel.textAlignment = NSTextAlignmentCenter;
            othersCell.textLabel.textColor = [UIColor systemBlueColor];
        } else {
            othersCell.textLabel.text = @"Reset to Default";
            othersCell.textLabel.textAlignment = NSTextAlignmentCenter;
            othersCell.textLabel.textColor = [UIColor systemRedColor];
        }
    }
    return othersCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self returnAndSave];
            [self.delegate auroreSetAsDefault];
        } else {
            [self returnAndSave];
            [self.delegate auroreResetToDefault];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)weatherSwitchChanged:(UISwitch *)weatherSwitch {
    self.showWeather = @(weatherSwitch.on);
    self.othersSettingsChanged = YES;
}
- (void)mathActionSwitchChanged:(UISwitch *)mathSwitch {
    NSArray *path = @[[NSIndexPath indexPathForRow:1 inSection:1]];
    [self.tableView beginUpdates];
    if (mathSwitch.on) {
        self.dismissAction = @1;
        [self.tableView deleteRowsAtIndexPaths:path withRowAnimation:UITableViewRowAnimationFade];
    } else {
        self.dismissAction = @0;
        [self.tableView insertRowsAtIndexPaths:path withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
    self.othersSettingsChanged = YES;
}
- (void)barcodeActionSwitchChanged:(UISwitch *)barcodeSwitch {
    NSArray *path1 = @[[NSIndexPath indexPathForRow:0 inSection:1]];
    NSArray *path2 = @[[NSIndexPath indexPathForRow:1 inSection:1]];
    [self.tableView beginUpdates];
    if (barcodeSwitch.on) {
        self.dismissAction = @2;
        [self.tableView deleteRowsAtIndexPaths:path1 withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:path2 withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView deleteRowsAtIndexPaths:path2 withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView insertRowsAtIndexPaths:path1 withRowAnimation:UITableViewRowAnimationFade];
        self.dismissAction = @0;
    }
    [self.tableView endUpdates];
    self.othersSettingsChanged = YES;
}
- (void)codeTextFieldChanged:(UITextField *)textField {
    self.code = textField.text;
    self.othersSettingsChanged = YES;
}
- (void)shortcutFireTextFieldChanged:(UITextField *)textField {
    self.shortcutFire = textField.text;
    self.othersSettingsChanged = YES;
}
- (void)shortcutDismissTextFieldChanged:(UITextField *)textField {
    self.shortcutDismiss = textField.text;
    self.othersSettingsChanged = YES;
}

@end