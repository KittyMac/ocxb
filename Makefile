SWIFT_BUILD_FLAGS=--configuration release
PROJECTNAME := $(shell basename `pwd`)

.PHONY: all build clean xcode

all: build

build:
	swift build $(SWIFT_BUILD_FLAGS) --triple arm64-apple-macosx
	swift build $(SWIFT_BUILD_FLAGS) --triple x86_64-apple-macosx
	lipo -create -output .build/release/${PROJECTNAME} .build/arm64-apple-macosx/release/${PROJECTNAME} .build/x86_64-apple-macosx/release/${PROJECTNAME}
	cp .build/release/ocxb ./bin/ocxb

clean:
	rm -rf .build

update:
	swift package update

run:
	swift run $(SWIFT_BUILD_FLAGS)
	
test:
	swift test --configuration debug

xcode:
	swift package generate-xcodeproj
