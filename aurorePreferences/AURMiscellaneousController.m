#import "AURMiscellaneousController.h"
#import "../tools/constants.h"

@implementation AURMiscellaneousController
- (NSString *)topTitle {
    return @"Miscellaneous";
}

- (NSString *)plistName {
	return @"Miscellaneous";
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    if (!tweakSettings[[specifier properties][@"key"]]) {
        return [specifier properties][@"default"];
    }
    return tweakSettings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/com.zhenguwu.aurore.list"]) {
        NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
        [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
        [defaults setObject:value forKey:[specifier properties][@"key"]];
        [defaults writeToFile:prefsPath atomically:YES];
    }
}


@end