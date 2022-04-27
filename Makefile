export TARGET = iphone:clang:13.5:13.0

INSTALL_TARGET_PROCESSES = SpringBoard
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Aurore

ARCHS = arm64
# change default toolchain to use hikari
TARGET_CC=/opt/theos/toolchain/XcodeDefault1.xctoolchain/usr/bin/clang
TARGET_CXX=/opt/theos/toolchain/XcodeDefault1.xctoolchain/usr/bin/clang++

Aurore_FILES = $(wildcard *.xm) $(wildcard */*.xm)
Aurore_CFLAGS = -fobjc-arc #-mllvm -enable-strcry -mllvm -enable-cffobf -mllvm -enable-bcfobf -mllvm -enable-indibran
#tools/crypto.h_CFLAGS = -mllvm -enable-strcry -mllvm -enable-cffobf -mllvm -enable-bcfobf -mllvm -enable-indibran
Aurore_LIBRARIES = MobileGestalt
Aurore_PRIVATE_FRAMEWORKS = MediaRemote, OnBoardingKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += aurorePreferences
include $(THEOS_MAKE_PATH)/aggregate.mk


after-install::
	install.exec "killall -9 Music & killall -9 Spotify & killall -9 mobiletimerd";
