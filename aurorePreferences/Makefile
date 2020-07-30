export ARCHS=arm64
export TARGET = iphone:clang:13.5:13.0
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AurorePrefs

TARGET_CC=/opt/theos/toolchain/XcodeDefault.xctoolchain/usr/bin/clang
TARGET_CXX=/opt/theos/toolchain/XcodeDefault.xctoolchain/usr/bin/clang++

AurorePrefs_FILES = $(wildcard *.m)
AurorePrefs_INSTALL_PATH = /Library/PreferenceBundles
AurorePrefs_FRAMEWORKS = UIKit
AurorePrefs_PRIVATE_FRAMEWORKS = Preferences
AurorePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Aurore.plist$(ECHO_END)
