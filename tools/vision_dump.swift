import AppKit
import Vision

let path = CommandLine.arguments[1]
guard let img = NSImage(contentsOfFile: path),
      let rep = img.representations.first as? NSBitmapImageRep,
      let cg = rep.cgImage else {
    fputs("no image\n", stderr)
    exit(1)
}

let req = VNRecognizeTextRequest()
req.recognitionLevel = .accurate
let handler = VNImageRequestHandler(cgImage: cg, options: [:])
try handler.perform([req])
guard let results = req.results else { exit(0) }
for obs in results {
    guard let c = obs.topCandidates(1).first else { continue }
    let t = c.string
    if t.lowercased().contains("gisk") {
        print("\(t)\t\(obs.boundingBox)")
    }
}
