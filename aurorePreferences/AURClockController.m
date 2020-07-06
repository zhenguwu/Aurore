#import "AURClockController.h"
#import "../tools/constants.h"
#import "../tools/helpers.h"

@implementation AURClockController
- (NSString *)topTitle {
    return @"Clock App";
}

- (NSString *)plistName {
	return @"Clock";
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:clockPrefsPath];
    if (!tweakSettings[[specifier properties][@"key"]]) {
        return [specifier properties][@"default"];
    }
    return tweakSettings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.zhenguwu.aurore.list"]) {
        NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
        [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:clockPrefsPath]];
        [defaults setObject:value forKey:[specifier properties][@"key"]];
        [defaults writeToFile:clockPrefsPath atomically:YES];
        killApp(@"MobileTimer");
    }
}

@end