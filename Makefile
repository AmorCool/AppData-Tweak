# AppData — Rootless tweak for iOS 26 (Dopamine 3 + ElleKit)
# Builds a .deb containing the AppData tweak dylib + the AppDataPrefs preference bundle.

ARCHS = arm64 arm64e
TARGET = iphone:clang::13.0

include $(THEOS)/makefiles/common.mk

# ---------- Tweak (injects into SpringBoard) ----------
TWEAK_NAME = AppData
AppData_FILES = AppData.xm \
	AppData/Classes/Controller/ADDataViewController.m \
	AppData/Classes/Controller/Cells/ADActionsBarView.m \
	AppData/Classes/Controller/Cells/ADExpandableSectionHeaderView.m \
	AppData/Classes/Controller/Cells/ADTitleSectionHeaderView.m \
	AppData/Classes/Controller/DataSource/ADMainDataSource.m \
	AppData/Classes/Controller/DataSource/ADMoreDataSource.m \
	AppData/Classes/Helpers/ADAppearance.m \
	AppData/Classes/Helpers/ADHelper.m \
	AppData/Classes/Helpers/ADSettings.m \
	AppData/Classes/Model/ADAppData.m \
	AppData/Classes/Presentation/ADDataPresentationAnimator.m \
	AppData/Classes/Presentation/ADDataPresentationController.m \
	AppData/Classes/Presentation/ADDataPresentationManager.m \
	AppData/Classes/Tools/ADTCC.m \
	AppData/Classes/Tools/ADTerminator.m \
	AppData/Vendors/NRFileManager/NRFileManager.m

AppData_CFLAGS = -fobjc-arc -Wno-deprecated-declarations \
	-I./include \
	-I./AppData \
	-I./AppData/Classes/Controller \
	-I./AppData/Classes/Controller/Cells \
	-I./AppData/Classes/Controller/DataSource \
	-I./AppData/Classes/Helpers \
	-I./AppData/Classes/Model \
	-I./AppData/Classes/Presentation \
	-I./AppData/Classes/Tools \
	-I./AppData/Vendors/NRFileManager \
	-include AppData/AppData-Prefix.pch
# ElleKit (libellekit) is loaded as the injection substrate at runtime and provides
# MSHookMessageEx / MSHookFunction, so we link with dynamic_lookup instead of
# requiring a vendored libellekit at build time. substrate.h is vendored at ./include.
AppData_LDFLAGS = -Wl,-undefined,dynamic_lookup -framework CoreLocation
AppData_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

# ---------- Preference Bundle (loaded by PreferenceLoader) ----------
BUNDLE_NAME = AppDataPrefs
AppDataPrefs_FILES = AppDataPrefs/ADPreferencesController.m \
	AppDataPrefs/Classes/ADPrefsHelper.m \
	AppDataPrefs/Classes/Cells/ADHeaderTableViewCell.m \
	AppDataPrefs/Classes/Cells/ADSwitchTableViewCell.m \
	AppDataPrefs/Classes/Controllers/ADSelectListTableViewController.m

AppDataPrefs_CFLAGS = -fobjc-arc -Wno-deprecated-declarations \
	-I./AppData/Classes/Helpers \
	-I./AppDataPrefs \
	-I./AppDataPrefs/Classes \
	-I./AppDataPrefs/Classes/Cells \
	-I./AppDataPrefs/Classes/Controllers
AppDataPrefs_LDFLAGS = -F./Frameworks -framework Preferences
AppDataPrefs_INSTALL_PATH = /Library/PreferenceBundles

# ---------- Rootless packaging ----------
THEOS_PACKAGE_SCHEME = rootless
THEOS_PACKAGE_SCHEME_VERSION = 2.0
AppData_DEPENDS = ellekit (>= 2.0), preferenceloader (>= 2.2.8)
AppDataPrefs_DEPENDS = preferenceloader (>= 2.2.8)

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk
