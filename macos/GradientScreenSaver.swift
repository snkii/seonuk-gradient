import ScreenSaver
import AppKit
import CoreGraphics

public class GradientScreenSaverView: ScreenSaverView {

    private let palette: [(CGFloat, CGFloat, CGFloat)] = [
        (250/255, 189/255,  47/255),
        (254/255, 128/255,  25/255),
        (251/255,  73/255,  52/255),
        (211/255, 134/255, 155/255),
        (184/255, 187/255,  38/255),
        (142/255, 192/255, 124/255),
        (131/255, 165/255, 152/255),
        ( 69/255, 133/255, 136/255),
    ]

    private struct Blob {
        var x, y, vx, vy, r: CGFloat
        var cr, cg, cb: CGFloat
        var tr, tg, tb: CGFloat
    }

    private var blobs: [Blob] = []
    private var colorTimer: Timer?

    public override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        animationTimeInterval = 1.0 / 60.0

        let positions:  [(CGFloat, CGFloat)] = [(0.22, 0.45), (0.78, 0.20), (0.52, 0.78)]
        let velocities: [(CGFloat, CGFloat)] = [(0.00022, 0.00016), (-0.00018, 0.00021), (0.00014, -0.00023)]
        let radii:      [CGFloat]            = [0.70, 0.65, 0.60]

        for i in 0..<3 {
            let c = palette[i]
            blobs.append(Blob(
                x: positions[i].0,  y: positions[i].1,
                vx: velocities[i].0, vy: velocities[i].1,
                r: radii[i],
                cr: c.0, cg: c.1, cb: c.2,
                tr: c.0, tg: c.1, tb: c.2
            ))
        }

        randomizeTargets()

        colorTimer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { [weak self] _ in
            self?.randomizeTargets()
        }
    }

    private func randomizeTargets() {
        let shuffled = palette.shuffled()
        for i in 0..<blobs.count {
            blobs[i].tr = shuffled[i].0
            blobs[i].tg = shuffled[i].1
            blobs[i].tb = shuffled[i].2
        }
    }

    private func lerp(_ a: CGFloat, _ b: CGFloat) -> CGFloat { a + (b - a) * 0.025 }

    public override func animateOneFrame() {
        for i in 0..<blobs.count {
            blobs[i].x += blobs[i].vx
            blobs[i].y += blobs[i].vy
            if blobs[i].x < -0.2 || blobs[i].x > 1.2 { blobs[i].vx = -blobs[i].vx }
            if blobs[i].y < -0.2 || blobs[i].y > 1.2 { blobs[i].vy = -blobs[i].vy }
            blobs[i].cr = lerp(blobs[i].cr, blobs[i].tr)
            blobs[i].cg = lerp(blobs[i].cg, blobs[i].tg)
            blobs[i].cb = lerp(blobs[i].cb, blobs[i].tb)
        }
        setNeedsDisplay(bounds)
    }

    public override func draw(_ rect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        ctx.setFillColor(CGColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1))
        ctx.fill(bounds)

        let minDim = min(bounds.width, bounds.height)
        for b in blobs {
            drawBlob(ctx: ctx,
                     cx: b.x * bounds.width,
                     cy: b.y * bounds.height,
                     r:  b.r * minDim,
                     r_: b.cr, g_: b.cg, b_: b.cb)
        }
    }

    private func drawBlob(ctx: CGContext, cx: CGFloat, cy: CGFloat, r: CGFloat,
                          r_: CGFloat, g_: CGFloat, b_: CGFloat) {
        let cs = CGColorSpaceCreateDeviceRGB()
        let colors = [
            CGColor(colorSpace: cs, components: [r_, g_, b_, 133/255])!,
            CGColor(colorSpace: cs, components: [r_, g_, b_, 56/255])!,
            CGColor(colorSpace: cs, components: [r_, g_, b_, 15/255])!,
            CGColor(colorSpace: cs, components: [r_, g_, b_, 0])!,
        ] as CFArray
        let locs: [CGFloat] = [0, 0.45, 0.75, 1]
        guard let grad = CGGradient(colorsSpace: cs, colors: colors, locations: locs) else { return }

        ctx.saveGState()
        ctx.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        ctx.clip()
        ctx.drawRadialGradient(grad,
                               startCenter: CGPoint(x: cx, y: cy), startRadius: 0,
                               endCenter:   CGPoint(x: cx, y: cy), endRadius: r,
                               options: [])
        ctx.restoreGState()
    }
}
