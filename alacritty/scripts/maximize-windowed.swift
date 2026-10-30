#!/usr/bin/env swift

//
// maximize-windowed — toggle the focused window between "fills the display it is
// on" and the size it had before, without using native macOS fullscreen.
//
// Multi-display notes, i.e. why this file is fussier than it looks:
//
//   * Cocoa (NSScreen) uses a bottom-left origin with +y going up, anchored to
//     the bottom-left of the PRIMARY display — NSScreen.screens[0].
//   * The Accessibility API uses a top-left origin with +y going down, anchored
//     to the TOP-LEFT of that same primary display.
//
//   The only correct flip is therefore:
//
//       axY = primary.frame.maxY - cocoaRect.maxY
//
//   Deriving that offset from the tallest screen instead (a tempting shortcut,
//   and what this script used to do) is correct only while no display is taller
//   than the primary one. A 1080p monitor next to a 982pt laptop panel breaks
//   it: every rect lands 98pt too low, and the "which screen am I on?" test
//   misses, so the window teleports to the laptop.
//
// Usage: maximize-windowed [--toggle|--maximize|--restore] [--margin N] [--dry-run]
//

import AppKit
import ApplicationServices
import Foundation

// MARK: - Arguments

enum Mode: String {
    case toggle, maximize, restore
}

var mode = Mode.toggle
var margin = Double(ProcessInfo.processInfo.environment["ALACRITTY_MAXIMIZE_MARGIN"] ?? "") ?? 0
var dryRun = false

var pendingArguments = Array(CommandLine.arguments.dropFirst())
while let argument = pendingArguments.first {
    pendingArguments.removeFirst()

    switch argument {
    case "--toggle", "--maximize", "--restore":
        mode = Mode(rawValue: String(argument.dropFirst(2)))!
    case "--margin":
        guard let value = pendingArguments.first.flatMap(Double.init) else {
            fputs("maximize-windowed: --margin needs a number\n", stderr)
            exit(2)
        }
        margin = value
        pendingArguments.removeFirst()
    case "--dry-run":
        dryRun = true
    case "--help", "-h":
        print("usage: maximize-windowed [--toggle|--maximize|--restore] [--margin N] [--dry-run]")
        exit(0)
    default:
        fputs("maximize-windowed: unknown argument \(argument)\n", stderr)
        exit(2)
    }
}

// MARK: - Tolerances

// Alacritty snaps its window to whole character cells, so an applied frame comes
// back a few points short of what we asked for. Positions, however, are exact.
let positionTolerance = 3.0
let cellSlack = 48.0

// MARK: - Accessibility helpers

func axValue(_ element: AXUIElement, _ attribute: String) -> AXValue? {
    var raw: CFTypeRef?

    guard AXUIElementCopyAttributeValue(element, attribute as CFString, &raw) == .success,
          let value = raw,
          CFGetTypeID(value) == AXValueGetTypeID()
    else {
        return nil
    }

    return (value as! AXValue)
}

func axPoint(_ element: AXUIElement, _ attribute: String) -> CGPoint? {
    guard let value = axValue(element, attribute) else {
        return nil
    }

    var point = CGPoint.zero
    return AXValueGetValue(value, .cgPoint, &point) ? point : nil
}

func axSize(_ element: AXUIElement, _ attribute: String) -> CGSize? {
    guard let value = axValue(element, attribute) else {
        return nil
    }

    var size = CGSize.zero
    return AXValueGetValue(value, .cgSize, &size) ? size : nil
}

func axBool(_ element: AXUIElement, _ attribute: String) -> Bool {
    var raw: CFTypeRef?

    guard AXUIElementCopyAttributeValue(element, attribute as CFString, &raw) == .success,
          let value = raw,
          CFGetTypeID(value) == CFBooleanGetTypeID()
    else {
        return false
    }

    return CFBooleanGetValue((value as! CFBoolean))
}

func windowFrame(of window: AXUIElement) -> CGRect? {
    guard let origin = axPoint(window, kAXPositionAttribute),
          let size = axSize(window, kAXSizeAttribute)
    else {
        return nil
    }

    return CGRect(origin: origin, size: size)
}

func writeFrame(_ rect: CGRect, to window: AXUIElement) {
    var origin = rect.origin
    var size = rect.size

    // Position first: macOS clamps a resize to the display the window currently
    // sits on, so a window growing onto a larger screen has to move there first.
    if let value = AXValueCreate(.cgPoint, &origin) {
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, value)
    }

    if let value = AXValueCreate(.cgSize, &size) {
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, value)
    }

    // And again, because resizing can nudge the origin back onto the old screen.
    if let value = AXValueCreate(.cgPoint, &origin) {
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, value)
    }
}

