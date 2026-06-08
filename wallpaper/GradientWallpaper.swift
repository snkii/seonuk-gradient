import AppKit
import CoreGraphics

private struct MeshRGB {
    var r, g, b: CGFloat
}

private struct MeshBlob {
    var x, y, vx, vy, vr, radius, sx, sy, rot, colorElapsed: CGFloat
    var current, start, target: MeshRGB
}

enum WallpaperMode: String, CaseIterable {
    case randomEvery10Minutes
    case randomEvery5Minutes
    case randomEvery3Minutes
    case randomEvery1Minute
    case paused

    var menuTitle: String {
        switch self {
        case .randomEvery10Minutes: return "Random Still - 10 Minutes"
        case .randomEvery5Minutes: return "Random Still - 5 Minutes"
        case .randomEvery3Minutes: return "Random Still - 3 Minutes"
        case .randomEvery1Minute: return "Random Still - 1 Minute"
        case .paused: return "Paused"
        }
    }

    var randomInterval: TimeInterval? {
        switch self {
        case .randomEvery10Minutes: return 600
        case .randomEvery5Minutes: return 300
        case .randomEvery3Minutes: return 180
        case .randomEvery1Minute: return 60
        case .paused: return nil
        }
    }
}

private let wallpaperModeDefaultsKey = "WallpaperMode"
private let defaultWallpaperMode: WallpaperMode = .randomEvery10Minutes
private let sceneStateDirectoryName = "Seonuk Gradient"
private let sceneStateFileName = "current_scene.json"

private func currentSceneStateURL() -> URL? {
    guard let directory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                   in: .userDomainMask).first?
        .appendingPathComponent(sceneStateDirectoryName, isDirectory: true)
    else { return nil }
    return directory.appendingPathComponent(sceneStateFileName)
}

private let meshPalette: [MeshRGB] = [
    MeshRGB(r: 250/255, g: 189/255, b:  47/255),
    MeshRGB(r: 215/255, g: 153/255, b:  33/255),
    MeshRGB(r: 254/255, g: 128/255, b:  25/255),
    MeshRGB(r: 251/255, g:  73/255, b:  52/255),
    MeshRGB(r: 184/255, g: 187/255, b:  38/255),
    MeshRGB(r: 142/255, g: 192/255, b: 124/255),
    MeshRGB(r: 131/255, g: 165/255, b: 152/255),
    MeshRGB(r:  69/255, g: 133/255, b: 136/255),
    MeshRGB(r: 211/255, g: 134/255, b: 155/255),
    MeshRGB(r: 146/255, g: 131/255, b: 116/255),
]

private let fineFilmGrainTileSize: CGFloat = 96
private let coarseFilmGrainTileSize: CGFloat = 360
private let fineFilmGrainImage = makeFilmGrainImage(size: Int(fineFilmGrainTileSize), seed: 0x5E0A)
private let coarseFilmGrainImage = makeFilmGrainImage(size: Int(coarseFilmGrainTileSize), seed: 0xC0A4)

private func nextFilmGrainSeed(_ seed: inout UInt32) -> UInt32 {
    seed ^= seed << 13
    seed ^= seed >> 17
    seed ^= seed << 5
    return seed
}

private func makeFilmGrainImage(size: Int, seed: UInt32) -> CGImage? {
    guard size > 0 else { return nil }

    var state = seed == 0 ? 0x9e3779b9 : seed
    var pixels = [UInt8](repeating: 0, count: size * size * 4)

    for offset in stride(from: 0, to: pixels.count, by: 4) {
        let value = UInt8(truncatingIfNeeded: nextFilmGrainSeed(&state))
        pixels[offset] = value
        pixels[offset + 1] = value
        pixels[offset + 2] = value
        pixels[offset + 3] = 255
    }

    let data = Data(pixels) as CFData
    guard let provider = CGDataProvider(data: data) else { return nil }
    return CGImage(width: size,
                   height: size,
                   bitsPerComponent: 8,
                   bitsPerPixel: 32,
                   bytesPerRow: size * 4,
                   space: CGColorSpaceCreateDeviceRGB(),
                   bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
                   provider: provider,
                   decode: nil,
                   shouldInterpolate: false,
                   intent: .defaultIntent)
}

private func applyMeshFilmTexture(ctx: CGContext, width: CGFloat, height: CGFloat) {
    guard width > 0, height > 0 else { return }
    drawMeshFilmTone(ctx: ctx, width: width, height: height)
    drawMeshFilmGrain(ctx: ctx, width: width, height: height)
}

