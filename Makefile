SWIFT_DEV_PM_FLAGS += --package-path $(CURDIR)/Development/ -Xswiftc -suppress-warnings
CONFIG_FILE=$(CURDIR)/Config/Config.xcconfig
VERSION_CONFIG_FILE=$(CURDIR)/Config/Version.xcconfig

.PHONY: archive build lint open test xcconfig xcodeproj

archive: xcodeproj
	swift run $(SWIFT_DEV_PM_FLAGS) carthage build --archive

build: xcconfig
	swift build

lint:
	swift run $(SWIFT_DEV_PM_FLAGS) swiftlint

open: Promise.xcodeproj
	xed .

test:
	swift test

xcconfig:
	echo "CURRENT_PROJECT_VERSION=$$(git describe --abbrev=0 --tags | cut -c 2-)" > \
		$(VERSION_CONFIG_FILE)

xcodeproj: xcconfig
	swift package generate-xcodeproj \
		--xcconfig-overrides $(CONFIG_FILE)

Promise.xcodeproj:
	swift package generate-xcodeproj \
		--xcconfig-overrides $(CONFIG_FILE)
