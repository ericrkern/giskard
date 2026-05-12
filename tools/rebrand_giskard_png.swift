import AppKit
import Vision

/// Replace visible Giskard / GISKARD branding with ZerothGuard in PNGs (Vision OCR + redraw).

extension String {
    func replacingGiskardBranding() -> String {
        var s = self
        s = s.replacingOccurrences(of: "GISKARD", with: "ZerothGuard")
        s = s.replacingOccurrences(of: "Giskard", with: "ZerothGuard")
        s = s.replacingOccurrences(of: "giskard", with: "ZerothGuard")
        // Vision often misreads “AI” as “Al” on diagram titles.
        s = s.replacingOccurrences(of: "Al-Powered", with: "AI-Powered")
        s = s.replacingOccurrences(of: "Al -Powered", with: "AI-Powered")
        return s
    }
}

func containsGiskard(_ s: String) -> Bool {
    s.range(of: "giskard", options: .caseInsensitive) != nil
}

/// Vision bounding box → pixel rect with origin at **top-left** (y increases downward).
func pixelRectTopLeft(_ box: CGRect, w: Int, h: Int) -> CGRect {
    let x = box.origin.x * CGFloat(w)
    let rw = box.size.width * CGFloat(w)
    let rh = box.size.height * CGFloat(h)
    let y = (1 - box.origin.y - box.size.height) * CGFloat(h)
    return CGRect(x: x, y: y, width: rw, height: rh)
}

func colorAtTopLeft(rep: NSBitmapImageRep, x: Int, yTop: Int) -> NSColor? {
    let h = rep.pixelsHigh
    let yBL = h - 1 - yTop
    return rep.colorAt(x: x, y: yBL)
}

/// Approximate background: median RGB in an expanded frame around `rect` (top-left coords), skipping interior.
func medianBackground(rep: NSBitmapImageRep, rect: CGRect, pad: Int) -> (CGFloat, CGFloat, CGFloat) {
    let w = rep.pixelsWide
    let h = rep.pixelsHigh
    let outer = rect.insetBy(dx: CGFloat(-pad), dy: CGFloat(-pad))
    var samples: [(CGFloat, CGFloat, CGFloat)] = []

    let xmin = max(0, Int(outer.minX))
    let xmax = min(w - 1, Int(outer.maxX))
    let ymin = max(0, Int(outer.minY))
    let ymax = min(h - 1, Int(outer.maxY))
    let ix0 = max(0, Int(rect.minX))
    let ix1 = min(w - 1, Int(rect.maxX))
    let iy0 = max(0, Int(rect.minY))
    let iy1 = min(h - 1, Int(rect.maxY))

    for y in ymin...ymax {
        for x in xmin...xmax {
            let outside = x < ix0 || x > ix1 || y < iy0 || y > iy1
            guard outside else { continue }
            guard let c = colorAtTopLeft(rep: rep, x: x, yTop: y) else { continue }
            samples.append((c.redComponent, c.greenComponent, c.blueComponent))
        }
    }

    if samples.isEmpty {
        for y in ymin...ymax {
            for x in xmin...xmax {
                guard let c = colorAtTopLeft(rep: rep, x: x, yTop: y) else { continue }
                samples.append((c.redComponent, c.greenComponent, c.blueComponent))
            }
        }
    }

    let sorted = samples.sorted { ($0.0 + $0.1 + $0.2) < ($1.0 + $1.1 + $1.2) }
    let i = max(0, sorted.count / 2)
    if sorted.isEmpty { return (0.12, 0.18, 0.42) }
    return sorted[min(i, sorted.count - 1)]
}

func luminance(_ t: (CGFloat, CGFloat, CGFloat)) -> CGFloat {
    0.2126 * t.0 + 0.7152 * t.1 + 0.0722 * t.2
}

