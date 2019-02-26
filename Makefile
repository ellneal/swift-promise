.PHONY: archive
archive: version-xcconfig xcodeproj
	carthage build --archive

.PHONY: build
build: version-xcconfig
	make generate-version-xcconfig; \
	swift build

.PHONY: version-xcconfig
version-xcconfig:
	echo "CURRENT_PROJECT_VERSION=$$(git describe --abbrev=0 --tags | cut -c 2-)" > \
		$(CURDIR)/Config/Version.xcconfig

.PHONY: xcodeproj
xcodeproj:
	rm -rf Promise.xcodeproj/; \
	swift package generate-xcodeproj \
		--xcconfig-overrides Config/Config.xcconfig

.PHONY: lint
lint:
	swift run --package-path Development/ swiftlint

.PHONY: open
open: xcodeproj
	xed .

.PHONY: test
test:
	swift test
