.PHONY: archive
archive:
	swift package generate-xcodeproj; \
	carthage build --archive

.PHONY: build
build:
	swift build

.PHONY: lint
lint:
	swiftlint
