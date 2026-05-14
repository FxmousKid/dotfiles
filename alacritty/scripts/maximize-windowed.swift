#!/usr/bin/env swift

import AppKit
import ApplicationServices
import Foundation

struct WindowFrame: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
}

func axPoint(_ element: AXUIElement, _ attribute: CFString) -> CGPoint? {
    var raw: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(element, attribute, &raw)

    guard result == .success, let value = raw, CFGetTypeID(value) == AXValueGetTypeID() else {
        return nil
    }

    var output = CGPoint.zero
    guard AXValueGetValue(value as! AXValue, .cgPoint, &output) else {
        return nil
    }

    return output
}

func axSize(_ element: AXUIElement, _ attribute: CFString) -> CGSize? {
    var raw: CFTypeRef?
    let result = AXUIElementCopyAttributeValue(element, attribute, &raw)

    guard result == .success, let value = raw, CFGetTypeID(value) == AXValueGetTypeID() else {
        return nil
    }

    var output = CGSize.zero
    guard AXValueGetValue(value as! AXValue, .cgSize, &output) else {
        return nil
    }

    return output
}

func setAXPoint(_ element: AXUIElement, _ attribute: CFString, _ value: CGPoint) {
    var mutableValue = value
    guard let axValue = AXValueCreate(.cgPoint, &mutableValue) else {
        return
    }

    AXUIElementSetAttributeValue(element, attribute, axValue)
}

func setAXSize(_ element: AXUIElement, _ attribute: CFString, _ value: CGSize) {
    var mutableValue = value
    guard let axValue = AXValueCreate(.cgSize, &mutableValue) else {
        return
    }

    AXUIElementSetAttributeValue(element, attribute, axValue)
}

func frame(of window: AXUIElement) -> WindowFrame? {
    guard
        let position = axPoint(window, kAXPositionAttribute as CFString),
        let size = axSize(window, kAXSizeAttribute as CFString)
    else {
        return nil
    }

    return WindowFrame(
        x: position.x,
        y: position.y,
        width: size.width,
        height: size.height
    )
}

func setFrame(_ frame: WindowFrame, on window: AXUIElement) {
    setAXPoint(
        window,
        kAXPositionAttribute as CFString,
        CGPoint(x: frame.x, y: frame.y)
    )
    setAXSize(
        window,
        kAXSizeAttribute as CFString,
        CGSize(width: frame.width, height: frame.height)
    )
}

func accessibilityRect(from screenRect: NSRect, maxY: CGFloat) -> CGRect {
    CGRect(
        x: screenRect.minX,
        y: maxY - screenRect.maxY,
        width: screenRect.width,
        height: screenRect.height
    )
}

func nearlyEqual(_ lhs: WindowFrame, _ rhs: WindowFrame) -> Bool {
    let tolerance = 4.0

    return abs(lhs.x - rhs.x) <= tolerance
        && abs(lhs.y - rhs.y) <= tolerance
        && abs(lhs.width - rhs.width) <= tolerance
        && abs(lhs.height - rhs.height) <= tolerance
}

guard AXIsProcessTrusted() else {
    fputs("maximize-windowed: accessibility permission is required\n", stderr)
    exit(1)
}

guard let app = NSWorkspace.shared.frontmostApplication else {
    fputs("maximize-windowed: no frontmost application found\n", stderr)
    exit(1)
}

let appElement = AXUIElementCreateApplication(app.processIdentifier)
var focusedWindowRef: CFTypeRef?
let windowResult = AXUIElementCopyAttributeValue(
    appElement,
    kAXFocusedWindowAttribute as CFString,
    &focusedWindowRef
)

guard windowResult == .success, let focusedWindow = focusedWindowRef else {
    fputs("maximize-windowed: no focused window found\n", stderr)
    exit(1)
}

let window = focusedWindow as! AXUIElement

guard let currentFrame = frame(of: window) else {
    fputs("maximize-windowed: could not read current window frame\n", stderr)
    exit(1)
}

let screens = NSScreen.screens
guard !screens.isEmpty else {
    fputs("maximize-windowed: no screens found\n", stderr)
    exit(1)
}

let maxY = screens.map { $0.frame.maxY }.max() ?? 0
let windowCenter = CGPoint(
    x: currentFrame.x + currentFrame.width / 2,
    y: currentFrame.y + currentFrame.height / 2
)

let selectedScreen = screens.first {
    accessibilityRect(from: $0.frame, maxY: maxY).contains(windowCenter)
} ?? NSScreen.main ?? screens[0]

let targetRect = accessibilityRect(from: selectedScreen.visibleFrame, maxY: maxY)
let targetFrame = WindowFrame(
    x: targetRect.minX,
    y: targetRect.minY,
    width: targetRect.width,
    height: targetRect.height
)

let cacheURL = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent("alacritty-windowed-maximize-\(app.processIdentifier).json")

if nearlyEqual(currentFrame, targetFrame),
   let data = try? Data(contentsOf: cacheURL),
   let previousFrame = try? JSONDecoder().decode(WindowFrame.self, from: data) {
    setFrame(previousFrame, on: window)
    try? FileManager.default.removeItem(at: cacheURL)
} else {
    if let data = try? JSONEncoder().encode(currentFrame) {
        try? data.write(to: cacheURL, options: .atomic)
    }
    setFrame(targetFrame, on: window)
}
