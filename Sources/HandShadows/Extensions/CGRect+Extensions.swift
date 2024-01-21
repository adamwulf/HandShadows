//
//  CGRect+Extensions.swift
//
//
//  Created by Adam Wulf on 1/20/24.
//

import UIKit

extension CGRect {
    func flipPathAroundMidY(_ path: UIBezierPath) {
        path.apply(CGAffineTransform(translationX: -size.width / 2 - origin.x, y: 0))
        path.apply(CGAffineTransform(scaleX: -1, y: 1))
        path.apply(CGAffineTransform(translationX: size.width / 2 + origin.x, y: 0))
    }
}
