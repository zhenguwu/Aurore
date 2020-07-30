#import <spawn.h>
#import <RemoteLog5.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
@end

static void postAlert(NSString *title, NSString *message) {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction* dismissButton = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];

	[alert addAction: dismissButton];

    UIWindow *foundWindow = nil;
    for (UIWindow *window in [[UIApplication sharedApplication]windows]) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
	[foundWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

static void postNotification(NSString *message) {
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.zhenguwu.aurore" object:nil userInfo:@{@"from" : message}];
}

static void launchLink(NSString *link) {
	pid_t pid;
	const char *args[] = {"uiopen", [link UTF8String], NULL, NULL};
	posix_spawn(&pid, "/usr/bin/uiopen", NULL, NULL, (char* const*)args, NULL);
    /*const char *args[] = {"ls", "/var/lib/dpkg/info/or.mr.aurore.list", NULL, NULL};
	posix_spawn(&pid, "/usr/bin/ls", NULL, NULL, (char* const*)args, NULL);
    int success = waitpid(pid, &status, 0);
    RLog(@"%d", success);*/

}

static void respring() {
    pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
}

static void reset() {
    NSError *err;
    if ([[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/Aurore" error:&err]) {
        respring();
    } else {
        postAlert(@"Aurore Error", [NSString stringWithFormat:@"%@", [err localizedDescription]]);
    }

}

static void killApp(NSString *appName) {
    pid_t pid;
    int status;
    const char* args[] = {"killall", "-9", [appName UTF8String], NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, WEXITED);
}
