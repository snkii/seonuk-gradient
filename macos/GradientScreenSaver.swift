import ScreenSaver
import AppKit
import CoreGraphics

private let sceneStateDirectoryName = "Seonuk Gradient"
private let sceneStateFileName = "current_scene.json"

private func currentSceneStateURL() -> URL? {
    guard let directory = FileManager.default.urls(for: .applicationSupportDirectory,
                                                   in: .userDomainMask).first?
        .appendingPathComponent(sceneStateDirectoryName, isDirectory: true)
    else { return nil }
    return directory.appendingPathComponent(sceneStateFileName)
}

public class GradientScreenSaverView: ScreenSaverView {

    private struct RGB {
        var r, g, b: CGFloat
    }

    private struct Blob {
        var x, y, vx, vy, vr, radius, sx, sy, rot, colorElapsed: CGFloat
        var current, start, target: RGB
    }

    private let palette: [RGB] = [
        RGB(r: 250/255, g: 189/255, b:  47/255),
        RGB(r: 215/255, g: 153/255, b:  33/255),
        RGB(r: 254/255, g: 128/255, b:  25/255),
        RGB(r: 251/255, g:  73/255, b:  52/255),
        RGB(r: 184/255, g: 187/255, b:  38/255),
        RGB(r: 142/255, g: 192/255, b: 124/255),
        RGB(r: 131/255, g: 165/255, b: 152/255),
        RGB(r:  69/255, g: 133/255, b: 136/255),
        RGB(r: 211/255, g: 134/255, b: 155/255),
        RGB(r: 146/255, g: 131/255, b: 116/255),
    ]

    private static let fineFilmGrainTileSize: CGFloat = 96
    private static let coarseFilmGrainTileSize: CGFloat = 360
    private static let fineFilmGrainImage = makeFilmGrainImage(size: Int(fineFilmGrainTileSize), seed: 0x5E0A)
    private static let coarseFilmGrainImage = makeFilmGrainImage(size: Int(coarseFilmGrainTileSize), seed: 0xC0A4)

    private let blobSizeFactor: CGFloat = 0.90
    private let blurFactor: CGFloat = 0.22
    private let colorTransitionSeconds: CGFloat = 6.5

    private var blobs: [Blob] = []
    private var colorTimer: Timer?
    private var lastFrameTime: TimeInterval?

    public override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        animationTimeInterval = 1.0 / 15.0

        if !loadSavedScene() {
            initRandomBlobs()
        }

