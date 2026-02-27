//
//  MarqueeText.swift
//  MCat
//

import SwiftUI

@MainActor
@Observable
final class MarqueeTicker {
    private(set) var value: UInt64 = 0
    private var timer: Timer?

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.value &+= 1
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        value = 0
    }
}

struct MarqueeText: View {
    let text: String
    let tick: UInt64
    var maxDisplayWidth: CGFloat = 190
    var speed: CGFloat = 30

    static func textWidth(_ text: String, font: NSFont = .menuBarFont(ofSize: 0)) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }

    var body: some View {
        Text(displayText)
    }

    private var displayText: String {
        let textWidth = Self.textWidth(text)
        guard textWidth > maxDisplayWidth else { return text }

        let separator = "    "
        let fullText = text + separator
        let totalChars = fullText.count

        let avgCharWidth = textWidth / CGFloat(text.count)
        let charsPerSecond = speed / avgCharWidth
        let ticksPerChar = max(1, Int(round(30.0 / charsPerSecond)))
        let charOffset = Int(tick / UInt64(ticksPerChar)) % totalChars

        let startIdx = fullText.index(fullText.startIndex, offsetBy: charOffset)
        let rotated = String(fullText[startIdx...]) + String(fullText[..<startIdx])

        var display = ""
        var width: CGFloat = 0
        for char in rotated {
            let charWidth = Self.textWidth(String(char))
            if width + charWidth > maxDisplayWidth { break }
            display.append(char)
            width += charWidth
        }
        return display
    }
}
