BINARIES=InputMethodHinter-console InputMethodHinter-launch

X86_TARGET=x86_64-apple-macos10.11
ARM_TARGET=arm64-apple-macos10.15

all: $(BINARIES) app zip

# https://stackoverflow.com/questions/71084674/hot-to-compile-a-swift-script-to-a-universal-binary

InputMethodHinter-console: InputMethodHinter.swift
	swiftc $< -target $(X86_TARGET) -o $@--$(X86_TARGET)
	xattr -cr . ; codesign -fs codesign $@--$(X86_TARGET)
	swiftc $< -target $(ARM_TARGET) -o $@--$(ARM_TARGET)
	xattr -cr . ; codesign -fs codesign $@--$(ARM_TARGET)
	lipo -create $@--$(X86_TARGET) $@--$(ARM_TARGET) -output $@
	xattr -cr . ; codesign -fs codesign $@

InputMethodHinter-launch: InputMethodHinter-launch.c
	$(CC) -o3 $< -target $(X86_TARGET) -o $@--$(X86_TARGET)
	xattr -cr . ; codesign -fs codesign $@--$(X86_TARGET)
	$(CC) -o3 $< -target $(ARM_TARGET) -o $@--$(ARM_TARGET)
	xattr -cr . ; codesign -fs codesign $@--$(ARM_TARGET)
	lipo -create $@--$(X86_TARGET) $@--$(ARM_TARGET) -output $@
	xattr -cr . ; codesign -fs codesign $@

# https://stackoverflow.com/questions/1596945/building-osx-app-bundle
# https://stackoverflow.com/questions/27474751/how-can-i-codesign-an-app-without-being-in-the-mac-developer-program

app: $(BINARIES)
	rm -rf InputMethodHinter.app
	cp -a InputMethodHinter.app-template InputMethodHinter.app
	mkdir -p InputMethodHinter.app/Contents/{Resources,MacOS,Frameworks}
	cp $(BINARIES) InputMethodHinter.app/Contents/MacOS/
	#ln -s InputMethodHinter-launch InputMethodHinter.app/Contents/MacOS/InputMethodHinter
	cp InputMethodHinter-launch InputMethodHinter.app/Contents/MacOS/InputMethodHinter
	#install_name_tool -add_rpath "@executable_path" InputMethodHinter.app/Contents/MacOS/InputMethodHinter-console
	install_name_tool -add_rpath "@loader_path" InputMethodHinter.app/Contents/MacOS/InputMethodHinter-console
	cp /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift-5.0/macosx/* InputMethodHinter.app/Contents/MacOS/
	cp /Library/Developer/CommandLineTools/usr/lib/swift-5.0/macosx/* InputMethodHinter.app/Contents/MacOS/
	xattr -cr .
	codesign -fs codesign --deep InputMethodHinter.app/Contents/MacOS/InputMethodHinter-console  # have to do it after adding rpath
	codesign -fs codesign InputMethodHinter.app  # --deep?
	#codesign -dvv --req - InputMethodHinter.app

zip: app
	rm -f InputMethodHinter.zip; zip -qr InputMethodHinter.zip InputMethodHinter.app

clean:
	rm -rf \
		$(BINARIES) \
		InputMethodHinter-{console,launch}--* \
		InputMethodHinter.app \
		.ccls-cache \
		#

.PHONY: all clean app zip
