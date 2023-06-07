#!/usr/bin/swift

// import Foundation
import Carbon
import AppKit
import Cocoa

import SwiftUI

let version = "0.2"

let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false as NSNumber]
let accessibilityEnabled = AXIsProcessTrusted() || AXIsProcessTrustedWithOptions(options)
if !accessibilityEnabled {
    let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    // let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
    NSWorkspace.shared.open(URL(string: urlString)!)
    // exit(0)
}

//NSApplication.shared.setActivationPolicy(.accessory)

var FG = NSColor.textColor
var BG = NSColor.textBackgroundColor
var BG2 = NSColor.windowBackgroundColor
var BG3 = NSColor.selectedTextBackgroundColor

var windowSize = 0.05
var height = Int((NSScreen.screens.first?.frame.size.height ?? 1666) * windowSize)
var width = height * 5
var size = NSMakeSize(CGFloat(width), CGFloat(height))
var isBigWindow = true
let greetText = "文    Input Method Hinter   Ж"

func setBigWindow() {
    isBigWindow = true
    windowSize = 0.05
    height = Int((NSScreen.screens.first?.frame.size.height ?? 1666) * windowSize)
    width = height * 4 / 3
    size = NSMakeSize(CGFloat(width), CGFloat(height))
    window.setContentSize(size)
    FG = NSColor.white
    BG = NSColor.black
    BG2 = NSColor.windowBackgroundColor
    BG3 = NSColor.selectedTextBackgroundColor
    animationDurationHold = 0.1
}

func setSmallWindow() {
    isBigWindow = false
    windowSize = 0.025
    height = Int((NSScreen.screens.first?.frame.size.height ?? 1666) * windowSize)
    width = height * 3
    size = NSMakeSize(CGFloat(width), CGFloat(height))
    window.setContentSize(size)
    FG = NSColor.textColor
    BG = NSColor.textBackgroundColor
    BG2 = NSColor.windowBackgroundColor
    BG3 = NSColor.selectedTextBackgroundColor
    animationDurationHold = 0.5
}

func genIndicationImage(_ inputMethod: String) -> NSImage {
    if isBigWindow {
        var image1 = NSImage(
            size:NSMakeSize(CGFloat(width), CGFloat(height)),
            flipped: false,
            drawingHandler: { (NSRect) -> Bool in
                let context = NSGraphicsContext.current?.cgContext
                context?.setFillColor(BG2.withAlphaComponent(0.2).cgColor)
                context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
                return true
            }
        )
        if let flag = im2icon[getCurrentInputSourceId()] {
            image1 = drawOverImg(image1, flag, isIcon: true)
        }
        let image2 = drawOverImg(image1, inputMethod)
        return image2
    } else {
        let image1 = NSImage(
            size:NSMakeSize(CGFloat(width), CGFloat(height)),
            flipped: false,
            drawingHandler: { (NSRect) -> Bool in
                let context = NSGraphicsContext.current?.cgContext
                context?.setFillColor(BG2.withAlphaComponent(0.2).cgColor)
                context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
                return true
            }
        )
        let flag = im2icon[getCurrentInputSourceId()] ?? ""
        let image2 = drawOverImg(image1, flag + inputMethod)
        return image2
    }
}

func drawOverImg(_ image: NSImage, _ text: String, isIcon: Bool = false) -> NSImage {
    let fontSize = isIcon ?
        image.size.height*3/2 :
        isBigWindow ? image.size.height*3/10 : image.size.height*3/4
    let fonWeight = isIcon ? NSFont.Weight.black : NSFont.Weight.medium
    let font = NSFont.systemFont(ofSize: fontSize, weight: fonWeight)
    let textPos = isBigWindow && !isIcon ? image.size.height/2 - font.pointSize*4/3 : 0
    let textStyle = NSParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
    textStyle.alignment = .center
    textStyle.lineBreakMode = .byClipping
    let shadow = NSShadow()
    shadow.shadowOffset = NSMakeSize(0, 0)
    shadow.shadowBlurRadius = image.size.height/20
    shadow.shadowColor = BG
    let textFontAttributes = [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: FG,
        NSAttributedString.Key.paragraphStyle: textStyle,
        NSAttributedString.Key.shadow: shadow
    ]
    let textFontAttributesBg = [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: BG.withAlphaComponent(0.8),
        NSAttributedString.Key.paragraphStyle: textStyle
    ]
    let im : NSImage = NSImage(size: image.size)
    let rep : NSBitmapImageRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(image.size.width),
        pixelsHigh: Int(image.size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: NSColorSpaceName.calibratedRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0)!
    im.addRepresentation(rep)
    im.lockFocus()
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    if isIcon {
        text.draw(in: CGRect(
            x: -image.size.height / 4,
            y: -image.size.height * 0.4,
            width:  image.size.width  + image.size.height*2/4,
            height: image.size.height + image.size.height*2*0.4),
            withAttributes: textFontAttributes)
    } else {
        let txDrawHeight = isBigWindow ? font.pointSize*2 : image.size.height
        text.draw(in: CGRect(x:  0, y: textPos-1, width: image.size.width, height: txDrawHeight), withAttributes: textFontAttributesBg)
        text.draw(in: CGRect(x:  0, y: textPos+1, width: image.size.width, height: txDrawHeight), withAttributes: textFontAttributesBg)
        text.draw(in: CGRect(x: -1, y: textPos  , width: image.size.width, height: txDrawHeight), withAttributes: textFontAttributesBg)
        text.draw(in: CGRect(x:  1, y: textPos  , width: image.size.width, height: txDrawHeight), withAttributes: textFontAttributesBg)
        text.draw(in: CGRect(x:  0, y: textPos  , width: image.size.width, height: txDrawHeight), withAttributes: textFontAttributes)
    }
    im.unlockFocus()
    // TODO: dynamic window size: https://developer.apple.com/documentation/foundation/nsstring/1531844-size
    return im
}