        colorTimer = Timer.scheduledTimer(withTimeInterval: 7.0, repeats: true) { [weak self] _ in
            self?.randomizeTargets()
        }
    }

    private func initRandomBlobs() {
        blobs.removeAll()
        for _ in 0..<3 {
            let color = randomColor()
            let velocity = randomVelocity()
            blobs.append(Blob(
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
            ))
        }
    }

    deinit {
        colorTimer?.invalidate()
    }

    private func loadSavedScene() -> Bool {
        guard let url = currentSceneStateURL(),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let scenes = payload["scenes"] as? [[String: Any]],
              let scene = bestScene(from: scenes),
              let blobStates = scene["blobs"] as? [[String: Any]]
        else { return false }

        let loadedBlobs = blobStates.compactMap { blob(from: $0) }
        guard loadedBlobs.count >= 3 else { return false }
        blobs = Array(loadedBlobs.prefix(3))
        return true
    }

    private func bestScene(from scenes: [[String: Any]]) -> [String: Any]? {
        let targetAspect = bounds.height > 0 ? Double(bounds.width / bounds.height) : 1
        return scenes.min { left, right in
            let leftAspect = doubleValue(left["aspectRatio"]) ?? 1
            let rightAspect = doubleValue(right["aspectRatio"]) ?? 1
            return abs(leftAspect - targetAspect) < abs(rightAspect - targetAspect)
        }
    }

    private func blob(from state: [String: Any]) -> Blob? {
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

        return Blob(x: x,
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

    private func color(from value: Any?) -> RGB? {
        guard let state = value as? [String: Any],
              let r = cgFloatValue(state["r"]),
              let g = cgFloatValue(state["g"]),
              let b = cgFloatValue(state["b"])
        else { return nil }
        return RGB(r: r, g: g, b: b)
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

    private func randomizeTargets() {
        for i in 0..<blobs.count {
            blobs[i].start = blobs[i].current
            blobs[i].target = randomColor()
            blobs[i].colorElapsed = 0
        }
    }

    private func randomColor() -> RGB {
        palette[Int.random(in: 0..<palette.count)]
    }

    private func randomBetween(_ min: CGFloat, _ max: CGFloat) -> CGFloat {
        min + CGFloat.random(in: 0...1) * (max - min)
    }

    private func randomVelocity() -> (vx: CGFloat, vy: CGFloat) {
        let angle = randomBetween(0, CGFloat.pi * 2)
        let speed = randomBetween(0.0026, 0.0054)
        return (cos(angle) * speed, sin(angle) * speed)
    }

    private static func nextFilmGrainSeed(_ seed: inout UInt32) -> UInt32 {
        seed ^= seed << 13
        seed ^= seed >> 17
        seed ^= seed << 5
        return seed
    }

    private static func makeFilmGrainImage(size: Int, seed: UInt32) -> CGImage? {
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

    private func easeInOut(_ t: CGFloat) -> CGFloat {
        let x = min(max(t, 0), 1)
        return x * x * (3 - 2 * x)
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }

    private func lerp(_ a: RGB, _ b: RGB, _ t: CGFloat) -> RGB {
        RGB(r: lerp(a.r, b.r, t), g: lerp(a.g, b.g, t), b: lerp(a.b, b.b, t))
    }

    public override func animateOneFrame() {
        let now = Date.timeIntervalSinceReferenceDate
        let dt = CGFloat(min(now - (lastFrameTime ?? now), 0.25))
        lastFrameTime = now

        for i in 0..<blobs.count {
            blobs[i].x += blobs[i].vx * dt
            blobs[i].y += blobs[i].vy * dt
            blobs[i].rot += blobs[i].vr * dt
            if blobs[i].x < -0.2 || blobs[i].x > 1.2 { blobs[i].vx = -blobs[i].vx }
            if blobs[i].y < -0.2 || blobs[i].y > 1.2 { blobs[i].vy = -blobs[i].vy }
            if blobs[i].colorElapsed < colorTransitionSeconds {
                blobs[i].colorElapsed += dt
                blobs[i].current = lerp(blobs[i].start, blobs[i].target,
                                        easeInOut(blobs[i].colorElapsed / colorTransitionSeconds))
            }
        }
        setNeedsDisplay(bounds)
    }

    public override func draw(_ rect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        ctx.setFillColor(CGColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1))
        ctx.fill(bounds)

        let minDim = min(bounds.width, bounds.height)
        for b in blobs {
            let size = b.radius * blobSizeFactor * minDim
            drawBlob(ctx: ctx,
                     cx: b.x * bounds.width,
                     cy: b.y * bounds.height,
                     size: size,
                     blur: blurFactor * minDim,
                     sx: b.sx,
                     sy: b.sy,
                     rot: b.rot,
                     color: b.current)
        }
        applyMeshFilmTexture(ctx: ctx, width: bounds.width, height: bounds.height)
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

        if let coarseImage = Self.coarseFilmGrainImage {
            ctx.setAlpha(0.05)
            drawTiledFilmGrain(ctx: ctx,
                               image: coarseImage,
                               tileSize: Self.coarseFilmGrainTileSize,
                               width: width,
                               height: height)
        }

        if let fineImage = Self.fineFilmGrainImage {
            ctx.setAlpha(0.10)
            drawTiledFilmGrain(ctx: ctx,
                               image: fineImage,
                               tileSize: Self.fineFilmGrainTileSize,
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

    private func drawBlob(ctx: CGContext, cx: CGFloat, cy: CGFloat, size: CGFloat,
                          blur: CGFloat, sx: CGFloat, sy: CGFloat, rot: CGFloat,
                          color: RGB) {
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
}
