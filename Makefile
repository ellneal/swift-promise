.PHONY: archive
archive:
	make generate-version-xcconfig; \
	make generate-xcodeproj; \
	carthage build --archive

.PHONY: build
build:
	make generate-version-xcconfig; \
	swift build

.PHONY: generate-version-xcconfig
generate-version-xcconfig:
	echo "CURRENT_PROJECT_VERSION=$$(git describe --abbrev=0 --tags | cut -c 2-)" > \
		$(CURDIR)/Config/Version.xcconfig

.PHONY: generate-xcodeproj
generate-xcodeproj:
	rm -rf Promise.xcodeproj/; \
	swift package generate-xcodeproj \
		--xcconfig-overrides Config/Config.xcconfig

.PHONY: lint
lint:
	swift run --package-path Development/ swiftlint
