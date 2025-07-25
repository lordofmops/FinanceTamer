//
//  PieChartView.swift
//  Utilities
//
//  Created by Дарья Дробышева on 25.07.2025.
//

import UIKit

public class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet {
            calculateSegments()
            setNeedsDisplay()
        }
    }
    public var innerBackgroundColor: UIColor = .black
    
    public var segmentColors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemGray
    ]

    private var segments: [Segment] = []
    
    private struct Segment {
        let value: CGFloat
        let label: String
        let color: UIColor
    }

    private func calculateSegments() {
        let top5 = entities.prefix(5)
        let restSum = entities.dropFirst(5).reduce(Decimal(0)) { $0 + $1.value }
        
        var all = Array(top5)
        if restSum > 0 {
            all.append(Entity(value: restSum, label: "Остальные"))
        }

        let total = all.reduce(CGFloat(0)) { $0 + CGFloat(truncating: $1.value as NSNumber) }

        segments = all.enumerated().map { (index, entity) in
            Segment(
                value: CGFloat(truncating: entity.value as NSNumber) / total,
                label: entity.label,
                color: segmentColors[index % segmentColors.count]
            )
        }
    }

    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext(), !segments.isEmpty else { return }

        let radius = min(bounds.width, bounds.height) / 2 - 10
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        var startAngle: CGFloat = -.pi / 2

        for segment in segments {
            let endAngle = startAngle + segment.value * 2 * .pi
            ctx.setFillColor(segment.color.cgColor)
            ctx.move(to: center)
            ctx.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            ctx.closePath()
            ctx.fillPath()
            startAngle = endAngle
        }

        let holeRadius = radius * 0.9
        let holeRect = CGRect(
            x: center.x - holeRadius,
            y: center.y - holeRadius,
            width: holeRadius * 2,
            height: holeRadius * 2
        )
        ctx.setFillColor(innerBackgroundColor.cgColor)
        ctx.fillEllipse(in: holeRect)
        ctx.setBlendMode(.normal)

        let font = UIFont.systemFont(ofSize: 10)
        let lineHeight: CGFloat = 20
        let circleRadius: CGFloat = 5
        let spacing: CGFloat = 6

        let totalHeight = CGFloat(segments.count) * lineHeight
        let startY = center.y - totalHeight / 2

        for (index, segment) in segments.enumerated() {
            let percent = Int(round(segment.value * 100))
            let text = "\(percent)% \(segment.label)"

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor(named: "header") ?? .black
            ]

            let circleX = center.x - 50
            let circleY = startY + CGFloat(index) * lineHeight + (lineHeight - circleRadius * 2) / 2
            let circleRect = CGRect(x: circleX, y: circleY, width: circleRadius * 2, height: circleRadius * 2)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            segment.color.setFill()
            circlePath.fill()

            let textX = circleX + circleRadius * 2 + spacing
            let textY = startY + CGFloat(index) * lineHeight
            let attributedText = NSAttributedString(string: text, attributes: textAttributes)
            attributedText.draw(at: CGPoint(x: textX, y: textY))
        }
    }


}
