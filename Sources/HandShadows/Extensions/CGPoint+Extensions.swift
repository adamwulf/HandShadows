//
//  CGPoint+Extensions.swift
//
//
//  Created by Adam Wulf on 1/20/24.
//

import CoreGraphics

extension CGPoint {
    func average(with point: CGPoint, weight: CGFloat) -> CGPoint {
        return CGPoint(x: x * weight + point.x * (1 - weight), y: y * weight + point.y * (1 - weight))
    }

    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - x, 2) + pow(point.y - y, 2))
    }
}
