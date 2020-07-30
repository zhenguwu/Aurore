#import "AURDismissController.h"
#import "../tools/constants.h"

@implementation AURDismissController
- (NSString *)topTitle {
    return @"Dismiss Button";
}

- (NSString *)plistName {
	return @"Dismiss";
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    if (!tweakSettings[[specifier properties][@"key"]]) {
        return [specifier properties][@"default"];
    }
    return tweakSettings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    if ([[NSFileManager defaultManager] fileExistsAtPath:drmPath]) {
        NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
        [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
        [defaults setObject:value forKey:[specifier properties][@"key"]];
        [defaults writeToFile:prefsPath atomically:YES];
    }
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    if (![preferences[@"dismissShouldColor"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"color"], self.savedSpecifiers[@"alpha"]] animated:NO];
    }
}

@end