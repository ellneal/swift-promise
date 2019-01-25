.PHONY: archive
archive:
	make generate-xcodeproj; \
	carthage build --archive

.PHONY: build
build:
	swift build

.PHONY: generate-xcodeproj
generate-xcodeproj:
	rm -rf Promise.xcodeproj/; \
	swift package generate-xcodeproj \
		--xcconfig-overrides Config/Config.xcconfig

.PHONY: lint
lint:
	swiftlint
