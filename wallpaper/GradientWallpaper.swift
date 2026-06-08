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
private let savedScenesFileName = "saved_scenes.json"
private let maxSavedScenes = 24

private func sceneStateDirectoryURL() -> URL? {
    FileManager.default.urls(for: .applicationSupportDirectory,
                             in: .userDomainMask).first?
        .appendingPathComponent(sceneStateDirectoryName, isDirectory: true)
}

private func currentSceneStateURL() -> URL? {
    sceneStateDirectoryURL()?.appendingPathComponent(sceneStateFileName)
}

private func savedScenesStateURL() -> URL? {
    sceneStateDirectoryURL()?.appendingPathComponent(savedScenesFileName)
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

private let fineFilmGrainTileSize: CGFloat = 731
private let coarseFilmGrainTileSize: CGFloat = 1543
private let fineFilmGrainImage = makeFilmGrainImage(size: Int(fineFilmGrainTileSize), seed: 0x5E0A, contrast: 46)
private let coarseFilmGrainImage = makeFilmGrainImage(size: Int(coarseFilmGrainTileSize), seed: 0xC0A4, contrast: 26)
private let meshColorSaturationLift: CGFloat = 1.16
private let meshColorBrightnessLift: CGFloat = 1.08
private let meshColorLiftOffset: CGFloat = 0.015

private func nextFilmGrainSeed(_ seed: inout UInt32) -> UInt32 {
    seed ^= seed << 13
    seed ^= seed >> 17
    seed ^= seed << 5
    return seed
}

private func makeFilmGrainImage(size: Int, seed: UInt32, contrast: Int) -> CGImage? {
    guard size > 0 else { return nil }

    var state = seed == 0 ? 0x9e3779b9 : seed
    var pixels = [UInt8](repeating: 0, count: size * size * 4)

    for offset in stride(from: 0, to: pixels.count, by: 4) {
        let raw = Int(UInt8(truncatingIfNeeded: nextFilmGrainSeed(&state)))
        let value = UInt8(clamping: 128 + ((raw - 128) * contrast / 128))
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
        ctx.setAlpha(0.032)
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
        ctx.setAlpha(0.032)
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
        ctx.setAlpha(0.018)
        drawTiledFilmGrain(ctx: ctx,
                           image: coarseImage,
                           tileSize: coarseFilmGrainTileSize,
                           width: width,
                           height: height,
                           xOffset: -863,
                           yOffset: -541)
    }

    if let fineImage = fineFilmGrainImage {
        ctx.setAlpha(0.046)
        drawTiledFilmGrain(ctx: ctx,
                           image: fineImage,
                           tileSize: fineFilmGrainTileSize,
                           width: width,
                           height: height,
                           xOffset: -211,
                           yOffset: -397)
    }

    ctx.restoreGState()
}

private func drawTiledFilmGrain(ctx: CGContext, image: CGImage, tileSize: CGFloat, width: CGFloat, height: CGFloat, xOffset: CGFloat, yOffset: CGFloat) {
    var y = yOffset
    while y > 0 { y -= tileSize }
    while y + tileSize < 0 { y += tileSize }
    while y < height {
        var x = xOffset
        while x > 0 { x -= tileSize }
        while x + tileSize < 0 { x += tileSize }
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
    private let minimumBlobCenterDistance: CGFloat = 0.52
    private let minimumColorDistance: CGFloat = 0.36
    private let randomCandidateCount = 48

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

    func setMode(_ newMode: WallpaperMode) {
        mode = newMode
        needsDisplay = true
    }

    func randomizeScene() {
        initBlobs()
        needsDisplay = true
    }

    private func initBlobs() {
        let colors = distinctColors(count: 3)
        let centers = separatedBlobCenters(count: 3)

        blobs = (0..<3).map { index in
            let color = colors[index]
            let velocity = randomVelocity()
            return MeshBlob(
                x: centers[index].x,
                y: centers[index].y,
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

    private func distinctColors(count: Int) -> [MeshRGB] {
        guard count > 0 else { return [] }

        var candidates = meshPalette.shuffled()
        var selected: [MeshRGB] = []
        if let first = candidates.popLast() {
            selected.append(first)
        }

        while selected.count < count, !candidates.isEmpty {
            let ranked = candidates.enumerated().map { index, color in
                (index: index, color: color, distance: nearestColorDistance(color, to: selected))
            }.sorted { $0.distance > $1.distance }

            let preferred = ranked.filter { $0.distance >= minimumColorDistance }
            let pool = preferred.isEmpty ? Array(ranked.prefix(min(4, ranked.count))) : Array(preferred.prefix(min(4, preferred.count)))
            guard let pick = pool.randomElement() else { break }

            selected.append(pick.color)
            candidates.remove(at: pick.index)
        }

        while selected.count < count {
            selected.append(randomColor())
        }
        return selected
    }

    private func separatedBlobCenters(count: Int) -> [(x: CGFloat, y: CGFloat)] {
        guard count > 0 else { return [] }

        var centers: [(x: CGFloat, y: CGFloat)] = []
        while centers.count < count {
            if centers.isEmpty {
                centers.append(randomBlobCenter())
                continue
            }

            let ranked = (0..<randomCandidateCount).map { _ -> (center: (x: CGFloat, y: CGFloat), distance: CGFloat) in
                let center = randomBlobCenter()
                return (center: center, distance: nearestCenterDistance(center, to: centers))
            }.sorted { $0.distance > $1.distance }

            let preferred = ranked.filter { $0.distance >= minimumBlobCenterDistance }
            let pool = preferred.isEmpty ? Array(ranked.prefix(min(8, ranked.count))) : Array(preferred.prefix(min(8, preferred.count)))
            centers.append((pool.randomElement() ?? ranked[0]).center)
        }
        return centers
    }

    private func randomBlobCenter() -> (x: CGFloat, y: CGFloat) {
        (
            x: randomBetween(-0.10, 1.10),
            y: randomBetween(-0.08, 1.08)
        )
    }

    private func nearestColorDistance(_ color: MeshRGB, to selected: [MeshRGB]) -> CGFloat {
        guard !selected.isEmpty else { return .greatestFiniteMagnitude }
        return selected.map { colorDistance(color, $0) }.min() ?? .greatestFiniteMagnitude
    }

    private func colorDistance(_ a: MeshRGB, _ b: MeshRGB) -> CGFloat {
        let dr = a.r - b.r
        let dg = a.g - b.g
        let db = a.b - b.b
        return sqrt(dr * dr + dg * dg + db * db)
    }

    private func nearestCenterDistance(_ center: (x: CGFloat, y: CGFloat), to centers: [(x: CGFloat, y: CGFloat)]) -> CGFloat {
        guard !centers.isEmpty else { return .greatestFiniteMagnitude }
        return centers.map { other in
            hypot(center.x - other.x, center.y - other.y)
        }.min() ?? .greatestFiniteMagnitude
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

    func portableSceneState() -> [String: Any] {
        [
            "blobs": blobs.map { blobState($0) }
        ]
    }

    func applySceneState(_ state: [String: Any]) -> Bool {
        guard let blobStates = state["blobs"] as? [[String: Any]] else { return false }
        let loadedBlobs = blobStates.compactMap { blob(from: $0) }
        guard loadedBlobs.count >= 3 else { return false }

        blobs = Array(loadedBlobs.prefix(3))
        needsDisplay = true
        return true
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

    private func blob(from state: [String: Any]) -> MeshBlob? {
        guard let x = cgFloatValue(state["x"]),
              let y = cgFloatValue(state["y"]),
              let vx = cgFloatValue(state["vx"]),
              let vy = cgFloatValue(state["vy"]),
              let vr = cgFloatValue(state["vr"]),
              let radius = cgFloatValue(state["radius"]),
              let sx = cgFloatValue(state["sx"]),
              let sy = cgFloatValue(state["sy"]),
              let rot = cgFloatValue(state["rot"]),
              let colorElapsed = cgFloatValue(state["colorElapsed"]),
              let current = color(from: state["current"]),
              let start = color(from: state["start"]),
              let target = color(from: state["target"])
        else { return nil }

        return MeshBlob(x: x,
                        y: y,
                        vx: vx,
                        vy: vy,
                        vr: vr,
                        radius: radius,
                        sx: sx,
                        sy: sy,
                        rot: rot,
                        colorElapsed: colorElapsed,
                        current: current,
                        start: start,
                        target: target)
    }

    private func color(from value: Any?) -> MeshRGB? {
        guard let state = value as? [String: Any],
              let r = cgFloatValue(state["r"]),
              let g = cgFloatValue(state["g"]),
              let b = cgFloatValue(state["b"])
        else { return nil }
        return MeshRGB(r: r, g: g, b: b)
    }

    private func doubleValue(_ value: Any?) -> Double? {
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        return value as? Double
    }

    private func cgFloatValue(_ value: Any?) -> CGFloat? {
        guard let double = doubleValue(value) else { return nil }
        return CGFloat(double)
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
    let renderColor = liftedMeshColor(color)
    let colors = [
        CGColor(red: renderColor.r, green: renderColor.g, blue: renderColor.b, alpha: 0.76),
        CGColor(red: renderColor.r, green: renderColor.g, blue: renderColor.b, alpha: 0.56),
        CGColor(red: renderColor.r, green: renderColor.g, blue: renderColor.b, alpha: 0.21),
        CGColor(red: renderColor.r, green: renderColor.g, blue: renderColor.b, alpha: 0.0),
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

private func liftedMeshColor(_ color: MeshRGB) -> MeshRGB {
    let luma = color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
    return MeshRGB(
        r: clamp01((luma + (color.r - luma) * meshColorSaturationLift) * meshColorBrightnessLift + meshColorLiftOffset),
        g: clamp01((luma + (color.g - luma) * meshColorSaturationLift) * meshColorBrightnessLift + meshColorLiftOffset),
        b: clamp01((luma + (color.b - luma) * meshColorSaturationLift) * meshColorBrightnessLift + meshColorLiftOffset)
    )
}

private func clamp01(_ value: CGFloat) -> CGFloat {
    min(max(value, 0), 1)
}

final class SavedScenePreviewView: NSView {
    var record: [String: Any]? {
        didSet { needsDisplay = true }
    }

    override var isOpaque: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        let width = bounds.width
        let height = bounds.height

        ctx.setFillColor(CGColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1))
        ctx.fill(bounds)

        guard width > 0, height > 0, let blobs = previewBlobStates() else {
            drawEmptyState()
            return
        }

        let minDim = min(width, height)
        for blob in blobs.prefix(3) {
            guard let x = cgFloatValue(blob["x"]),
                  let y = cgFloatValue(blob["y"]),
                  let radius = cgFloatValue(blob["radius"]),
                  let sx = cgFloatValue(blob["sx"]),
                  let sy = cgFloatValue(blob["sy"]),
                  let rot = cgFloatValue(blob["rot"]),
                  let color = color(from: blob["current"])
            else { continue }

            drawStaticBlob(ctx: ctx,
                           cx: x * width,
                           cy: y * height,
                           size: radius * 0.90 * minDim,
                           blur: 0.22 * minDim,
                           sx: sx,
                           sy: sy,
                           rot: rot,
                           color: color)
        }
        applyMeshFilmTexture(ctx: ctx, width: width, height: height)
    }

    private func previewBlobStates() -> [[String: Any]]? {
        if let scenes = record?["scenes"] as? [[String: Any]],
           let scene = scenes.first,
           let blobs = scene["blobs"] as? [[String: Any]] {
            return blobs
        }
        return record?["blobs"] as? [[String: Any]]
    }

    private func drawEmptyState() {
        let text = "No Saved Scenes"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor(white: 1, alpha: 0.45),
            .font: NSFont.systemFont(ofSize: 15, weight: .medium)
        ]
        let size = text.size(withAttributes: attributes)
        text.draw(at: CGPoint(x: (bounds.width - size.width) / 2,
                              y: (bounds.height - size.height) / 2),
                  withAttributes: attributes)
    }

    private func color(from value: Any?) -> MeshRGB? {
        guard let state = value as? [String: Any],
              let r = cgFloatValue(state["r"]),
              let g = cgFloatValue(state["g"]),
              let b = cgFloatValue(state["b"])
        else { return nil }
        return MeshRGB(r: r, g: g, b: b)
    }

    private func doubleValue(_ value: Any?) -> Double? {
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        return value as? Double
    }

    private func cgFloatValue(_ value: Any?) -> CGFloat? {
        guard let double = doubleValue(value) else { return nil }
        return CGFloat(double)
    }
}

final class SavedSceneBrowserController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    private weak var wallpaperDelegate: WallpaperDelegate?
    private let panel: NSPanel
    private let tableView = NSTableView()
    private let previewView = SavedScenePreviewView()
    private let loadButton = NSButton(title: "Load", target: nil, action: nil)
    private let deleteButton = NSButton(title: "Delete", target: nil, action: nil)
    private let closeButton = NSButton(title: "Close", target: nil, action: nil)
    private var records: [[String: Any]] = []

    init(wallpaperDelegate: WallpaperDelegate) {
        self.wallpaperDelegate = wallpaperDelegate
        panel = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 760, height: 430),
                        styleMask: [.titled, .closable],
                        backing: .buffered,
                        defer: false)
        super.init()
        configurePanel()
    }

    func show() {
        reloadRecords()
        NSApp.activate(ignoringOtherApps: true)
        panel.center()
        panel.makeKeyAndOrderFront(nil)
    }

    func reloadRecords(selecting id: String? = nil) {
        records = wallpaperDelegate?.loadSavedSceneRecords() ?? []
        tableView.reloadData()

        if let id,
           let index = records.firstIndex(where: { $0["id"] as? String == id }) {
            tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        } else if !records.isEmpty && tableView.selectedRow < 0 {
            tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
        updatePreview()
    }

    private func configurePanel() {
        panel.title = "Saved Scenes"
        panel.isReleasedWhenClosed = false
        panel.isFloatingPanel = true

        guard let contentView = panel.contentView else { return }
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("SavedScene"))
        column.title = "Scene"
        column.width = 220
        tableView.addTableColumn(column)
        tableView.headerView = nil
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = false
        tableView.usesAlternatingRowBackgroundColors = false

        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder

        previewView.wantsLayer = true
        previewView.layer?.cornerRadius = 8
        previewView.layer?.masksToBounds = true

        loadButton.target = self
        loadButton.action = #selector(loadSelectedScene)
        loadButton.keyEquivalent = "\r"
        deleteButton.target = self
        deleteButton.action = #selector(deleteSelectedScene)
        closeButton.target = self
        closeButton.action = #selector(closePanel)

        [scrollView, previewView, deleteButton, closeButton, loadButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -58),
            scrollView.widthAnchor.constraint(equalToConstant: 230),

            previewView.leadingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 16),
            previewView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            previewView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            previewView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -58),

            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            loadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loadButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            closeButton.trailingAnchor.constraint(equalTo: loadButton.leadingAnchor, constant: -8),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        records.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        wallpaperDelegate?.savedSceneTitle(records[row], fallbackIndex: row)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        updatePreview()
    }

    private func updatePreview() {
        let selectedRow = tableView.selectedRow
        let hasSelection = selectedRow >= 0 && selectedRow < records.count
        previewView.record = hasSelection ? records[selectedRow] : nil
        loadButton.isEnabled = hasSelection
        deleteButton.isEnabled = hasSelection
    }

    @objc private func loadSelectedScene() {
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0, selectedRow < records.count else { return }
        wallpaperDelegate?.applySavedSceneRecord(records[selectedRow])
        panel.orderOut(nil)
    }

    @objc private func deleteSelectedScene() {
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0, selectedRow < records.count else { return }

        records.remove(at: selectedRow)
        wallpaperDelegate?.writeSavedSceneRecords(records)
        wallpaperDelegate?.updateSavedScenesMenu()
        tableView.reloadData()

        if !records.isEmpty {
            tableView.selectRowIndexes(IndexSet(integer: min(selectedRow, records.count - 1)),
                                       byExtendingSelection: false)
        }
        updatePreview()
    }

    @objc private func closePanel() {
        panel.orderOut(nil)
    }
}

class WallpaperDelegate: NSObject, NSApplicationDelegate {
    var windows: [NSWindow] = []
    var statusItem: NSStatusItem?
    var headerItem: NSMenuItem?
    var modeItems: [WallpaperMode: NSMenuItem] = [:]
    var savedScenesMenu: NSMenu?
    var savedSceneBrowser: SavedSceneBrowserController?
    var originalWallpapers: [NSScreen: URL] = [:]
    var pausedForSystem = false
    var pausedForActivity = false
    var refreshPaused = false
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
        refreshTimerState()
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
        refreshTimerState(force: force)
    }

    func refreshTimerState(force: Bool = false) {
        let shouldPause = pausedForSystem || pausedForActivity
        guard force || shouldPause != refreshPaused else { return }
        refreshPaused = shouldPause
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
        gradientViews().forEach { $0.setMode(mode) }
        if randomize {
            randomizeSharedScene()
        } else {
            syncDisplaysToPrimaryScene()
        }
        refreshLockScreenWallpaper()
        updateRandomSceneTimer()
        updateMenuState()
    }

    func randomizeScenes(ignorePause: Bool = false) {
        guard ignorePause || (!pausedForSystem && !pausedForActivity) else { return }
        randomizeSharedScene()
        refreshLockScreenWallpaper()
    }

    func randomizeSharedScene() {
        guard let primaryView = gradientViews().first else { return }
        primaryView.randomizeScene()
        applySceneStateToAllDisplays(primaryView.portableSceneState())
    }

    func syncDisplaysToPrimaryScene() {
        guard let primaryState = gradientViews().first?.portableSceneState() else { return }
        applySceneStateToAllDisplays(primaryState)
    }

    @discardableResult
    func applySceneStateToAllDisplays(_ scene: [String: Any]) -> Bool {
        var applied = false
        for view in gradientViews() {
            applied = view.applySceneState(scene) || applied
        }
        return applied
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

    func currentScenePayload(updatedAt: Date = Date()) -> [String: Any]? {
        let scenes = NSScreen.screens.enumerated().compactMap { index, screen -> [String: Any]? in
            guard let view = gradientView(for: screen) else { return nil }
            return view.sceneState(for: screen, index: index)
        }
        guard !scenes.isEmpty else { return nil }

        return [
            "version": 1,
            "updatedAt": updatedAt.timeIntervalSince1970,
            "mode": wallpaperMode.rawValue,
            "scenes": scenes
        ]
    }

    func saveCurrentSceneState() {
        guard let payload = currentScenePayload(),
              let url = currentSceneStateURL() else { return }

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
        updateSavedScenesMenu()
    }

    // MARK: - Saved scenes

    func loadSavedSceneRecords() -> [[String: Any]] {
        guard let url = savedScenesStateURL(),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let records = payload["savedScenes"] as? [[String: Any]]
        else { return [] }

        return records
    }

    func writeSavedSceneRecords(_ records: [[String: Any]]) {
        guard let url = savedScenesStateURL() else { return }
        let payload: [String: Any] = [
            "version": 1,
            "updatedAt": Date().timeIntervalSince1970,
            "savedScenes": records
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

    func savedSceneName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d, HH:mm"
        return "Scene \(formatter.string(from: date))"
    }

    func savedSceneTitle(_ record: [String: Any], fallbackIndex: Int) -> String {
        if let name = record["name"] as? String, !name.isEmpty {
            return name
        }
        return "Saved Scene \(fallbackIndex + 1)"
    }

    func applySavedSceneRecord(_ record: [String: Any]) {
        guard let scenes = record["scenes"] as? [[String: Any]],
              applySceneStates(scenes)
        else { return }

        applyMode(.paused, randomize: false)
    }

    func applySceneStates(_ sceneStates: [[String: Any]]) -> Bool {
        let referenceScreen = NSScreen.main ?? NSScreen.screens.first
        let scene = referenceScreen.flatMap { bestScene(from: sceneStates, for: $0, index: 0) } ?? sceneStates.first
        guard let scene else { return false }
        return applySceneStateToAllDisplays(scene)
    }

    func bestScene(from sceneStates: [[String: Any]], for screen: NSScreen, index: Int) -> [String: Any]? {
        if let exact = sceneStates.first(where: { intValue($0["index"]) == index }) {
            return exact
        }

        let targetAspect = screen.frame.height > 0 ? Double(screen.frame.width / screen.frame.height) : 1
        return sceneStates.min { left, right in
            let leftAspect = doubleValue(left["aspectRatio"]) ?? 1
            let rightAspect = doubleValue(right["aspectRatio"]) ?? 1
            return abs(leftAspect - targetAspect) < abs(rightAspect - targetAspect)
        }
    }

    func doubleValue(_ value: Any?) -> Double? {
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        return value as? Double
    }

    func intValue(_ value: Any?) -> Int? {
        if let number = value as? NSNumber {
            return number.intValue
        }
        return value as? Int
    }

    func updateSavedScenesMenu() {
        guard let savedScenesMenu else { return }
        savedScenesMenu.removeAllItems()

        let browseItem = NSMenuItem(title: "Browse Saved Scenes...", action: #selector(showSavedScenesBrowser), keyEquivalent: "b")
        browseItem.target = self
        savedScenesMenu.addItem(browseItem)
        savedScenesMenu.addItem(.separator())

        let records = loadSavedSceneRecords()
        guard !records.isEmpty else {
            let emptyItem = NSMenuItem(title: "No Saved Scenes", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            savedScenesMenu.addItem(emptyItem)
            return
        }

        for (index, record) in records.enumerated() {
            let item = NSMenuItem(title: savedSceneTitle(record, fallbackIndex: index),
                                  action: #selector(loadSavedScene(_:)),
                                  keyEquivalent: "")
            item.target = self
            item.representedObject = record["id"] as? String
            savedScenesMenu.addItem(item)
        }

        savedScenesMenu.addItem(.separator())
        let clearItem = NSMenuItem(title: "Clear Saved Scenes", action: #selector(clearSavedScenes), keyEquivalent: "")
        clearItem.target = self
        savedScenesMenu.addItem(clearItem)
    }

    // MARK: - Menu bar

    func makeStatusIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18))
        image.lockFocus()
        if let context = NSGraphicsContext.current?.cgContext {
            context.setStrokeColor(NSColor.white.cgColor)
            context.setLineCap(.round)
            context.setLineJoin(.round)

            context.setLineWidth(2.15)
            context.beginPath()
            context.move(to: CGPoint(x: 14.4, y: 4.8))
            context.addCurve(to: CGPoint(x: 4.2, y: 8.1),
                             control1: CGPoint(x: 11.6, y: 2.4),
                             control2: CGPoint(x: 4.2, y: 2.7))
            context.addCurve(to: CGPoint(x: 13.7, y: 12.2),
                             control1: CGPoint(x: 4.2, y: 13.4),
                             control2: CGPoint(x: 10.8, y: 14.2))
            context.strokePath()

            context.setLineWidth(1.75)
            context.beginPath()
            context.move(to: CGPoint(x: 5.0, y: 12.9))
            context.addCurve(to: CGPoint(x: 12.5, y: 8.9),
                             control1: CGPoint(x: 7.4, y: 15.0),
                             control2: CGPoint(x: 14.0, y: 13.4))
            context.addCurve(to: CGPoint(x: 7.2, y: 7.2),
                             control1: CGPoint(x: 11.3, y: 5.5),
                             control2: CGPoint(x: 7.8, y: 5.4))
            context.strokePath()
        }
        image.unlockFocus()
        image.isTemplate = false
        return image
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = makeStatusIcon()
            button.imagePosition = .imageOnly
            button.title = ""
            button.alignment = .center
            button.toolTip = "Gradient Wallpaper"
            button.setAccessibilityLabel("Gradient Wallpaper")
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

        let saveCurrent = NSMenuItem(title: "Save Current Scene", action: #selector(saveCurrentSceneMenuItem), keyEquivalent: "s")
        saveCurrent.target = self
        menu.addItem(saveCurrent)

        let savedScenesRoot = NSMenuItem(title: "Saved Scenes", action: nil, keyEquivalent: "")
        let savedScenesMenu = NSMenu()
        savedScenesRoot.submenu = savedScenesMenu
        self.savedScenesMenu = savedScenesMenu
        menu.addItem(savedScenesRoot)

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

    @objc func saveCurrentSceneMenuItem() {
        let now = Date()
        guard var record = currentScenePayload(updatedAt: now) else { return }

        var records = loadSavedSceneRecords()
        record["id"] = UUID().uuidString
        record["name"] = savedSceneName(for: now)
        record["createdAt"] = now.timeIntervalSince1970
        records.insert(record, at: 0)
        if records.count > maxSavedScenes {
            records = Array(records.prefix(maxSavedScenes))
        }

        writeSavedSceneRecords(records)
        saveCurrentSceneState()
        updateSavedScenesMenu()
        savedSceneBrowser?.reloadRecords(selecting: record["id"] as? String)
    }

    @objc func showSavedScenesBrowser() {
        if savedSceneBrowser == nil {
            savedSceneBrowser = SavedSceneBrowserController(wallpaperDelegate: self)
        }
        savedSceneBrowser?.show()
    }

    @objc func loadSavedScene(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String,
              let record = loadSavedSceneRecords().first(where: { $0["id"] as? String == id })
        else { return }

        applySavedSceneRecord(record)
    }

    @objc func clearSavedScenes() {
        let alert = NSAlert()
        alert.messageText = "Clear saved scenes?"
        alert.informativeText = "This removes saved Seonuk Gradient scenes from this Mac."
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else { return }
        if let url = savedScenesStateURL() {
            try? FileManager.default.removeItem(at: url)
        }
        updateSavedScenesMenu()
        savedSceneBrowser?.reloadRecords()
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
        view.setMode(wallpaperMode)
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
