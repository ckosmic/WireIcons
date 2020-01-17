ARCHS = armv7 arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = wireiconsprefs

wireiconsprefs_FILES = WIPRootListController.m
wireiconsprefs_INSTALL_PATH = /Library/PreferenceBundles
wireiconsprefs_FRAMEWORKS = UIKit
wireiconsprefs_PRIVATE_FRAMEWORKS = Preferences
wireiconsprefs_CFLAGS = -fobjc-arc
wireiconsprefs_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/wireiconsprefs.plist$(ECHO_END)
