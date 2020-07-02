export ARCHS=arm64 arm64e
export TARGET = iphone:clang:13.5:13.0

INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Aurore

Aurore_FILES = $(wildcard *.xm) $(wildcard */*.xm)
Aurore_CFLAGS = -fobjc-arc
Aurore_EXTRA_FRAMEWORKS += Cephei
Aurore_PRIVATE_FRAMEWORKS = MediaRemote, OnBoardingKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += aurorePreferences
include $(THEOS_MAKE_PATH)/aggregate.mk


#after-install::
#	install.exec "killall -9 Music & killall -9 mobiletimerd & killall -9 MobileTimer";