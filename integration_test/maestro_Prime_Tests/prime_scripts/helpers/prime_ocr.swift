#!/usr/bin/env swift

// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Run Apple's Vision OCR on an image and print recognized text to stdout.
// Used by Maestro/Prime tests to scrape on-screen text (seed words, prompts)
// without taking a dependency on tesseract or a network OCR service.
//
// Default output is one recognized string per line.
//
// With --pos, each line is `<x>\t<y>\t<w>\t<h>\t<text>` where x,y are pixel
// coordinates of the bounding-box top-left (origin at image top-left) and
// w,h are pixel width/height. Center = (x+w/2, y+h/2). Sort by y (then x)
// to recover natural reading order regardless of how many columns the
// layout has.
//
// Usage:
//   swift scripts/prime_ocr.swift /tmp/shot.png
//   swift scripts/prime_ocr.swift /tmp/shot.png --pos

import Foundation
import Vision
import AppKit

guard CommandLine.arguments.count >= 2 else {
    FileHandle.standardError.write("usage: prime_ocr.swift <image>\n".data(using: .utf8)!)
    exit(2)
}

let path = CommandLine.arguments[1]
let emitPos = CommandLine.arguments.dropFirst(2).contains("--pos")

guard let img = NSImage(contentsOfFile: path),
      let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    FileHandle.standardError.write("could not load image: \(path)\n".data(using: .utf8)!)
    exit(1)
}
let w = Double(cg.width), h = Double(cg.height)

let req = VNRecognizeTextRequest { req, _ in
    for o in (req.results as? [VNRecognizedTextObservation]) ?? [] {
        guard let s = o.topCandidates(1).first?.string else { continue }
        if emitPos {
            // Vision uses a normalized coordinate system with origin at the
            // bottom-left; flip y so output uses image top-left origin.
            let b = o.boundingBox
            let x  = Int(b.origin.x * w)
            let y  = Int((1.0 - b.origin.y - b.size.height) * h)
            let bw = Int(b.size.width  * w)
            let bh = Int(b.size.height * h)
            print("\(x)\t\(y)\t\(bw)\t\(bh)\t\(s)")
        } else {
            print(s)
        }
    }
}
req.recognitionLevel = .accurate
req.usesLanguageCorrection = false

try VNImageRequestHandler(cgImage: cg, options: [:]).perform([req])
