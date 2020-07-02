#import "../tools/helpers.h"
#import "auroreModal.h"


@implementation auroreModal

- (id)initWithTitle:(id)arg1 detailText:(id)arg2 {
    self = [super initWithTitle:arg1 detailText:arg2 icon:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/AurorePrefs.bundle/iconLarge.png"]];
    self.modalPresentationStyle = UIModalPresentationPageSheet;
    self.modalInPresentation = YES;
    return self;
}
- (OBBoldTrayButton *)buttonForStyle:(NSInteger)style {
    OBBoldTrayButton *button = [OBBoldTrayButton buttonWithType:1];
    [button setClipsToBounds:YES];
    [button.layer setCornerRadius:15];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    if (style == 0) {
        [button setTitle:@"Continue" forState:UIControlStateNormal];
    } else if (style == 1) {
        [button setTitle:@"Dismiss" forState:UIControlStateNormal];
    } else if (style == 2) {
        [button setTitle:@"Purchase" forState:UIControlStateNormal];
    } else if (style == 3) {
        [button setTitle:@"Respring" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(respring) forControlEvents:UIControlEventTouchUpInside];
    
        OBBoldTrayButton *resetButton = [OBBoldTrayButton buttonWithType:1];
        resetButton.clipsToBounds = YES;
        resetButton.layer.cornerRadius = 15;
        [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        resetButton.backgroundColor = [UIColor redColor];
        [resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        [resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];

        [self.buttonTray addButton:button];
        [self.buttonTray addButton:resetButton];
        return nil;
    }
    [self.buttonTray addButton:button];
    return button;
}
- (void)presentModal {
    UIWindow *foundWindow = nil;
    for (UIWindow *window in [[UIApplication sharedApplication]windows]) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    if ([foundWindow class] == [%c(SBHomeScreenWindow) class]) {
        self.homeWindowTemp = (SBHomeScreenWindow*)foundWindow;
        self.origWindowLevel = foundWindow.windowLevel;
        foundWindow.windowLevel = 26;
    }
    [foundWindow.rootViewController presentViewController:self animated:YES completion:nil];
}
- (void)respring {
    respring();
}
- (void)reset {
    if (reset()) {
        respring();
    } else {
        postAlert(@"Aurore", @"Error Cleaning Files");
    }
}
- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.homeWindowTemp) {
            self.homeWindowTemp.windowLevel = self.origWindowLevel;
            self.homeWindowTemp = nil;
            self.origWindowLevel = nil;
        }
    }];
}

- (void)viewDidDisappear:(BOOL)arg1 {
    [self dismissModal];
    [super viewDidDisappear:arg1];
}

@end