let window = NSWindow()

window.styleMask.insert(.fullSizeContentView)
window.styleMask.insert(.borderless)
window.styleMask.subtract(.closable)
window.styleMask.subtract(.resizable)
window.styleMask.subtract(.miniaturizable)
window.titleVisibility = .hidden
window.titlebarAppearsTransparent = true
window.isMovableByWindowBackground = true
window.isOpaque = false
window.hasShadow = false
window.level = .screenSaver
window.ignoresMouseEvents = true  // click-through
window.isRestorable = false
window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
window.standardWindowButton(.closeButton)?.isHidden = true
window.standardWindowButton(.zoomButton)?.isHidden = true
window.standardWindowButton(.miniaturizeButton)?.isHidden = true
window.setContentSize(size)
// window.minSize = size
// window.maxSize = size
let mouse = NSEvent.mouseLocation
window.setFrame(CGRect(x: Int(mouse.x)-width, y: Int(mouse.y) - height/2, width: width, height: height), display: true)
window.center()
window.makeKeyAndOrderFront(nil)

window.backgroundColor = NSColor(
    patternImage: drawOverImg(NSImage(
                    size:NSMakeSize(CGFloat(width), CGFloat(height)),
                    flipped: false,
                    drawingHandler: { (NSRect) -> Bool in
                let context = NSGraphicsContext.current?.cgContext
                context?.setFillColor(BG3.cgColor)
                context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
                return true
            }
        ), greetText))
// Make it like a splash screen at startup
window.alphaValue = 1.0
NSAnimationContext.beginGrouping()
NSAnimationContext.current.duration = 7
window.animator().alphaValue = 0
NSAnimationContext.endGrouping()

// https://stackoverflow.com/questions/64949572/how-to-create-status-bar-icon-and-menu-in-macos-using-swiftui
let statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
statusBarItem.button?.title = "️文"
let menu = NSMenu()
menu.autoenablesItems = false
statusBarItem.menu = menu

//// BUG:
//// 1. Modal dialoig is neither getting focus nor popping above all windows.
//// 2. Until the modal dialog is closed, the app's main thread is hanging.
// class Alert: NSAlert { @objc func action() {
//     NSApplication.shared.activate(ignoringOtherApps: true)
//     self.window.makeKeyAndOrderFront(_: nil)
//     self.runModal()
//     self.window.resignKey()
// }}
// let about = Alert()
// about.window.isRestorable = false
// about.messageText = "About"
// about.informativeText = "MacOS Input Method Hinter\n\n© 2023 by Yury Ershov\n\nhttps://github.com/ershov/InputMethodHinter"
// about.alertStyle = .informational
// about.icon = drawOverImg(NSImage(
//                     size:NSMakeSize(128.0, 128.0),
//                     flipped: false,
//                     drawingHandler: { (NSRect) -> Bool in
//                 let context = NSGraphicsContext.current?.cgContext
//                 context?.setFillColor(BG3.cgColor)
//                 context?.fill(CGRect(x: 0, y: 0, width: 128, height: 128))
//                 return true
//             }
//         ), "文")
// let aboutMenuItem = NSMenuItem(title: "About", action: #selector(about.action), keyEquivalent: "")
// aboutMenuItem.target = about
// menu.addItem(aboutMenuItem)

//// Using "About" menu item instead of proper dialog window.
class About { @objc func action() {
    guard let url = URL(string: "https://github.com/ershov/InputMethodHinter") else { return }
    NSWorkspace.shared.open(url)
}}
let about = About()

