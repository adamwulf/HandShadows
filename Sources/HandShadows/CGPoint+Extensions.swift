//
//  File.swift
//  
//
//  Created by Adam Wulf on 1/20/24.
//

import CoreGraphics

extension CGPoint {
    func average(with point: CGPoint, weight: CGFloat) -> CGPoint {
        return CGPoint(x: self.x*weight + point.x*(1-weight), y: self.y*weight + point.y*(1-weight))
    }

}
