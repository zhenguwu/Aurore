#import "auroreSnoozeTableViewController.h"

@implementation auroreSnoozeTableViewController
- (id)initWithSettings:(NSDictionary *)settings {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    self.snoozeEnabled = settings[@"snoozeEnabled"];
    self.snoozeCount = settings[@"snoozeCount"];
    self.snoozeTime = settings[@"snoozeTime"];
    self.snoozeVolume = settings[@"snoozeVolume"];
    self.snoozeVolumeTime = settings[@"snoozeVolumeTime"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Snooze Options";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 2) {
        return 3;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *snoozeCell = [tableView dequeueReusableCellWithIdentifier:@"auroreCell"];
    if (snoozeCell == nil) {
        snoozeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"auroreCell"];
        snoozeCell.backgroundColor = [UIColor colorWithRed:0.172549 green:0.172549 blue:0.180392 alpha:1.0];
        snoozeCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(160, 12, 200, 21)];
    [textField setReturnKeyType:UIReturnKeyDone];
    tectField.autocorrectionType = UITextAutocorrectionTypeNo;
    if (indexPath.section == 0) {
        snoozeCell.textLabel.text = @"Snooze";
        UISwitch *snoozeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [snoozeSwitch setOn:[self.snoozeEnabled boolValue] animated:NO];
        snoozeCell.accessoryView = snoozeSwitch;
    } else if (indexPath.section == 1) {
        ;
    } else {
        if (indexPath.row == 0) {
            snoozeCell.textLabel.text = @"Snooze Duration";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"Seconds";
            textField.text = [self.snoozeTime stringValue];
            [snoozeCell.contentView addSubview:textField];

        } else if (indexPath.row == 1) {
            snoozeCell.textLabel.text = @"Snooze Volume";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"0 - 100";
            textField.text = [self.snoozeVolume stringValue];
            [snoozeCell.contentView addSubview:textField];
        } else {
            snoozeCell.textLabel.text = @"Volume Time";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"After Snooze";
            textField.text = [self.snoozeVolumeTime stringValue];
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
@end