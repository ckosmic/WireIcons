ARCHS = armv7 arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WireIcons

WireIcons_FILES = Tweak.x
WireIcons_CFLAGS = -fobjc-arc
WireIcons_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += wireiconsprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