private func drawMeshFilmTone(ctx: CGContext, width: CGFloat, height: CGFloat) {
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    if let linear = CGGradient(colorsSpace: colorSpace,
                               colors: [
                                   CGColor(red: 251/255, green:  73/255, blue:  52/255, alpha: 0.16),
                                   CGColor(red: 184/255, green: 187/255, blue:  38/255, alpha: 0.07),
                                   CGColor(red:  69/255, green: 133/255, blue: 136/255, alpha: 0.14),
                               ] as CFArray,
                               locations: [0, 0.45, 1]) {
        ctx.saveGState()
        ctx.setBlendMode(.softLight)
        ctx.setAlpha(0.05)
        ctx.drawLinearGradient(linear,
                               start: CGPoint(x: 0, y: 0),
                               end: CGPoint(x: width, y: height),
                               options: [])
        ctx.restoreGState()
    }

    if let radial = CGGradient(colorsSpace: colorSpace,
                               colors: [
                                   CGColor(red: 250/255, green: 189/255, blue: 47/255, alpha: 0.22),
                                   CGColor(red: 250/255, green: 189/255, blue: 47/255, alpha: 0.06),
                                   CGColor(red:  40/255, green:  40/255, blue: 40/255, alpha: 0.0),
                               ] as CFArray,
                               locations: [0, 0.36, 0.68]) {
        ctx.saveGState()
        ctx.setBlendMode(.softLight)
        ctx.setAlpha(0.05)
        ctx.drawRadialGradient(radial,
                               startCenter: CGPoint(x: width * 0.48, y: height * 0.42),
                               startRadius: 0,
                               endCenter: CGPoint(x: width * 0.48, y: height * 0.42),
                               endRadius: max(width, height) * 0.68,
                               options: [.drawsAfterEndLocation])
        ctx.restoreGState()
    }
}

private func drawMeshFilmGrain(ctx: CGContext, width: CGFloat, height: CGFloat) {
    ctx.saveGState()
    ctx.setBlendMode(.overlay)
    ctx.interpolationQuality = .none

    if let coarseImage = coarseFilmGrainImage {
        ctx.setAlpha(0.05)
        drawTiledFilmGrain(ctx: ctx,
                           image: coarseImage,
                           tileSize: coarseFilmGrainTileSize,
                           width: width,
                           height: height)
    }

    if let fineImage = fineFilmGrainImage {
        ctx.setAlpha(0.10)
        drawTiledFilmGrain(ctx: ctx,
                           image: fineImage,
                           tileSize: fineFilmGrainTileSize,
                           width: width,
                           height: height)
    }

    ctx.restoreGState()
}

private func drawTiledFilmGrain(ctx: CGContext, image: CGImage, tileSize: CGFloat, width: CGFloat, height: CGFloat) {
    var y: CGFloat = 0
    while y < height {
        var x: CGFloat = 0
        while x < width {
            ctx.draw(image, in: CGRect(x: x, y: y, width: tileSize, height: tileSize))
            x += tileSize
        }
        y += tileSize
    }
}

final class GradientWallpaperView: NSView {
    private let blobSizeFactor: CGFloat = 0.90
    private let blurFactor: CGFloat = 0.22

    private var blobs: [MeshBlob] = []
    private var mode: WallpaperMode = defaultWallpaperMode
    private let colorTransitionSeconds: CGFloat = 6.5