func matchesTarget(_ rect: CGRect, _ target: CGRect) -> Bool {
    abs(rect.minX - target.minX) <= positionTolerance
        && abs(rect.minY - target.minY) <= positionTolerance
        && rect.width <= target.width + positionTolerance
        && rect.height <= target.height + positionTolerance
        && rect.width >= target.width - cellSlack
        && rect.height >= target.height - cellSlack
}

func matchesExactly(_ rect: CGRect, _ other: CGRect) -> Bool {
    abs(rect.minX - other.minX) <= positionTolerance
        && abs(rect.minY - other.minY) <= positionTolerance
        && abs(rect.width - other.width) <= positionTolerance
        && abs(rect.height - other.height) <= positionTolerance
}

/// Applies `target`, retrying because a cross-display move needs the window to
/// land on the new screen before the resize is allowed to grow past the old
/// screen's bounds. Returns the frame that actually stuck.
@discardableResult
func applyFrame(_ target: CGRect, to window: AXUIElement) -> CGRect {
    var applied = target

    for attempt in 0 ..< 4 {
        writeFrame(target, to: window)
        applied = windowFrame(of: window) ?? target

        if matchesTarget(applied, target) {
            break
        }

        if attempt < 3 {
            usleep(25_000)
        }
    }

    return applied
}

func leaveNativeFullScreen(_ window: AXUIElement) {
    guard axBool(window, "AXFullScreen") else {
        return
    }

    AXUIElementSetAttributeValue(window, "AXFullScreen" as CFString, kCFBooleanFalse)

    // The exit animation runs about half a second; poll rather than guess.
    for _ in 0 ..< 40 {
        if !axBool(window, "AXFullScreen") {
            break
        }
        usleep(25_000)
    }

    usleep(150_000)
}

// MARK: - Screen geometry

let screens = NSScreen.screens

guard let primaryScreen = screens.first else {
    fputs("maximize-windowed: no screens found\n", stderr)
    exit(1)
}

/// The one true Cocoa -> Accessibility flip. See the header comment.
let primaryTopY = primaryScreen.frame.maxY

func axRect(_ cocoaRect: CGRect) -> CGRect {
    CGRect(
        x: cocoaRect.minX,
        y: primaryTopY - cocoaRect.maxY,
        width: cocoaRect.width,
        height: cocoaRect.height
    )
}

func overlapArea(_ lhs: CGRect, _ rhs: CGRect) -> Double {
    let intersection = lhs.intersection(rhs)
    return intersection.isNull ? 0 : intersection.width * intersection.height
}

/// The display a window belongs to: most overlap wins, so a window straddling
/// two monitors maximizes onto the one showing most of it. With no overlap at
/// all (a window left behind by an unplugged display) the nearest centre wins.
func screen(hosting rect: CGRect) -> NSScreen {
    var best: (screen: NSScreen, area: Double)?

    for candidate in screens {
        let area = overlapArea(axRect(candidate.frame), rect)
        if area > (best?.area ?? 0) {
            best = (candidate, area)
        }
    }

    if let best {
        return best.screen
    }

    let center = CGPoint(x: rect.midX, y: rect.midY)

    return screens.min {
        let lhs = axRect($0.frame), rhs = axRect($1.frame)
        return hypot(lhs.midX - center.x, lhs.midY - center.y)
            < hypot(rhs.midX - center.x, rhs.midY - center.y)
    } ?? primaryScreen
}

/// `visibleFrame` already excludes the menu bar and the Dock — on whichever
/// displays they actually appear — so it needs no manual fudging.
func maximizedRect(for screen: NSScreen) -> CGRect {
    axRect(screen.visibleFrame).insetBy(dx: margin, dy: margin)
}

/// Keeps a restored frame reachable: a window saved on a display that has since
/// been unplugged (or resized) gets re-centred on the display it is on now.
func madeReachable(_ rect: CGRect) -> CGRect {
    let visible = screens.reduce(0.0) { $0 + overlapArea(axRect($1.visibleFrame), rect) }

    if visible / max(rect.width * rect.height, 1) > 0.5 {
        return rect
    }

    let host = maximizedRect(for: screen(hosting: rect))
    let size = CGSize(width: min(rect.width, host.width), height: min(rect.height, host.height))

    return CGRect(
        x: host.minX + (host.width - size.width) / 2,
        y: host.minY + (host.height - size.height) / 2,
        width: size.width,
        height: size.height
    )
}

func defaultRestoreRect(for screen: NSScreen) -> CGRect {
    let host = maximizedRect(for: screen)
    let size = CGSize(width: (host.width * 0.7).rounded(), height: (host.height * 0.75).rounded())

    return CGRect(
        x: (host.minX + (host.width - size.width) / 2).rounded(),
        y: (host.minY + (host.height - size.height) / 2).rounded(),
        width: size.width,
        height: size.height
    )
}

// MARK: - Saved state