let about2MenuItem = NSMenuItem(title: "About", action: #selector(about.action), keyEquivalent: "")
about2MenuItem.target = about
let aboutHtml = """
    <style>* { font-family: Arial; text-align: center; } big { font-size: 50pt }</style>
    <h2><big>文</big></h2>
    <h2>About</h2>
    <p>MacOS Input Method Hinter</p>
    <p>© 2023 by Yury Ershov</p>
    <p><a href='https://github.com/ershov/InputMethodHinter'>https://github.com/ershov/InputMethodHinter</a></p>
    <p>Version \(version)</p>
    """
var dict: NSDictionary? = NSMutableDictionary()
about2MenuItem.attributedTitle = try! NSAttributedString(
    data: Data(bytes: UnsafePointer<Int8>((aboutHtml as NSString).utf8String)!, count: aboutHtml.data(using: .utf8)!.count),
    options: [
        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
        NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
    ],
    documentAttributes: &dict)
menu.addItem(about2MenuItem)

menu.addItem(NSMenuItem.separator())

let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
menu.addItem(quitMenuItem)

var animationDurationHold = 0.5
let animationDurationFade = 1.5

var animTimer : DispatchSourceTimer?
func setTimeout(_ delay: Double, _ closure: @escaping () -> Void) {
    cancelTimeout()
    animTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
    guard let timer = animTimer else { animTimer = nil; return }
    timer.setEventHandler {
        closure()
    }
    timer.schedule(deadline: .now() + delay, repeating: .never)
    timer.resume()
}
func cancelTimeout() {
    animTimer?.cancel()
    animTimer = nil
}

func animateWindow1() {
    setTimeout(animationDurationHold) {
        window.alphaValue = 1.0
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = animationDurationFade
        window.animator().alphaValue = 0
        NSAnimationContext.endGrouping()
        animateWindow2()
    }
}
func animateWindow2() {
    setTimeout(animationDurationFade) {
        window.center()
        cancelTimeout()
    }
}

func animateWindow() {
    window.alphaValue = 1.0
    animateWindow1()
}

extension NSEvent {
    func isKeyboardEvent() -> Bool {
        return self.type == .keyDown || self.type == .keyUp || self.type == .flagsChanged
    }
}

// https://github.com/ghawkgu/isHUD/blob/master/isHUD/ISHKeyCode.h
var inputMethod = ""
var activeWindow = ""
var maxKeysPressed: UInt = 0
let modifiersMask: UInt = (NSEvent.ModifierFlags.capsLock.rawValue | NSEvent.ModifierFlags.shift.rawValue | NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.numericPad.rawValue | NSEvent.ModifierFlags.help.rawValue | NSEvent.ModifierFlags.function.rawValue | NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue)
let interestingKeysMask: UInt = (NSEvent.ModifierFlags.capsLock.rawValue | NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.option.rawValue | NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.function.rawValue)
let forceIndicationKeys: UInt = (NSEvent.ModifierFlags.control.rawValue | NSEvent.ModifierFlags.function.rawValue)
func onEvent(_ event: NSEvent) {
    // if event.isARepeat { return }
    var userRequestedIndication = false
    if event.type == .flagsChanged {
        let keyMask: UInt = event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue // modifiersMask
        maxKeysPressed |= keyMask
        if keyMask != 0 { return }
        // All keys released
        let lastMaxKeysPressed = maxKeysPressed
        maxKeysPressed = 0
        // Fn+Ctrl forces indication
        userRequestedIndication = lastMaxKeysPressed == forceIndicationKeys
        // Any of interesting keys were pressed?
        if ((lastMaxKeysPressed & interestingKeysMask) == 0) && !userRequestedIndication { return }
    }
    // Wait for windows to activate and input method to switch
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        let lastInputMethod = inputMethod;         inputMethod = getCurrentInputSource()
        let lastActiveWindow = activeWindow;       activeWindow = "\(getActiveWindowId()) \(isActiveTextInput())"
        if !userRequestedIndication && lastInputMethod == inputMethod{
            if !isActiveTextInput() { return }
            if lastActiveWindow == activeWindow { return }
        }

        if event.isKeyboardEvent() {
            setBigWindow()
        } else {
            setSmallWindow()
        }

        let pos = {() -> NSPoint in
            if event.isKeyboardEvent(), let winPos = getActiveWindowCoord() {
                return NSPoint(x: winPos.x - window.frame.width / 2, y: winPos.y - window.frame.height / 2)
            } else {
                var pos = getNextWindowPos()
                pos.x += 10.0
                pos.y += CGFloat(height/2)
                return cocoaScreenPoint(fromCarbonScreenPoint: pos)
            }
        }()
        //window.setFrameOrigin(pos)
        window.setFrame(NSRect(x: Int(pos.x), y: Int(pos.y), width: width, height: height), display: true)

        window.backgroundColor = NSColor(patternImage: genIndicationImage(inputMethod))

        animateWindow()
    }
}

let monitor = NSEvent.addGlobalMonitorForEvents(matching: [
        .leftMouseUp,
        .rightMouseUp,
        .otherMouseUp,
        .flagsChanged]) { (event: NSEvent) in
    onEvent(event)
}





///////////////////////////////////////////////////////////////////////////////

func getCurrentInputSource() -> String {
    guard let inputSourceUnmanaged = TISCopyCurrentKeyboardInputSource() else { return "" }
    let inputSource = inputSourceUnmanaged.takeRetainedValue()
    let localizedName = Unmanaged<AnyObject>.fromOpaque(TISGetInputSourceProperty(inputSource, kTISPropertyLocalizedName)).takeUnretainedValue()
    return "\(localizedName)"
}

