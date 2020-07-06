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
    self.shortcut = settings[@"shortcut"];
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
        [self.delegate auroreOthersTableControllerUpdateShowWeather:self.showWeather dismissAction:self.dismissAction shortcut:self.shortcut];
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
            [self.delegate auroreOthersTableControllerUpdateShowWeather:self.showWeather dismissAction:self.dismissAction shortcut:self.shortcut];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3) {
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
        othersCell.textLabel.text = @"Coming Soon";
    } else if (indexPath.section == 2) {
        othersCell.textLabel.text = @"Run Shortcut";
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(130, 12, 200, 21)];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setFont:[UIFont systemFontOfSize:16]];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.placeholder = @"Shortcut Name";
        textField.text = self.shortcut;
        [textField addTarget:self action:@selector(shortcutTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [othersCell.contentView addSubview:textField];
    } else {
        if (indexPath.row == 0) {

        } else if (indexPath.row == 1) {

        } else {

        }
        othersCell.textLabel.text = @"Coming Soon";
    }
    return othersCell;
}

- (void)weatherSwitchChanged:(UISwitch *)weatherSwitch {
    self.showWeather = @(weatherSwitch.on);
    self.othersSettingsChanged = YES;

}
- (void)shortcutTextFieldChanged:(UITextField *)textField {
    self.shortcut = textField.text;
    self.othersSettingsChanged = YES;
}

@end