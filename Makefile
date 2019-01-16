.PHONY: archive
archive:
	generate-xcodeproj; \
	carthage build --archive

.PHONY: build
build:
	swift build

.PHONY: generate-xcodeproj
generate-xcodeproj:
	rm -rf Promise.xcodeproj/; \
	swift package generate-xcodeproj \
		--xcconfig-overrides Config.xcconfig

.PHONY: lint
lint:
	swiftlint
