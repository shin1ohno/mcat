//
//  MarqueeText.swift
//  MCat
//

import SwiftUI

struct MarqueeText: View {
    let text: String
    var maxDisplayWidth: CGFloat = 190
    var speed: CGFloat = 30
    var gap: CGFloat = 40

    @State private var startDate = Date.now

    static func textWidth(_ text: String, font: NSFont = .menuBarFont(ofSize: 0)) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        return (text as NSString).size(withAttributes: attributes).width
    }

    var body: some View {
        let width = Self.textWidth(text)
        if width <= maxDisplayWidth {
            Text(text)
        } else {
            let cycleWidth = width + gap
            TimelineView(.animation) { context in
                let elapsed = context.date.timeIntervalSince(startDate)
                let offset = CGFloat(elapsed) * speed
                let clippedOffset = offset.truncatingRemainder(dividingBy: cycleWidth)
                HStack(spacing: gap) {
                    Text(text)
                    Text(text)
                }
                .fixedSize()
                .offset(x: -clippedOffset)
            }
            .frame(width: maxDisplayWidth, alignment: .leading)
            .clipped()
            .onChange(of: text) {
                startDate = .now
            }
        }
    }
}