func getCurrentInputSourceId() -> String {
    guard let inputSourceUnmanaged = TISCopyCurrentKeyboardInputSource() else { return "" }
    let inputSource = inputSourceUnmanaged.takeRetainedValue()
    let localizedName = Unmanaged<AnyObject>.fromOpaque(TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID)).takeUnretainedValue()
    return "\(localizedName)"
}

func getFrontMostApp() -> NSRunningApplication? {
    // let runningApps = NSWorkspace.shared.runningApplications
    // let activeApp = runningApps.first { $0.isActive == true }
    // return activeApp
    return NSWorkspace.shared.frontmostApplication
}

func getActiveWindowId() -> String {
    // based on https://stackoverflow.com/a/74262682/3191958
    guard let activeApp = NSWorkspace.shared.frontmostApplication else { return "" }
    return (CGWindowListCopyWindowInfo([.excludeDesktopElements, .optionOnScreenOnly], kCGNullWindowID) as [AnyObject]?)?
        .first { $0.object(forKey: kCGWindowOwnerPID) as? pid_t == activeApp.processIdentifier }
        .flatMap { $0.object(forKey: kCGWindowNumber) as CFString? }?
        .flatMap { "\(activeApp.processIdentifier) \($0)" }
        ?? ""
}

func isActiveTextInput() -> Bool {
    // Don't have accessibility access
    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false as NSNumber]
    if !AXIsProcessTrusted() && !AXIsProcessTrustedWithOptions(options) { return true }

    let system = AXUIElementCreateSystemWide()  // AXUIElement
    guard let activeAppElement = getAXUIElementAttributeValue(system, kAXFocusedApplicationAttribute) else { return false }
    guard let focusedElement = getAXUIElementAttributeValue(activeAppElement, kAXFocusedUIElementAttribute) else { return false }
    guard let role = getAXUIElementAttributeValue(focusedElement, kAXRoleAttribute) else { return false }
    guard let roleString = role as? String else { return false }
    return roleString == kAXTextFieldRole || roleString == kAXTextAreaRole
}

func getNextWindowPos() -> NSPoint {
    return cocoaScreenPoint(fromCarbonScreenPoint: NSEvent.mouseLocation)
}

func getAXUIElementAttributeValue(_ element: AnyObject?, _ attribute: String) -> AnyObject? {
    guard let element else { return nil }
    var value: AnyObject?
    let err = AXUIElementCopyAttributeValue(element as! AXUIElement, attribute as CFString, &value)
    if err != .success { return nil }
    return value
}

func cocoaScreenPoint(fromCarbonScreenPoint carbonPoint: NSPoint) -> NSPoint {
    return NSPoint(x: carbonPoint.x, y: (NSScreen.screens.first?.frame.size.height ?? 0) - carbonPoint.y)
    // return NSPoint(x: carbonPoint.x, y: (NSScreen.main?.frame.size.height ?? 0) - carbonPoint.y)
}

func cocoaScreenRect(fromCarbonScreenRect carbonPoint: CGRect) -> NSRect {
    return NSRect(
        x: carbonPoint.origin.x,
        y: (NSScreen.screens.first?.frame.size.height ?? 0) - carbonPoint.origin.y - carbonPoint.size.height,
        width: carbonPoint.size.width,
        height: carbonPoint.size.height)
}

func getActiveWindowCoord() -> NSPoint? {
    guard let application = getFrontMostApp() else { return nil }
    let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
    let windowsListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
    let infoList = windowsListInfo as! [[String:Any]]
    let visibleWindows = infoList.filter {
        $0["kCGWindowLayer"] as! Int == 0 &&
        $0["kCGWindowOwnerPID"] as! Int == application.processIdentifier }
    if visibleWindows.count == 0 { return nil }
    var bounds = CGRect()
    if !CGRectMakeWithDictionaryRepresentation(visibleWindows[0]["kCGWindowBounds"] as! CFDictionary, &bounds) { return nil }
    return cocoaScreenPoint(fromCarbonScreenPoint: NSPoint(x: bounds.midX, y: bounds.midY))
}

