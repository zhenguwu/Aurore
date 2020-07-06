#import "auroreMusicTableViewController.h"

@implementation auroreMusicTableViewController
- (id)initWithSettings:(NSDictionary *)settings inset:(BOOL)inset isSleep:(BOOL)isSleep {
    if (inset & !isSleep) {
        self = [super initWithStyle:UITableViewStyleInsetGrouped];
    } else {
        self = [super initWithStyle:UITableViewStyleGrouped];
    }
    self.isSleep = isSleep;
    self.link = settings[@"link"];
    self.linkContext = settings[@"linkContext"];
    self.shuffle = settings[@"shuffle"];
    self.volumeMax = settings[@"volumeMax"];
    self.volumeTime = settings[@"volumeTime"];
    self.bluetooth = settings[@"bluetooth"];
    self.airplay = settings[@"airplay"];
    self.linkChanged = NO;
    self.musicSettingsChanged = NO;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Music Options";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if (self.isSleep) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(returnAndSave)];
    }
}

- (void)returnAndSave {
    if (self.musicSettingsChanged) {
        [self.delegate auroreMusicTableControllerUpdateLink:self.link shuffle:self.shuffle volumeMax:self.volumeMax volumeTime:self.volumeTime bluetooth:self.bluetooth airplay:self.airplay];
        NSString *link = self.link;
        if ( ([link containsString:@"open.spotify.com"] && ([link containsString:@"playlist"] || [link containsString:@"track"])) || ([link containsString:@"music.apple.com"] && ([link containsString:@"playlist"] || [link containsString:@"station"])) ) {
            [self.delegate auroreUpdateLinkContext:YES link:link reload:YES];
        } else {
            if (![link isEqualToString:@""]) {
                self.link = @"";
            }
            self.linkContext = @"";
            [self.delegate auroreUpdateLinkContext:NO link:nil reload:YES];
        }
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
        } else if (self.musicSettingsChanged) {
            [self.delegate auroreMusicTableControllerUpdateLink:self.link shuffle:self.shuffle volumeMax:self.volumeMax volumeTime:self.volumeTime bluetooth:self.bluetooth airplay:self.airplay];
        }
    }
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
        if (self.isSleep) {
            musicCell.backgroundColor = [UIColor blackColor];
        } else {
            musicCell.backgroundColor = [UIColor colorWithRed:0.172549 green:0.172549 blue:0.180392 alpha:1.0];
        }
        musicCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for (UIView *badView in musicCell.contentView.subviews) {
        [badView removeFromSuperview];
    }
    musicCell.accessoryView = nil;
    musicCell.textLabel.text = @"";
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(130, 12, 200, 21)];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setFont:[UIFont systemFontOfSize:16]];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.delegate = self;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            musicCell.textLabel.text = @"Music Link";
            textField.keyboardType = UIKeyboardTypeURL;
            textField.placeholder = @"Paste URL Here";
            if ([self.linkContext isEqualToString:@""]) {
                if (![self.link isEqualToString:@""]) {
                    textField.text = @"Link Loading Error";
                }
            } else {
                textField.text = self.linkContext;
            }
            textField.tag = 1;
            [textField addTarget:self action:@selector(linkTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [musicCell.contentView addSubview:textField];
        } else {
            musicCell.textLabel.text = @"Shuffle";
            UISwitch *shuffleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
			[shuffleSwitch setOn:[self.shuffle boolValue] animated:NO];
            [shuffleSwitch addTarget:self action:@selector(shuffleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            musicCell.accessoryView = shuffleSwitch;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            musicCell.textLabel.text = @"Max Volume";
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.placeholder = @"0 - 100%";
            textField.text = [NSString stringWithFormat:@"%@%%", [self.volumeMax stringValue]];
            textField.tag = 3;
            [textField addTarget:self action:@selector(volumeMaxTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [musicCell.contentView addSubview:textField];

        } else {
            musicCell.textLabel.text = @"Fade In Time";
            textField.keyboardType = UIKeyboardTypeDecimalPad;
            textField.placeholder = @"Minutes to Max";
            NSString *text = [self.volumeTime stringValue];
            textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ minute", text] : [NSString stringWithFormat:@"%@ minutes", text];
            textField.tag = 4;
            [textField addTarget:self action:@selector(volumeTimeTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [musicCell.contentView addSubview:textField];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            musicCell.textLabel.text = @"Bluetooth";
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.placeholder = @"Device Name";
            textField.text = self.bluetooth;
            [textField addTarget:self action:@selector(bluetoothTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
            [musicCell.contentView addSubview:textField];
        } else {
            musicCell.textLabel.text = @"AirPlay";
            textField.keyboardType = UIKeyboardTypeAlphabet;
            textField.placeholder = @"Device Name";
            textField.text = self.airplay;
            [textField addTarget:self action:@selector(aiplayTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
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
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        textField.text = self.link;
        [textField selectAll:nil];
    } else if (textField.tag == 3) {
        textField.text = [self.volumeMax stringValue];
    } else if (textField.tag == 4) {
        textField.text = [self.volumeTime stringValue];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        if (self.linkChanged) {
            if (!self.isSleep) {
                self.linkChanged = NO;
            }
            NSString *link = textField.text;
            if ( ([link containsString:@"open.spotify.com"] && ([link containsString:@"playlist"] || [link containsString:@"track"])) || ([link containsString:@"music.apple.com"] && ([link containsString:@"playlist"] || [link containsString:@"station"])) ) {
                if (!self.isSleep) {
                    self.linkContext = [self.delegate auroreUpdateLinkContext:YES link:link reload:YES];
                    textField.text = self.linkContext;
                }
            } else {
                if (![link isEqualToString:@""]) {
                    textField.text = @"Invalid Link";
                    self.link = @"";
                }
                self.linkContext = @"";
                if (!self.isSleep) {
                    [self.delegate auroreUpdateLinkContext:NO link:nil reload:YES];
                }
            }
        } else {
            if ([self.linkContext isEqualToString:@""]) {
                textField.text = @"Link Loading Error";
            } else {
                textField.text = self.linkContext;
            }
        }
    } else if (textField.tag == 3) {
        textField.text = [NSString stringWithFormat:@"%@%%", [self.volumeMax stringValue]];
    } else if (textField.tag == 4) {
        NSString *text = [self.volumeTime stringValue];
        textField.text = [text isEqualToString:@"1"] ? [NSString stringWithFormat:@"%@ minute", text] : [NSString stringWithFormat:@"%@ minutes", text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)linkTextFieldChanged:(UITextField *)textField {
    self.link = textField.text;
    self.linkChanged = YES;
    self.musicSettingsChanged = YES;
}

- (void)shuffleSwitchChanged:(UISwitch *)shuffleSwitch {
    self.shuffle = @(shuffleSwitch.on);
    self.musicSettingsChanged = YES;
}

- (void)volumeMaxTextFieldChanged:(UITextField *)textField {
    self.volumeMax = @([textField.text floatValue]);
    self.musicSettingsChanged = YES;
}

- (void)volumeTimeTextFieldChanged:(UITextField *)textField {
    self.volumeTime = @([textField.text floatValue]);
    self.musicSettingsChanged = YES;
}

- (void)bluetoothTextFieldChanged:(UITextField *)textField {
    self.bluetooth = textField.text;
    self.musicSettingsChanged = YES;
}

- (void)airplayTextFieldChanged:(UITextField *)textField {
    self.airplay = textField.text;
    self.musicSettingsChanged = YES;
}
@end