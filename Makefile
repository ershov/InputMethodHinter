BINARIES=InputMethodHinter-console InputMethodHinter-app

all: $(BINARIES) app

# https://stackoverflow.com/questions/71084674/hot-to-compile-a-swift-script-to-a-universal-binary

InputMethodHinter-console: InputMethodHinter.swift
	swiftc $< -target x86_64-apple-macos10.15 -o $@-x86_64
	xattr -cr . ; codesign -fs codesign $@-x86_64
	swiftc $< -target arm64-apple-macos10.15 -o $@-arm64
	xattr -cr . ; codesign -fs codesign $@-arm64
	lipo -create $@-x86_64 $@-arm64 -output $@
	xattr -cr . ; codesign -fs codesign $@

InputMethodHinter-app: InputMethodHinter-launch.c
	$(CC) -o3 $< -target x86_64-apple-macos10.15 -o InputMethodHinter-app-x86_64
	xattr -cr . ; codesign -fs codesign $@-x86_64
	$(CC) -o3 $< -target arm64-apple-macos10.15 -o InputMethodHinter-app-arm64
	xattr -cr . ; codesign -fs codesign $@-arm64
	lipo -create $@-x86_64 $@-arm64 -output $@
	xattr -cr . ; codesign -fs codesign $@

# https://stackoverflow.com/questions/1596945/building-osx-app-bundle
# https://stackoverflow.com/questions/27474751/how-can-i-codesign-an-app-without-being-in-the-mac-developer-program

InputMethodHinter.app: $(BINARIES)
	mkdir -p InputMethodHinter.app/Contents/{Resources,MacOS}
	cp $(BINARIES) InputMethodHinter.app/Contents/MacOS/
	#ln -s InputMethodHinter-app InputMethodHinter.app/Contents/MacOS/InputMethodHinter
	cp InputMethodHinter-app InputMethodHinter.app/Contents/MacOS/InputMethodHinter
	xattr -cr .
	codesign -fs codesign --deep InputMethodHinter.app
	codesign -dvv --req - InputMethodHinter.app

app: InputMethodHinter.app

clean:
	rm -f \
		$(BINARIES) \
		InputMethodHinter-{console,app}-{x86_64,arm64} \
		InputMethodHinter.app/Contents/MacOS/InputMethodHinter* \
		.ccls-cache

.PHONY: all clean app