let im2icon: [String: String] = [
    "com.apple.keylayout.Czech-QWERTY": "🇨🇿",
    "com.apple.keylayout.Czech": "🇨🇿",
    "com.apple.keylayout.Estonian": "🇪🇪",
    "com.apple.keylayout.Hungarian-QWERTY": "🇭🇺",
    "com.apple.keylayout.Hungarian": "🇭🇺",
    "com.apple.keylayout.Latvian": "🇱🇻",
    "com.apple.keylayout.Lithuanian": "🇱🇹",
    "com.apple.keylayout.PolishPro": "🇵🇱",
    "com.apple.keylayout.Polish": "🇵🇱",
    "com.apple.keylayout.Slovak": "🇸🇰",
    "com.apple.keylayout.Slovak-QWERTY": "🇸🇰",
    "com.apple.keylayout.Bulgarian-Phonetic": "🇧🇬",
    "com.apple.keylayout.Bulgarian": "🇧🇬",
    "com.apple.keylayout.Byelorussian": "🇧🇪",
    "com.apple.keylayout.Macedonian": "🇲🇰",
    "com.apple.keylayout.Russian-Phonetic": "🇷🇺",
    "com.apple.keylayout.Russian": "🇷🇺",
    "com.apple.keylayout.RussianWin": "🇷🇺",
    "com.apple.keylayout.Serbian": "🇷🇸",
    "com.apple.keylayout.Ukrainian-PC": "🇺🇦",
    "com.apple.keylayout.Ukrainian": "🇺🇦",
    //"com.apple.keylayout.Colemak": "",
    //"com.apple.keylayout.Dvorak-Left": "",
    //"com.apple.keylayout.Dvorak-Right": "",
    //"com.apple.keylayout.Dvorak": "",
    //"com.apple.keylayout.DVORAK-QWERTYCMD": "",
    "com.apple.keylayout.KANA": "🇯🇵",
    "com.apple.keylayout.ABC-AZERTY": "🇫🇷",
    "com.apple.keylayout.ABC-QWERTZ": "🇩🇪",
    "com.apple.keylayout.ABC": "🇺🇸",
    "com.apple.keylayout.Australian": "🇦🇺",
    "com.apple.keylayout.Austrian": "🇦🇹",
    "com.apple.keylayout.Belgian": "🇧🇪",
    "com.apple.keylayout.Brazilian-ABNT2": "🇧🇷",
    "com.apple.keylayout.Brazilian-Pro": "🇧🇷",
    "com.apple.keylayout.Brazilian": "🇧🇷",
    "com.apple.keylayout.British-PC": "🇬🇧",
    "com.apple.keylayout.British": "🇬🇧",
    "com.apple.keylayout.Canadian-CSA": "🇨🇦",
    "com.apple.keylayout.Canadian": "🇨🇦",
    "com.apple.keylayout.CanadianFrench-PC": "🇨🇦",
    "com.apple.keylayout.Danish": "🇩🇰",
    "com.apple.keylayout.Dutch": "🇳🇱",
    "com.apple.keylayout.Finnish": "🇫🇮",
    "com.apple.keylayout.French-PC": "🇫🇷",
    "com.apple.keylayout.French-numerical": "🇫🇷",
    "com.apple.keylayout.French": "🇫🇷",
    "com.apple.keylayout.German": "🇩🇪",
    "com.apple.keylayout.Irish": "🇮🇪",
    "com.apple.keylayout.Italian-Pro": "🇮🇹",
    "com.apple.keylayout.Italian": "🇮🇹",
    "com.apple.keylayout.Norwegian": "🇳🇴",
    "com.apple.keylayout.Portuguese": "🇵🇹",
    "com.apple.keylayout.Spanish-ISO": "🇪🇸",
    "com.apple.keylayout.Spanish": "🇪🇸",
    "com.apple.keylayout.Swedish-Pro": "🇸🇪",
    "com.apple.keylayout.Swedish": "🇸🇪",
    "com.apple.keylayout.SwissFrench": "🇨🇭🇫🇷",
    "com.apple.keylayout.SwissGerman": "🇨🇭🇩🇪",
    "com.apple.keylayout.Tongan": "🇹🇴",
    "com.apple.keylayout.US": "🇺🇸",
    "com.apple.keylayout.USInternational-PC": "🇺🇸",
    "com.apple.keylayout.2SetHangul": "🇰🇷",
    "com.apple.keylayout.ABC-India": "🇮🇳",
    "com.apple.keylayout.Adlam-QWERTY": "🇬🇳",
    "com.apple.keylayout.AfghanDari": "🇦🇫",
    "com.apple.keylayout.AfghanPashto": "🇦🇫",
    "com.apple.keylayout.AfghanUzbek": "🇦🇫",
    "com.apple.keylayout.Akan": "🇬🇭",
    "com.apple.keylayout.Albanian": "🇦🇱",
    "com.apple.keylayout.Anjal": "🇮🇳",
    "com.apple.keylayout.Apache": "🇺🇸",
    "com.apple.keylayout.Arabic-AZERTY": "🇸🇦",
    "com.apple.keylayout.Arabic-NorthAfrica": "🇸🇦",
    "com.apple.keylayout.Arabic-QWERTY": "🇸🇦",
    "com.apple.keylayout.Arabic": "🇸🇦",
    "com.apple.keylayout.ArabicPC": "🇸🇦",
    "com.apple.keylayout.Armenian-HMQWERTY": "🇦🇲",
    "com.apple.keylayout.Armenian-WesternQWERTY": "🇦🇲",
    "com.apple.keylayout.Assamese": "🇮🇳",
    "com.apple.keylayout.Azeri": "🇦🇿",
    "com.apple.keylayout.Bangla-QWERTY": "🇧🇩",
    "com.apple.keylayout.Bangla": "🇧🇩",
    "com.apple.keylayout.Bodo": "🇮🇳",
    "com.apple.keylayout.CangjieKeyboard": "🇹🇼",
    "com.apple.keylayout.Cherokee-Nation": "🇺🇸",
    "com.apple.keylayout.Cherokee-QWERTY": "🇺🇸",
    "com.apple.keylayout.Chickasaw": "🇺🇸",
    "com.apple.keylayout.Choctaw": "🇺🇸",
    "com.apple.keylayout.Croatian": "🇭🇷",
    "com.apple.keylayout.Croatian-PC": "🇭🇷",
    "com.apple.keylayout.Devanagari-QWERTY": "🇮🇳",
    "com.apple.keylayout.Devanagari": "🇮🇳",
    "com.apple.keylayout.Dhivehi-QWERTY": "🇲🇻",
    "com.apple.keylayout.Dogri": "🇮🇳",
    "com.apple.keylayout.Dzongkha": "🇧🇹",
    "com.apple.keylayout.Faroese": "🇫🇴",
    "com.apple.keylayout.FinnishExtended": "🇫🇮",
    "com.apple.keylayout.FinnishSami-PC": "🇫🇮",
    "com.apple.keylayout.Geez-QWERTY": "🇪🇹",
    "com.apple.keylayout.Georgian-QWERTY": "🇬🇪",
    "com.apple.keylayout.German-DIN-2137": "🇩🇪",
    "com.apple.keylayout.Greek": "🇬🇷",
    "com.apple.keylayout.GreekPolytonic": "🇬🇷",
    "com.apple.keylayout.Gujarati-QWERTY": "🇮🇳",
    "com.apple.keylayout.Gujarati": "🇮🇳",
    "com.apple.keylayout.Gurmukhi-QWERTY": "🇮🇳",
    "com.apple.keylayout.Gurmukhi": "🇮🇳",
    "com.apple.keylayout.Hanifi-Rohingya-QWERTY": "🇲🇲",
    "com.apple.keylayout.Hausa": "🇳🇬",
    "com.apple.keylayout.Hawaiian": "🇺🇸",
    "com.apple.keylayout.Hebrew-QWERTY": "🇮🇱",
    "com.apple.keylayout.Hebrew": "🇮🇱",
    "com.apple.keylayout.Hebrew-PC": "🇮🇱",
    "com.apple.keylayout.Icelandic": "🇮🇸",
    "com.apple.keylayout.Igbo": "🇳🇬",
    "com.apple.keylayout.Inuktitut-Nattilik": "🇨🇦",
    "com.apple.keylayout.Inuktitut-Nunavut": "🇨🇦",
    "com.apple.keylayout.Inuktitut-Nutaaq": "🇨🇦",
    "com.apple.keylayout.Inuktitut-QWERTY": "🇨🇦",
    "com.apple.keylayout.InuttitutNunavik": "🇨🇦",
    "com.apple.keylayout.IrishExtended": "🇮🇪",
    "com.apple.keylayout.Jawi-QWERTY": "🇲🇾",
    "com.apple.keylayout.Kannada-QWERTY": "🇮🇳",
    "com.apple.keylayout.Kannada": "🇮🇳",
    "com.apple.keylayout.Kashmiri-Devanagari": "🇮🇳",
    "com.apple.keylayout.Kazakh": "🇰🇿",
    "com.apple.keylayout.Khmer": "🇰🇭",
    "com.apple.keylayout.Konkani": "🇮🇳",
    "com.apple.keylayout.Kurdish-Kurmanji": "🇮🇶",
    "com.apple.keylayout.Kurdish-Sorani": "🇮🇶",
    "com.apple.keylayout.Kyrgyz-Cyrillic": "🇰🇬",
    "com.apple.keylayout.Lao": "🇱🇦",
    "com.apple.keylayout.LatinAmerican": "🇲🇽",
    "com.apple.keylayout.Maithili": "🇮🇳",
    "com.apple.keylayout.Malayalam-QWERTY": "🇮🇳",
    "com.apple.keylayout.Malayalam": "🇮🇳",
    "com.apple.keylayout.Maltese": "🇲🇹",
    "com.apple.keylayout.Manipuri-Bengali": "🇮🇳",
    "com.apple.keylayout.Manipuri-MeeteiMayek": "🇮🇳",
    "com.apple.keylayout.Maori": "🇳🇿",
    "com.apple.keylayout.Marathi": "🇮🇳",
    "com.apple.keylayout.Mongolian-Cyrillic": "🇲🇳",
    "com.apple.keylayout.Myanmar-QWERTY": "🇲🇲",
    "com.apple.keylayout.Myanmar": "🇲🇲",
    "com.apple.keylayout.Navajo": "🇺🇸",
    "com.apple.keylayout.Nepali-IS16350": "🇳🇵",
    "com.apple.keylayout.Nepali": "🇳🇵",
    "com.apple.keylayout.NorthernSami": "🇳🇴",
    "com.apple.keylayout.NorwegianExtended": "🇳🇴",
    "com.apple.keylayout.NorwegianSami-PC": "🇳🇴",
    "com.apple.keylayout.Oriya-QWERTY": "🇮🇳",
    "com.apple.keylayout.Oriya": "🇮🇳",
    "com.apple.keylayout.Persian-QWERTY": "🇮🇷",
    "com.apple.keylayout.Persian": "🇮🇷",
    "com.apple.keylayout.Persian-ISIRI2901": "🇮🇷",
    "com.apple.keylayout.Romanian-Standard": "🇷🇴",
    "com.apple.keylayout.Romanian": "🇷🇴",
    "com.apple.keylayout.Sami-PC": "🇸🇪",
    "com.apple.keylayout.Samoan": "🇼🇸",
    "com.apple.keylayout.Sanskrit": "🇮🇳",
    "com.apple.keylayout.Santali-Devanagari": "🇮🇳",
    "com.apple.keylayout.Santali-OlChiki": "🇮🇳",
    "com.apple.keylayout.Serbian-Latin": "🇷🇸",
    "com.apple.keylayout.Sindhi-Devanagari": "🇮🇳",
    "com.apple.keylayout.Sindhi": "🇵🇰",
    "com.apple.keylayout.Sinhala-QWERTY": "🇱🇰",
    "com.apple.keylayout.Sinhala": "🇱🇰",
    "com.apple.keylayout.Slovenian": "🇸🇮",
    "com.apple.keylayout.SwedishSami-PC": "🇸🇪",
    "com.apple.keylayout.Syriac-Arabic": "🇸🇾",
    "com.apple.keylayout.Syriac-QWERTY": "🇸🇾",
    "com.apple.keylayout.Tajik-Cyrillic": "🇹🇯",
    "com.apple.keylayout.Tamil99": "🇮🇳",
    "com.apple.keylayout.Telugu-QWERTY": "🇮🇳",
    "com.apple.keylayout.Telugu": "🇮🇳",
    "com.apple.keylayout.Thai-PattaChote": "🇹🇭",
    "com.apple.keylayout.Thai": "🇹🇭",
    "com.apple.keylayout.TibetanOtaniUS": "🇨🇳",
    "com.apple.keylayout.Tibetan-QWERTY": "🇨🇳",
    "com.apple.keylayout.Tibetan-Wylie": "🇨🇳",
    "com.apple.keylayout.Transliteration-bn": "🇧🇩",
    "com.apple.keylayout.Transliteration-gu": "🇮🇳",
    "com.apple.keylayout.Transliteration-hi": "🇮🇳",
    "com.apple.keylayout.Transliteration-kn": "🇮🇳",
    "com.apple.keylayout.Transliteration-ml": "🇮🇳",
    "com.apple.keylayout.Transliteration-mr": "🇮🇳",
    "com.apple.keylayout.Transliteration-pa": "🇮🇳",
    "com.apple.keylayout.Transliteration-ta": "🇮🇳",
    "com.apple.keylayout.Transliteration-te": "🇮🇳",
    "com.apple.keylayout.Transliteration-ur": "🇵🇰",
    "com.apple.keylayout.Turkish-QWERTY-PC": "🇹🇷",
    "com.apple.keylayout.Turkish-QWERTY": "🇹🇷",
    "com.apple.keylayout.Turkish-Standard": "🇹🇷",
    "com.apple.keylayout.Turkish": "🇹🇷",
    "com.apple.keylayout.Turkmen": "🇹🇲",
    "com.apple.keylayout.USExtended": "🇺🇸",
    "com.apple.keylayout.Ukrainian-QWERTY": "🇺🇦",
    //"com.apple.keylayout.UnicodeHexInput": "",
    "com.apple.keylayout.Urdu": "🇵🇰",
    "com.apple.keylayout.Uyghur": "🇨🇳",
    "com.apple.keylayout.Uzbek-Cyrillic": "🇺🇿",
    "com.apple.keylayout.Vietnamese": "🇻🇳",
    "com.apple.keylayout.Welsh": "🇬🇧",
    "com.apple.keylayout.Yiddish-QWERTY": "🇮🇱",
    "com.apple.keylayout.Yoruba": "🇳🇬",
    "com.apple.keylayout.ZhuyinBopomofo": "🇹🇼",
    "com.apple.keylayout.GJCRomaja": "🇰🇷",
    "com.apple.keylayout.390Hangul": "🇰🇷",
    "com.apple.keylayout.HNCRomaja": "🇰🇷",
    "com.apple.keylayout.3SetHangul": "🇰🇷",
    "com.apple.keylayout.PinyinKeyboard": "🇨🇳",
    "com.apple.keylayout.WubihuaKeyboard": "🇨🇳",
    "com.apple.keylayout.TraditionalWubihuaKeyboard": "🇭🇰",
    "com.apple.keylayout.ZhuyinEten": "🇹🇼",
    "com.apple.keylayout.TraditionalPinyinKeyboard": "🇹🇼",
    "org.unknown.keylayout.Русская-BG46": "🇷🇺",
    //"com.apple.inputmethod.PluginIM": "🇺🇸",
    "com.apple.SyntheticRomanMode": "🇺🇸",
    "com.apple.inputmethod.VietnameseIM": "🇻🇳",
    "com.apple.inputmethod.Korean": "🇰🇷",
    "com.apple.inputmethod.Ainu": "🇯🇵",
    "com.apple.inputmethod.SCIM": "🇨🇳",
    "com.apple.inputmethod.ChineseHandwriting": "🇭🇰",
    "com.apple.inputmethod.Kotoeri.KanaTyping": "🇯🇵",
    "com.apple.inputmethod.EmojiFunctionRowItem": "😇",
    "com.apple.50onPaletteIM": "😀",
    //"com.apple.inputmethod.AssistiveControl": "♿",
    //"com.apple.inputmethod.ironwood": "",
    "com.apple.inputmethod.Kotoeri.RomajiTyping": "🇯🇵",
    "com.apple.inputmethod.TYIM": "🇭🇰",
    //"com.apple.PressAndHold": "",
    "com.apple.inputmethod.Tamil": "🇮🇳",
    "com.apple.inputmethod.TransliterationIM": "🇮🇳",
    "com.apple.CharacterPaletteIM": "🔢",
    "com.apple.inputmethod.TCIM": "🇹🇼",
    "com.apple.inputmethod.VietnameseIM.VietnameseVNI": "🇻🇳",
    "com.apple.inputmethod.VietnameseIM.VietnameseVIQR": "🇻🇳",
    "com.apple.inputmethod.VietnameseIM.VietnameseSimpleTelex": "🇻🇳",
    "com.apple.inputmethod.VietnameseIM.VietnameseTelex": "🇻🇳",
    "com.apple.inputmethod.Korean.2SetKorean": "🇰🇷",
    "com.apple.inputmethod.Korean.390Sebulshik": "🇰🇷",
    "com.apple.inputmethod.Korean.3SetKorean": "🇰🇷",
    "com.apple.inputmethod.Korean.GongjinCheongRomaja": "🇰🇷",
    "com.apple.inputmethod.Korean.HNCRomaja": "🇰🇷",
    "com.apple.inputmethod.AinuIM.Ainu": "🇯🇵",
    "com.apple.inputmethod.SCIM.ITABC": "🇨🇳",
    "com.apple.inputmethod.SCIM.Shuangpin": "🇨🇳",
    "com.apple.inputmethod.SCIM.WBX": "🇨🇳",
    "com.apple.inputmethod.SCIM.WBH": "🇨🇳",
    "com.apple.inputmethod.Kotoeri.KanaTyping.Japanese.Katakana": "🇯🇵",
    "com.apple.inputmethod.Kotoeri.KanaTyping.Japanese.HalfWidthKana": "🇯🇵",
    "com.apple.inputmethod.Kotoeri.KanaTyping.Roman": "🇺🇸",
    "com.apple.inputmethod.Kotoeri.KanaTyping.Japanese.FullWidthRoman": "🇯🇵",
    "com.apple.inputmethod.Kotoeri.KanaTyping.Japanese": "🇯🇵",
    "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese.Katakana": "🇯🇵",
    "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese.HalfWidthKana": "🇯🇵",
    "com.apple.inputmethod.Kotoeri.RomajiTyping.Roman": "🇺🇸",
    "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese.FullWidthRoman": "🇯🇵",
    "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese": "🇯🇵",
    "com.apple.inputmethod.TYIM.Stroke": "🇭🇰",
    "com.apple.inputmethod.TYIM.Sucheng": "🇭🇰",
    "com.apple.inputmethod.TYIM.Cangjie": "🇭🇰",
    "com.apple.inputmethod.TYIM.Phonetic": "🇭🇰",
    "com.apple.inputmethod.Tamil.AnjalIM": "🇮🇳",
    "com.apple.inputmethod.Tamil.Tamil99": "🇮🇳",
    "com.apple.inputmethod.TransliterationIM.mr": "🇮🇳",
    "com.apple.inputmethod.TransliterationIM.pa": "🇮🇳",
    "com.apple.inputmethod.TransliterationIM.ur": "🇵🇰",
    "com.apple.inputmethod.TransliterationIM.gu": "🇮🇳",
    "com.apple.inputmethod.TransliterationIM.hi": "🇮🇳",
    "com.apple.inputmethod.TransliterationIM.bn": "🇧🇩",
    "com.apple.inputmethod.TCIM.WBH": "🇹🇼",
    "com.apple.inputmethod.TCIM.Zhuyin": "🇹🇼",
    "com.apple.inputmethod.TCIM.Cangjie": "🇹🇼",
    "com.apple.inputmethod.TCIM.ZhuyinEten": "🇹🇼",
    "com.apple.inputmethod.TCIM.Jianyi": "🇹🇼",
    "com.apple.inputmethod.TCIM.Pinyin": "🇹🇼",
    "com.apple.inputmethod.TCIM.Shuangpin": "🇹🇼",
]








let app = NSApplication.shared
app.run()