struct StoredRect: Codable {
    var x, y, width, height: Double

    init(_ rect: CGRect) {
        x = rect.minX
        y = rect.minY
        width = rect.width
        height = rect.height
    }

    var rect: CGRect { CGRect(x: x, y: y, width: width, height: height) }
}

struct Snapshot: Codable {
    /// Where the window was before it got maximized.
    var restore: StoredRect
    /// What maximizing actually produced — compared against on the next run,
    /// because Alacritty rounds the requested size down to whole cells and would
    /// otherwise never look "already maximized".
    var applied: StoredRect
    var stamp: Double
}

let stateURL = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent("alacritty-maximize-windowed.json")

func loadState() -> [String: Snapshot] {
    guard let data = try? Data(contentsOf: stateURL),
          let decoded = try? JSONDecoder().decode([String: Snapshot].self, from: data)
    else {
        return [:]
    }

    let cutoff = Date().timeIntervalSince1970 - 7 * 24 * 3600
    return decoded.filter { $0.value.stamp > cutoff }
}

func saveState(_ state: [String: Snapshot]) {
    var trimmed = state

    if trimmed.count > 64 {
        let keep = trimmed.sorted { $0.value.stamp > $1.value.stamp }.prefix(64)
        trimmed = Dictionary(uniqueKeysWithValues: keep.map { ($0.key, $0.value) })
    }

    if let data = try? JSONEncoder().encode(trimmed) {
        try? data.write(to: stateURL, options: .atomic)
    }
}

/// Per-window key so two Alacritty windows do not overwrite each other's saved
/// size. `_AXUIElementGetWindow` is private, so it is looked up at runtime and
/// falls back to the window's index within the app.
func stateKey(for window: AXUIElement, app: NSRunningApplication) -> String {
    typealias GetWindowID = @convention(c) (AXUIElement, UnsafeMutablePointer<CGWindowID>) -> AXError

    if let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "_AXUIElementGetWindow") {
        var identifier = CGWindowID(0)
        if unsafeBitCast(symbol, to: GetWindowID.self)(window, &identifier) == .success, identifier != 0 {
            return "window-\(identifier)"
        }
    }

    let appElement = AXUIElementCreateApplication(app.processIdentifier)
    var raw: CFTypeRef?

    if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &raw) == .success,
       let list = raw as? [AXUIElement],
       let index = list.firstIndex(where: { CFEqual($0, window) })
    {
        return "pid-\(app.processIdentifier)-index-\(index)"
    }

    return "pid-\(app.processIdentifier)"
}

// MARK: - Main

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

guard AXUIElementCopyAttributeValue(
    appElement,
    kAXFocusedWindowAttribute as CFString,
    &focusedWindowRef
) == .success, let focusedWindow = focusedWindowRef else {
    fputs("maximize-windowed: no focused window found\n", stderr)
    exit(1)
}

let window = focusedWindow as! AXUIElement

if !dryRun {
    leaveNativeFullScreen(window)
}

guard let currentFrame = windowFrame(of: window) else {
    fputs("maximize-windowed: could not read current window frame\n", stderr)
    exit(1)
}

let hostScreen = screen(hosting: currentFrame)
let targetFrame = maximizedRect(for: hostScreen)
let key = stateKey(for: window, app: app)

var state = loadState()
let snapshot = state[key]

let isMaximized = snapshot.map { matchesExactly(currentFrame, $0.applied.rect) } ?? false
    || matchesTarget(currentFrame, targetFrame)

let shouldRestore = mode == .restore || (mode == .toggle && isMaximized)

if dryRun {
    let index = screens.firstIndex(of: hostScreen) ?? -1

    print("app          \(app.localizedName ?? "?") (pid \(app.processIdentifier))")
    print("key          \(key)")
    print("current      \(currentFrame)")
    print("host screen  [\(index)] frame=\(hostScreen.frame) visible=\(hostScreen.visibleFrame)")
    print("maximized to \(targetFrame)")
    print("is maximized \(isMaximized)")
    print("would        \(shouldRestore ? "restore" : "maximize")")

    if shouldRestore {
        let restoreTo = snapshot.map { madeReachable($0.restore.rect) }
            ?? defaultRestoreRect(for: hostScreen)
        print("restore to   \(restoreTo)\(snapshot == nil ? " (no saved frame — default)" : "")")
    }

    exit(0)
}

if shouldRestore {
    let restoreTo = snapshot.map { madeReachable($0.restore.rect) }
        ?? defaultRestoreRect(for: hostScreen)

    applyFrame(restoreTo, to: window)
    state[key] = nil
} else {
    let applied = applyFrame(targetFrame, to: window)

    state[key] = Snapshot(
        restore: StoredRect(currentFrame),
        applied: StoredRect(applied),
        stamp: Date().timeIntervalSince1970
    )
}

saveState(state)
