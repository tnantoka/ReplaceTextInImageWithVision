//
//  Replacer.swift
//  ReplaceTextInImageWithVision
//
//  Created by Tatsuya Tobioka on 2023/08/15.
//

import SwiftUI
import Vision

struct ReplaceItem {
    var string: String
    var rect: CGRect
}

class Replacer: ObservableObject {
    private var originalImage = UIImage(named: "demo.png") ?? UIImage()
    @Published var image = UIImage(named: "demo.png") ?? UIImage()
    
    func replace(target: String, replacement: String) {
        guard let cgImage = image.cgImage else { return }

        var items = [ReplaceItem]()
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let maximumCandidates = 1
            var recognizedText = ""
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                recognizedText += candidate.string
                
                items.append(
                    ReplaceItem(string: candidate.string, rect: observation.boundingBox)
                )
            }
        }
        request.recognitionLanguages = ["ja-JP"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try? handler.perform([request])
        
        replaceImage(items: items, target: target, replacement: replacement)
    }
    
    private func replaceImage(items: [ReplaceItem], target: String, replacement: String) {
        let renderer = UIGraphicsImageRenderer(size: originalImage.size)
        
        let replacedImage = renderer.image { context in
            originalImage.draw(at: CGPoint.zero)
            
            UIColor.white.setFill()
            
            var text = ""
            let padding = 1.2
            
            items.enumerated().forEach { i, item in
                text += item.string
                
                if (text == target) {
                    let rects = items[i - (target.count - 1)...i].map { item in
                        let rect = CGRect(
                            x: item.rect.minX * originalImage.size.width,
                            y: originalImage.size.height - item.rect.maxY * originalImage.size.height,
                            width: item.rect.width * originalImage.size.width * padding,
                            height: item.rect.height * originalImage.size.height * padding
                        )
                        return rect
                    }
                    
                    context.cgContext.fill(rects)
                    
                    rects.enumerated().forEach { i, rect in
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.alignment = .center
                        var textAttributes: [NSAttributedString.Key: Any] = [
                            .foregroundColor: UIColor.black,
                            .paragraphStyle: paragraphStyle,
                            .verticalGlyphForm: 1,
                        ]
                        let fontSize = findFontSizeToFit(text: item.string, attributes: textAttributes, rect: rect)
                        textAttributes[.font] = UIFont.systemFont(ofSize: fontSize)
                        
                        let substr = NSString(string: replacement).substring(with: NSRange(location: i, length: 1))
                        let attributedText = NSAttributedString(string: String(substr), attributes: textAttributes
                        )
                        attributedText.draw(in: rect)
                    }
                    
                    text = ""
                }
                
                if (!target.hasPrefix(text)) {
                    text = ""
                }
            }
        }
        
        image = replacedImage
    }
    
    func findFontSizeToFit(text: String, attributes: [NSAttributedString.Key: Any], rect: CGRect) -> CGFloat {
        var fontSize: CGFloat = 1.0
        let font = UIFont.systemFont(ofSize: fontSize)
        
        var attrs = attributes
        attrs[.font] = font
        
        var textSize = (text as NSString).size(withAttributes: attrs)
        
        while textSize.width < rect.height && textSize.height < rect.width {
            fontSize += 1.0
            let newFont = font.withSize(fontSize)
            attrs[.font] = newFont
            textSize = (text as NSString).size(withAttributes: attrs)
        }
        
        return max(fontSize - 1.0, 1.0)
    }
}
