#import "auroreSnoozeTableViewController.h"

@implementation auroreSnoozeTableViewController
- (id)initWithSettings:(NSDictionary *)settings inset:(BOOL)inset isSleep:(BOOL)isSleep{
    if (inset & !isSleep) {
        self = [super initWithStyle:UITableViewStyleInsetGrouped];
    } else {
        self = [super initWithStyle:UITableViewStyleGrouped];
    }
    self.isSleep = isSleep;
    self.snoozeEnabled = settings[@"snoozeEnabled"];
    self.snoozeCount = settings[@"snoozeCount"];
    self.snoozeTime = settings[@"snoozeTime"];
    self.snoozeVolume = settings[@"snoozeVolume"];
    self.snoozeVolumeTime = settings[@"snoozeVolumeTime"];
    self.snoozeSettingsChanged = NO;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Snooze Options";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (self.isSleep) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(returnAndSave)];
    }
}

- (void)returnAndSave {
    if (self.snoozeSettingsChanged) {
        [self.delegate auroreSnoozeTableControllerUpdateSnoozeEnabled:self.snoozeEnabled snoozeCount:self.snoozeCount snoozeTime:self.snoozeTime snoozeVolume:self.snoozeVolume snoozeVolumeTime:self.snoozeVolumeTime];
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
        } else if (self.snoozeSettingsChanged) {
            [self.delegate auroreSnoozeTableControllerUpdateSnoozeEnabled:self.snoozeEnabled snoozeCount:self.snoozeCount snoozeTime:self.snoozeTime snoozeVolume:self.snoozeVolume snoozeVolumeTime:self.snoozeVolumeTime];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        if ([self.snoozeEnabled boolValue]) {
            return 2;
        } else {
            return 0;
        }
    } 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *snoozeCell = [tableView dequeueReusableCellWithIdentifier:@"auroreCell"];
    if (snoozeCell == nil) {
        snoozeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"auroreCell"];
        if (self.isSleep) {
            snoozeCell.backgroundColor = [UIColor blackColor];
        } else {
            snoozeCell.backgroundColor = [UIColor colorWithRed:0.172549 green:0.172549 blue:0.180392 alpha:1.0];
        }
        snoozeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView *badView in snoozeCell.contentView.subviews) {
        [badView removeFromSuperview];
    }
    snoozeCell.accessoryView = nil;
    snoozeCell.textLabel.text = @"";
    
    if (indexPath.section == 0) {
        snoozeCell.textLabel.text = @"Enabled";
        UISwitch *snoozeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [snoozeSwitch setOn:[self.snoozeEnabled boolValue] animated:NO];
        [snoozeSwitch addTarget:self action:@selector(snoozeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        snoozeCell.accessoryView = snoozeSwitch;
    } else if (indexPath.section == 1) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(155, 12, 150, 21)];
        [textField setFont:[UIFont systemFontOfSize:16]];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.delegate = self;
        if (indexPath.row == 0) {
            /*PSSegmentableSlider *snoozeCountSlider = [[%c(PSSegmentableSlider) alloc] initWithFrame:CGRectMake(15, 5, 315, 34)];
            [snoozeCountSlider setSegmented:YES];
            [snoozeCountSlider setSegmentCount:4];
            [snoozeCell.contentView addSubview:snoozeCountSlider];*/
            snoozeCell.textLabel.text = @"Snooze Count";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"Allowed Attempts";
            NSString *text = [self.snoozeCount stringValue];
            textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ snooze", text] : [NSString stringWithFormat:@"%@ snoozes", text];
            textField.tag = 2;
            [textField addTarget:self action:@selector(snoozeCountTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [snoozeCell.contentView addSubview:textField];
        } else {
            snoozeCell.textLabel.text = @"Snooze Duration";
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.placeholder = @"Minutes";
            NSString *text = [self.snoozeTime stringValue];
            textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ minute", text] : [NSString stringWithFormat:@"%@ minutes", text];
            textField.tag = 3;
            [textField addTarget:self action:@selector(snoozeTimeTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [snoozeCell.contentView addSubview:textField];
        }
    } else if (indexPath.section == 2) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(230, 12, 100, 21)];
        [textField setFont:[UIFont systemFontOfSize:16]];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.delegate = self;
        if (indexPath.row == 0) {
            snoozeCell.textLabel.text = @"Volume While Snoozed";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"0 - 100%";
            NSString *volume = [self.snoozeVolume stringValue];
            if ([volume isEqualToString:@"0"]) {
                textField.text = @"Pause";
            } else {
                textField.text = [NSString stringWithFormat:@"%@%%", volume];
            }
            textField.tag = 4;
            [textField addTarget:self action:@selector(snoozeVolumeTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [snoozeCell.contentView addSubview:textField];
        } else {
            snoozeCell.textLabel.text = @"Fade In Time After Snooze";
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.placeholder = @"Minutes";
            NSString *text = [self.snoozeVolumeTime stringValue];
            textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ minute", text] : [NSString stringWithFormat:@"%@ minutes", text];
            textField.tag = 5;
            [textField addTarget:self action:@selector(snoozeVolumeTimeTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [snoozeCell.contentView addSubview:textField];
        }
    }
    return snoozeCell;
}
/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 2) {
		UIView *tableFooterContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 30)];
		
		UILabel *tableFooter = [[UILabel alloc] initWithFrame:CGRectMake(15, 23/3, 320, 15)];
		tableFooter.text = @"Capitalization matters";
		tableFooter.font = [UIFont systemFontOfSize:13];
		tableFooter.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.576 alpha:1];
		
		[tableFooterContainer addSubview:tableFooter];
		return tableFooterContainer;
	}
	return nil;
}*/

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 2) {
        textField.text = [self.snoozeCount stringValue];
    } else if (textField.tag == 3) {
        textField.text = [self.snoozeTime stringValue];
    } else if (textField.tag == 4) {
        textField.text = [self.snoozeVolume stringValue];
    } else if (textField.tag == 5) {
        textField.text = [self.snoozeVolumeTime stringValue];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 2) {
        NSString *text = [self.snoozeCount stringValue];
        textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ snooze", text] : [NSString stringWithFormat:@"%@ snoozes", text];
    } else if (textField.tag == 3) {
        NSString *text = [self.snoozeTime stringValue];
        textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ minute", text] : [NSString stringWithFormat:@"%@ minutes", text];
    } else if (textField.tag == 4) {
        NSString *volume = [self.snoozeVolume stringValue];
        if ([volume isEqualToString:@"0"]) {
            textField.text = @"Pause";
        } else {
            textField.text = [NSString stringWithFormat:@"%@%%", volume];
        }
    } else if (textField.tag == 5) {
        NSString *text = [self.snoozeVolumeTime stringValue];
        textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ minute", text] : [NSString stringWithFormat:@"%@ minutes", text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)snoozeSwitchChanged:(UISwitch *)snoozeSwitch {
    self.snoozeEnabled = @(snoozeSwitch.on);
    self.snoozeSettingsChanged = YES;

    NSArray *path = @[[NSIndexPath indexPathForRow:0 inSection:1], [NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:0 inSection:2], [NSIndexPath indexPathForRow:1 inSection:2]];

	[self.tableView beginUpdates];
	if (snoozeSwitch.on) {
		[self.tableView insertRowsAtIndexPaths:path withRowAnimation:UITableViewRowAnimationFade];
	} else {
		[self.tableView deleteRowsAtIndexPaths:path withRowAnimation:UITableViewRowAnimationFade];
	}
	[self.tableView endUpdates];
}
- (void)snoozeCountTextFieldChanged:(UITextField *)textField {
    self.snoozeCount = @([textField.text intValue]);
    self.snoozeSettingsChanged = YES;
}

- (void)snoozeTimeTextFieldChanged:(UITextField *)textField {
    self.snoozeTime = @([textField.text floatValue]);
    self.snoozeSettingsChanged = YES;
}
- (void)snoozeVolumeTextFieldChanged:(UITextField *)textField {
    self.snoozeVolume = @([textField.text intValue]);
    self.snoozeSettingsChanged = YES;
}
- (void)snoozeVolumeTimeTextFieldChanged:(UITextField *)textField {
    self.snoozeVolumeTime = @([textField.text floatValue]);
    self.snoozeSettingsChanged = YES;
}


@end