func processImage(path: String) throws {
    guard let src = NSImage(contentsOfFile: path),
          let data = src.tiffRepresentation,
          let rep = NSBitmapImageRep(data: data) else {
        throw NSError(domain: "rebrand", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot load \(path)"])
    }

    let w = rep.pixelsWide
    let h = rep.pixelsHigh
    guard let cg = rep.cgImage else { return }

    let req = VNRecognizeTextRequest()
    req.recognitionLevel = .accurate
    let handler = VNImageRequestHandler(cgImage: cg, options: [:])
    try handler.perform([req])
    let observations = req.results ?? []

    var hits: [(String, CGRect)] = []
    for obs in observations {
        guard let cand = obs.topCandidates(1).first else { continue }
        let text = cand.string
        guard containsGiskard(text) else { continue }
        hits.append((text.replacingGiskardBranding(), obs.boundingBox))
    }

    if hits.isEmpty {
        print("ok (no Giskard text): \(path)")
        return
    }

    guard let outRep = rep.copy() as? NSBitmapImageRep else {
        throw NSError(domain: "rebrand", code: 3, userInfo: [NSLocalizedDescriptionKey: "bitmap copy"])
    }

    guard let gfx = NSGraphicsContext(bitmapImageRep: outRep) else {
        throw NSError(domain: "rebrand", code: 4, userInfo: [NSLocalizedDescriptionKey: "graphics context"])
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = gfx
    let ctx = gfx.cgContext

    ctx.interpolationQuality = .high
    ctx.saveGState()
    ctx.translateBy(x: 0, y: CGFloat(h))
    ctx.scaleBy(x: 1, y: -1)
    // `outRep` is a pixel copy of `rep`; only paint over rebranded regions.
    ctx.setShouldAntialias(true)

    for (newText, vbox) in hits {
        var rect = pixelRectTopLeft(vbox, w: w, h: h)
        let pad: CGFloat = 3
        rect = rect.insetBy(dx: -pad, dy: -pad)

        let inner = rect.insetBy(dx: pad, dy: pad)
        let bg = medianBackground(rep: rep, rect: inner, pad: 6)
        let bgL = luminance(bg)
        let fg: NSColor = bgL > 0.55 ? NSColor(calibratedRed: 0.1, green: 0.12, blue: 0.2, alpha: 1) : .white

        ctx.setFillColor(NSColor(calibratedRed: bg.0, green: bg.1, blue: bg.2, alpha: 1).cgColor)
        ctx.fill(rect)

        var fontSize = min(max(rect.height * 0.72, 8), 46)
        let maxWidth = rect.width * 0.98
        let fontWeight: NSFont.Weight = rect.height > 22 ? .bold : .medium

        func measure(_ size: CGFloat) -> CGFloat {
            let font = NSFont.systemFont(ofSize: size, weight: fontWeight)
            let a: [NSAttributedString.Key: Any] = [.font: font]
            let s = NSAttributedString(string: newText, attributes: a)
            return s.boundingRect(with: NSSize(width: 10000, height: 10000), options: [.usesLineFragmentOrigin, .usesFontLeading]).width
        }

        while fontSize > 6.5 && measure(fontSize) > maxWidth {
            fontSize -= 0.5
        }

        let font = NSFont.systemFont(ofSize: fontSize, weight: fontWeight)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fg,
        ]
        let asr = NSAttributedString(string: newText, attributes: attrs)
        let box = asr.boundingRect(with: NSSize(width: maxWidth, height: 2000), options: [.usesLineFragmentOrigin, .usesFontLeading])
        let drawOrigin = CGPoint(x: rect.midX - box.width / 2, y: rect.midY - box.height / 2)
        asr.draw(with: CGRect(origin: drawOrigin, size: box.size), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
    }

    ctx.restoreGState()
    NSGraphicsContext.restoreGraphicsState()

    guard let png = outRep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "rebrand", code: 2, userInfo: [NSLocalizedDescriptionKey: "encode png"])
    }

    try png.write(to: URL(fileURLWithPath: path))
    print("updated: \(path) (\(hits.count) regions)")
}

let args = Array(CommandLine.arguments.dropFirst())
guard !args.isEmpty else {
    print("usage: swift rebrand_giskard_png.swift <file.png> ...")
    exit(1)
}

for a in args {
    do {
        try processImage(path: a)
    } catch {
        fputs("error \(a): \(error)\n", stderr)
        exit(1)
    }
}
