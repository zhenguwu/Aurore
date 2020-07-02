#import "auroreMusicTableViewController.h"

@implementation auroreMusicTableViewController
- (id)initWithSettings:(NSDictionary *)settings {
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    self.link = settings[@"link"];
    self.shuffle = settings[@"shuffle"];
    self.volumeMax = settings[@"volumeMax"];
    self.volumeTime = settings[@"volumeTime"];
    self.bluetooth = settings[@"bluetooth"];
    self.airplay = settings[@"airplay"];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Music Options";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *musicCell = [tableView dequeueReusableCellWithIdentifier:@"auroreCell"];
    if (musicCell == nil) {
        musicCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"auroreCell"];
        musicCell.backgroundColor = [UIColor colorWithRed:0.172549 green:0.172549 blue:0.180392 alpha:1.0];
        musicCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(130, 12, 200, 21)];
    [textField setReturnKeyType:UIReturnKeyDone];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            musicCell.textLabel.text = @"Music Link";
            textField.keyboardType = UIKeyboardTypeURL;
            textField.placeholder = @"Paste URL Here";
            textField.text = self.link;
            [musicCell.contentView addSubview:textField];
        } else {
            musicCell.textLabel.text = @"Shuffle";
            UISwitch *shuffleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
			[shuffleSwitch setOn:[self.shuffle boolValue] animated:NO];
			musicCell.accessoryView = shuffleSwitch;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            musicCell.textLabel.text = @"Max Volume";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"0 - 100";
            textField.text = [self.volumeMax stringValue];
            [musicCell.contentView addSubview:textField];

        } else {
            musicCell.textLabel.text = @"Volume Time";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"Seconds to Max";
            textField.text = [self.volumeTime stringValue];
            [musicCell.contentView addSubview:textField];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            musicCell.textLabel.text = @"Bluetooth";
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.placeholder = @"Device Name";
            textField.text = self.bluetooth;
            [musicCell.contentView addSubview:textField];
        } else {
            musicCell.textLabel.text = @"AirPlay";
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.placeholder = @"Device Name";
            textField.text = self.airplay;
            [musicCell.contentView addSubview:textField];
        }
    }
    return musicCell;
}

/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
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