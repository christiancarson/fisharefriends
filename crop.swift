import Foundation
import Vision
import AppKit

let path = CommandLine.arguments[1]
let fish = CommandLine.arguments.count > 2 && CommandLine.arguments[2] == "fish"
guard let img = NSImage(contentsOfFile: path), let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { print("{}"); exit(0) }
let handler = VNImageRequestHandler(cgImage: cg, options: [:])
let faces = VNDetectFaceRectanglesRequest()
let saliency = VNGenerateAttentionBasedSaliencyImageRequest()
try? handler.perform([faces, saliency])
func box(_ r: CGRect) -> [Double] { [Double(r.minX), Double(1 - r.maxY), Double(r.width), Double(r.height)] }
let f = (faces.results ?? []).map { box($0.boundingBox) }
let s = ((saliency.results?.first as? VNSaliencyImageObservation)?.salientObjects ?? []).map { box($0.boundingBox) }
var windows: [[Double]] = []
if fish {
  let W = Double(cg.width), H = Double(cg.height)
  let wide = W / H > 16.0 / 9.0
  let cw = wide ? H * 16 / 9 : W, ch = wide ? H : W * 9 / 16
  let span = wide ? W - cw : H - ch
  let words = ["fish", "trout", "salmon", "bass", "carp"]
  for i in 0..<11 {
    let t = Double(i) / 10
    let x = wide ? span * t : 0, y = wide ? 0 : span * t
    guard let sub = cg.cropping(to: CGRect(x: x, y: y, width: cw, height: ch)) else { continue }
    let req = VNClassifyImageRequest()
    try? VNImageRequestHandler(cgImage: sub, options: [:]).perform([req])
    let score = (req.results ?? []).filter { o in words.contains { o.identifier.contains($0) } }.map { Double($0.confidence) }.max() ?? 0
    windows.append([(x + cw / 2) / W, (y + ch / 2) / H, score])
  }
}
let out: [String: Any] = ["faces": f, "salient": s, "windows": windows]
print(String(data: try! JSONSerialization.data(withJSONObject: out), encoding: .utf8)!)