    override var isOpaque: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = CGColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        initBlobs()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer?.backgroundColor = CGColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        initBlobs()
    }

    func setMode(_ newMode: WallpaperMode, randomize: Bool = false) {
        let changed = mode != newMode
        mode = newMode
        if randomize || (changed && newMode.randomInterval != nil) {
            randomizeScene()
        }
        needsDisplay = true
    }

    func randomizeScene() {
        initBlobs()
        needsDisplay = true
    }

    private func initBlobs() {
        blobs = (0..<3).map { _ in
            let color = randomColor()
            let velocity = randomVelocity()
            return MeshBlob(
                x: randomBetween(-0.12, 1.12),
                y: randomBetween(-0.10, 1.10),
                vx: velocity.vx,
                vy: velocity.vy,
                vr: randomBetween(-0.8, 0.8),
                radius: randomBetween(0.86, 1.08),
                sx: randomBetween(0.85, 1.38),
                sy: randomBetween(0.78, 1.28),
                rot: randomBetween(0, 360),
                colorElapsed: colorTransitionSeconds,
                current: color,
                start: color,
                target: color
            )
        }
    }

    private func randomColor() -> MeshRGB {
        meshPalette[Int.random(in: 0..<meshPalette.count)]
    }

    private func randomBetween(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
        min + CGFloat.random(in: 0...1) * (max - min)
    }

    private func randomVelocity() -> (vx: CGFloat, vy: CGFloat) {
        let angle = randomBetween(0, CGFloat.pi * 2)
        let speed = randomBetween(0.0026, 0.0054)
        return (cos(angle) * speed, sin(angle) * speed)
    }

    func sceneState(for screen: NSScreen, index: Int) -> [String: Any] {
        let width = Double(screen.frame.width)
        let height = Double(screen.frame.height)
        return [
            "index": index,
            "width": width,
            "height": height,
            "scale": Double(screen.backingScaleFactor),
            "aspectRatio": height > 0 ? width / height : 1,
            "blobs": blobs.map { blobState($0) }
        ]
    }

    private func blobState(_ blob: MeshBlob) -> [String: Any] {
        [
            "x": Double(blob.x),
            "y": Double(blob.y),
            "vx": Double(blob.vx),
            "vy": Double(blob.vy),
            "vr": Double(blob.vr),
            "radius": Double(blob.radius),
            "sx": Double(blob.sx),
            "sy": Double(blob.sy),
            "rot": Double(blob.rot),
            "colorElapsed": Double(blob.colorElapsed),
            "current": colorState(blob.current),
            "start": colorState(blob.start),
            "target": colorState(blob.target)
        ]
    }

    private func colorState(_ color: MeshRGB) -> [String: Double] {
        [
            "r": Double(color.r),
            "g": Double(color.g),
            "b": Double(color.b)
        ]
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        renderScene(ctx: ctx, width: bounds.width, height: bounds.height)
    }

    func makeStaticWallpaperURL(for screen: NSScreen, index: Int) -> URL? {
        let scale = screen.backingScaleFactor
        let pointSize = screen.frame.size
        let pixelWidth = max(2, Int(pointSize.width * scale))
        let pixelHeight = max(2, Int(pointSize.height * scale))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: nil,
                                  width: pixelWidth,
                                  height: pixelHeight,
                                  bitsPerComponent: 8,
                                  bytesPerRow: 0,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }

        renderScene(ctx: ctx, width: CGFloat(pixelWidth), height: CGFloat(pixelHeight))

        guard let cgImage = ctx.makeImage() else { return nil }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        guard let png = rep.representation(using: .png, properties: [:]) else { return nil }

        let filename = "gradient_wallpaper_lock_\(index)_\(UUID().uuidString).png"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        try? png.write(to: url)
        return url
    }

    private func renderScene(ctx: CGContext, width: CGFloat, height: CGFloat) {
        ctx.setFillColor(CGColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1))
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

        let minDim = min(width, height)
        guard minDim > 0 else { return }

        for blob in blobs {
            let size = blob.radius * blobSizeFactor * minDim
            drawStaticBlob(ctx: ctx,
                           cx: blob.x * width,
                           cy: blob.y * height,
                           size: size,
                           blur: blurFactor * minDim,
                           sx: blob.sx,
                           sy: blob.sy,
                           rot: blob.rot,
                           color: blob.current)
        }
        applyMeshFilmTexture(ctx: ctx, width: width, height: height)
    }
}

private func drawStaticBlob(ctx: CGContext, cx: CGFloat, cy: CGFloat, size: CGFloat,
                            blur: CGFloat, sx: CGFloat, sy: CGFloat, rot: CGFloat,
                            color: MeshRGB) {
    let radius = size / 2 + blur * 2
    let colors = [
        CGColor(red: color.r, green: color.g, blue: color.b, alpha: 0.70),
        CGColor(red: color.r, green: color.g, blue: color.b, alpha: 0.52),
        CGColor(red: color.r, green: color.g, blue: color.b, alpha: 0.18),
        CGColor(red: color.r, green: color.g, blue: color.b, alpha: 0.0),
    ] as CFArray
    let locations: [CGFloat] = [0, 0.34, 0.72, 1]
    guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors,
                                    locations: locations) else { return }

    ctx.saveGState()
    ctx.translateBy(x: cx, y: cy)
    ctx.rotate(by: rot * CGFloat.pi / 180)
    ctx.scaleBy(x: sx, y: sy)
    ctx.drawRadialGradient(gradient,
                           startCenter: .zero,
                           startRadius: 0,
                           endCenter: .zero,
                           endRadius: radius,
                           options: [.drawsAfterEndLocation])
    ctx.restoreGState()
}

class WallpaperDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var statusItem: NSStatusItem?
    var headerItem: NSMenuItem?
    var modeItems: [WallpaperMode: NSMenuItem] = [:]
    var originalWallpapers: [NSScreen: URL] = [:]
    var pausedForSystem = false
    var pausedForActivity = false
    var animationPaused = false
    var wallpaperMode: WallpaperMode = WallpaperMode(rawValue: UserDefaults.standard.string(forKey: wallpaperModeDefaultsKey) ?? "") ?? defaultWallpaperMode
    var randomSceneTimer: Timer?
    var generatedWallpaperURLs: [URL] = []

    func applicationDidFinishLaunching(_ n: Notification) {
        captureOriginalWallpapers()
        NSScreen.screens.forEach { windows.append(makeWindow($0)) }
        setupMenuBar()
        setupSleepObservers()
        setupActivityObservers()
        applyMode(wallpaperMode, randomize: wallpaperMode.randomInterval != nil)
        updateActivityPause(force: true)
    }

    func applicationWillTerminate(_ n: Notification) {
        randomSceneTimer?.invalidate()
        restoreSystemWallpaper()
        cleanupGeneratedWallpapers(keeping: [])
    }

    // MARK: - System wallpaper replacement

    func captureOriginalWallpapers() {
        for screen in NSScreen.screens {
            if let original = NSWorkspace.shared.desktopImageURL(for: screen) {
                originalWallpapers[screen] = original
            }
        }
    }

    func refreshLockScreenWallpaper() {
        let previousURLs = generatedWallpaperURLs
        var newURLs: [URL] = []

        for (index, screen) in NSScreen.screens.enumerated() {
            if let view = gradientView(for: screen),
               let meshURL = view.makeStaticWallpaperURL(for: screen, index: index) {
                do {
                    try NSWorkspace.shared.setDesktopImageURL(meshURL, for: screen, options: [:])
                    newURLs.append(meshURL)
                } catch {
                    try? FileManager.default.removeItem(at: meshURL)
                }
            }
        }

        if !newURLs.isEmpty {
            generatedWallpaperURLs = newURLs
            cleanupGeneratedWallpapers(keeping: newURLs, from: previousURLs)
        }
        saveCurrentSceneState()
    }

    func restoreSystemWallpaper() {
        for (screen, url) in originalWallpapers {
            try? NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: [:])
        }
    }

    func cleanupGeneratedWallpapers(keeping urlsToKeep: [URL], from urls: [URL]? = nil) {
        for url in urls ?? generatedWallpaperURLs where !urlsToKeep.contains(url) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Sleep / lock observers

    func setupSleepObservers() {
        let ws = NSWorkspace.shared.notificationCenter
        ws.addObserver(self, selector: #selector(pauseForSystem),
                       name: NSWorkspace.screensDidSleepNotification, object: nil)
        ws.addObserver(self, selector: #selector(pauseForSystem),
                       name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        ws.addObserver(self, selector: #selector(resumeFromSystem),
                       name: NSWorkspace.screensDidWakeNotification, object: nil)
        ws.addObserver(self, selector: #selector(resumeFromSystem),
                       name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
    }

    func setupActivityObservers() {
        let ws = NSWorkspace.shared.notificationCenter
        ws.addObserver(self, selector: #selector(activeApplicationDidChange),
                       name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    @objc func pauseForSystem() {
        refreshLockScreenWallpaper()
        pausedForSystem = true
        refreshAnimationState()
    }

    @objc func resumeFromSystem() {
        pausedForSystem = false
        updateActivityPause()
    }

    @objc func activeApplicationDidChange() {
        updateActivityPause()
    }

    func updateActivityPause(force: Bool = false) {
        let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        pausedForActivity = bundleID != nil && bundleID != "com.apple.finder"
        refreshAnimationState(force: force)
    }

    func refreshAnimationState(force: Bool = false) {
        let shouldPause = pausedForSystem || pausedForActivity
        guard force || shouldPause != animationPaused else { return }
        animationPaused = shouldPause
        updateRandomSceneTimer()
        saveCurrentSceneState()
    }

    func gradientViews() -> [GradientWallpaperView] {
        windows.compactMap { $0.contentView as? GradientWallpaperView }
    }

    func gradientView(for screen: NSScreen) -> GradientWallpaperView? {
        for window in windows {
            if let windowScreen = window.screen, windowScreen === screen {
                return window.contentView as? GradientWallpaperView
            }
            if window.frame.equalTo(screen.frame) {
                return window.contentView as? GradientWallpaperView
            }
        }
        return nil
    }

    // MARK: - Mode

    func applyMode(_ mode: WallpaperMode, randomize: Bool = false) {
        wallpaperMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: wallpaperModeDefaultsKey)
        gradientViews().forEach { $0.setMode(mode, randomize: randomize) }
        refreshLockScreenWallpaper()
        updateRandomSceneTimer()
        updateMenuState()
    }

    func randomizeScenes(ignorePause: Bool = false) {
        guard ignorePause || (!pausedForSystem && !pausedForActivity) else { return }
        gradientViews().forEach { $0.randomizeScene() }
        refreshLockScreenWallpaper()
    }

    func updateRandomSceneTimer() {
        randomSceneTimer?.invalidate()
        randomSceneTimer = nil

        guard let interval = wallpaperMode.randomInterval, !pausedForSystem, !pausedForActivity else { return }
        let timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            self?.randomizeScenes()
        }
        RunLoop.main.add(timer, forMode: .common)
        randomSceneTimer = timer
    }

    func saveCurrentSceneState() {
        let scenes = NSScreen.screens.enumerated().compactMap { index, screen -> [String: Any]? in
            guard let view = gradientView(for: screen) else { return nil }
            return view.sceneState(for: screen, index: index)
        }
        guard !scenes.isEmpty, let url = currentSceneStateURL() else { return }

        let payload: [String: Any] = [
            "version": 1,
            "updatedAt": Date().timeIntervalSince1970,
            "mode": wallpaperMode.rawValue,
            "scenes": scenes
        ]

        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            let data = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])
            try data.write(to: url, options: .atomic)
        } catch {
            return
        }
    }

    func updateMenuState() {
        let title = "Gradient Wallpaper - \(wallpaperMode.menuTitle)"
        headerItem?.title = title
        statusItem?.button?.toolTip = title
        for (mode, item) in modeItems {
            item.state = mode == wallpaperMode ? .on : .off
        }
    }

    // MARK: - Menu bar

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "sparkles", accessibilityDescription: "Gradient Wallpaper")
        }
        let menu = NSMenu()
        let header = NSMenuItem(title: "Gradient Wallpaper", action: nil, keyEquivalent: "")
        header.isEnabled = false
        headerItem = header
        menu.addItem(header)
        menu.addItem(.separator())

        let modeMenu = NSMenu()
        for mode in WallpaperMode.allCases {
            let item = NSMenuItem(title: mode.menuTitle, action: #selector(selectMode(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = mode.rawValue
            modeMenu.addItem(item)
            modeItems[mode] = item
        }
        let modeRoot = NSMenuItem(title: "Mode", action: nil, keyEquivalent: "")
        modeRoot.submenu = modeMenu
        menu.addItem(modeRoot)

        let randomNow = NSMenuItem(title: "Generate Random Now", action: #selector(generateRandomNow), keyEquivalent: "r")
        randomNow.target = self
        menu.addItem(randomNow)

        let refreshLock = NSMenuItem(title: "Refresh Lock Screen Wallpaper", action: #selector(refreshLockScreenMenuItem), keyEquivalent: "")
        refreshLock.target = self
        menu.addItem(refreshLock)

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
        updateMenuState()
    }

    @objc func selectMode(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let mode = WallpaperMode(rawValue: rawValue) else { return }
        applyMode(mode, randomize: mode.randomInterval != nil)
    }

    @objc func generateRandomNow() {
        randomizeScenes(ignorePause: true)
    }

    @objc func refreshLockScreenMenuItem() {
        refreshLockScreenWallpaper()
    }

    // MARK: - Window

    func makeWindow(_ screen: NSScreen) -> NSWindow {
        let win = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )
        win.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        win.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        win.isOpaque = true
        win.hasShadow = false
        win.ignoresMouseEvents = true
        win.backgroundColor = NSColor(deviceRed: 40/255, green: 40/255, blue: 40/255, alpha: 1)
        win.setFrame(screen.frame, display: true)

        let view = GradientWallpaperView(frame: CGRect(origin: .zero, size: screen.frame.size))
        view.setMode(wallpaperMode, randomize: false)
        view.autoresizingMask = [.width, .height]
        win.contentView = view

        win.orderFrontRegardless()
        return win
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = WallpaperDelegate()
app.delegate = delegate
app.run()
