#import "AURDefaultsController.h"
#import "../tools/constants.h"

@implementation AURDefaultsController
- (NSString *)topTitle {
    return @"Defaults";
}

- (NSString *)plistName {
	return @"Defaults";
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    if (!tweakSettings[[specifier properties][@"key"]]) {
        return [specifier properties][@"default"];
    }
    return tweakSettings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    if ([[NSFileManager defaultManager] fileExistsAtPath:drmPath]) {
        NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
        [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:defaultsPath]];
        NSString *key = [specifier properties][@"key"];
        if ([key isEqualToString:@"volumeMax"] || [key isEqualToString:@"volumeTime"] || [key isEqualToString:@"snoozeCount"] || [key isEqualToString:@"snoozeTime"] || [key isEqualToString:@"snoozeVolume"] || [key isEqualToString:@"snoozeVolumeTime"] || [key isEqualToString:@"dismissAction"]) {
            [defaults setObject:@([value floatValue]) forKey:key];
        } else {
            [defaults setObject:value forKey:key];
        }
        [defaults writeToFile:defaultsPath atomically:YES];
    }
}

@end