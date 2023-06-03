#!/usr/bin/swift

// import Foundation
import Carbon
import AppKit
import Cocoa

import SwiftUI

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

func drawText(_ image: NSImage, _ text: String) -> NSImage {
    let font = NSFont.systemFont(ofSize: image.size.height*3/4, weight: .medium)
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
    text.draw(in: CGRect(x: 0, y: -1, width: image.size.width, height: image.size.height), withAttributes: textFontAttributesBg)
    text.draw(in: CGRect(x: 0, y:  1, width: image.size.width, height: image.size.height), withAttributes: textFontAttributesBg)
    text.draw(in: CGRect(x: -1, y: 0, width: image.size.width, height: image.size.height), withAttributes: textFontAttributesBg)
    text.draw(in: CGRect(x:  1, y: 0, width: image.size.width, height: image.size.height), withAttributes: textFontAttributesBg)
    text.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), withAttributes: textFontAttributes)
    im.unlockFocus()
    // TODO: dynamic window size: https://developer.apple.com/documentation/foundation/nsstring/1531844-size
    return im
}

let window = NSWindow()

let width = 100  // 40
let height = 30
let size = NSMakeSize(CGFloat(width), CGFloat(height))

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
window.level = .floating
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
window.makeKeyAndOrderFront(nil)

window.backgroundColor = NSColor(
    patternImage: drawText(NSImage(
                    size:NSMakeSize(CGFloat(width), CGFloat(height)),
                    flipped: false,
                    drawingHandler: { (NSRect) -> Bool in
                let context = NSGraphicsContext.current?.cgContext
                context?.setFillColor(BG3.cgColor)
                context?.fill(CGRect(x: 0, y: 0, width: width, height: height))
                return true
            }
        ), "abc文яфж"))
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
// about.icon = drawText(NSImage(
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
    <p>Version 0.1</p>
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

        var pos = getNextWindowPos()
        pos.x += 10.0
        pos.y += CGFloat(height/2)
        // pos.x -= CGFloat(width/2)
        // pos.y -= CGFloat(height/2)
        window.setFrameOrigin(cocoaScreenPoint(fromCarbonScreenPoint: pos))

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
        let image2 = drawText(image1, inputMethod)
        window.backgroundColor = NSColor(patternImage: image2)

        window.alphaValue = 1.0
        NSAnimationContext.beginGrouping()
        NSAnimationContext.current.duration = 1.5
        window.animator().alphaValue = 0
        NSAnimationContext.endGrouping()
    }
}

let monitor = NSEvent.addGlobalMonitorForEvents(matching: [
        .leftMouseUp,
        .rightMouseUp,
        .otherMouseUp,
        .flagsChanged]) { (event: NSEvent) in
    onEvent(event)
}

let app = NSApplication.shared
app.run()




///////////////////////////////////////////////////////////////////////////////

func getCurrentInputSource() -> String {
    guard let inputSourceUnmanaged = TISCopyCurrentKeyboardInputSource() else { return "" }
    let inputSource = inputSourceUnmanaged.takeRetainedValue()
    let localizedName = Unmanaged<AnyObject>.fromOpaque(TISGetInputSourceProperty(inputSource, kTISPropertyLocalizedName)).takeUnretainedValue()
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

