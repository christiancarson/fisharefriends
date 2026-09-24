import Foundation
import Vision
import AppKit

let path = CommandLine.arguments[1]
guard let img = NSImage(contentsOfFile: path), let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { print("{}"); exit(0) }
let handler = VNImageRequestHandler(cgImage: cg, options: [:])
let faces = VNDetectFaceRectanglesRequest()
let saliency = VNGenerateAttentionBasedSaliencyImageRequest()
try? handler.perform([faces, saliency])
func box(_ r: CGRect) -> [Double] { [Double(r.minX), Double(1 - r.maxY), Double(r.width), Double(r.height)] }
let f = (faces.results ?? []).map { box($0.boundingBox) }
let s = ((saliency.results?.first as? VNSaliencyImageObservation)?.salientObjects ?? []).map { box($0.boundingBox) }
let out: [String: Any] = ["faces": f, "salient": s]
print(String(data: try! JSONSerialization.data(withJSONObject: out), encoding: .utf8)!)
