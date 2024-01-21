//
//  IndexFingerShadow.swift
//
//
//  Created by Adam Wulf on 1/19/24.
//

import PerformanceBezier
import UIKit

class IndexFingerShadow: NSObject {
    let handType: HandType
    var boundingBox: CGRect
    let indexFingerTipPath: UIBezierPath
    let pointerFingerPath: UIBezierPath

    override private init() {
        fatalError("This initializer is not available")
    }

    init(for hand: HandType) {
        handType = hand
        boundingBox = CGRect(x: 0, y: 0, width: 100, height: 227)
        boundingBox = boundingBox.applying(CGAffineTransform(scaleX: 4, y: 4))
        let paths = Self.scaledPaths(for: boundingBox.size)
        indexFingerTipPath = paths.indexFingerTipPath
        pointerFingerPath = paths.pointerFingerPath

        super.init()

        if handType == .leftHand {
            flipPathAroundYAxis(pointerFingerPath)
            flipPathAroundYAxis(indexFingerTipPath)
        }
    }

    var path: UIBezierPath {
        return pointerFingerPath
    }

    var locationOfIndexFingerInPathBounds: CGPoint {
        return indexFingerTipPath.center()
    }

    static func scaledPaths(for sizeOfHand: CGSize) -> (pointerFingerPath: UIBezierPath, indexFingerTipPath: UIBezierPath) {
        let handFrame = CGRect(x: 0, y: 0, width: sizeOfHand.width, height: sizeOfHand.height)

        let pointerFingerPath = UIBezierPath()
        pointerFingerPath.move(to: CGPoint(x: handFrame.minX + 0.28066 * handFrame.width, y: handFrame.minY + 0.95491 * handFrame.height))
        pointerFingerPath.addLine(to: CGPoint(x: handFrame.minX + 0.77766 * handFrame.width, y: handFrame.minY + 0.95491 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.74352 * handFrame.width, y: handFrame.minY + 0.86437 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.77766 * handFrame.width, y: handFrame.minY + 0.95491 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.75490 * handFrame.width, y: handFrame.minY + 0.88740 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.66005 * handFrame.width, y: handFrame.minY + 0.67666 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.73214 * handFrame.width, y: handFrame.minY + 0.84129 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.66385 * handFrame.width, y: handFrame.minY + 0.68329 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.62212 * handFrame.width, y: handFrame.minY + 0.57129 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.65625 * handFrame.width, y: handFrame.minY + 0.67008 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.61452 * handFrame.width, y: handFrame.minY + 0.58283 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.66764 * handFrame.width, y: handFrame.minY + 0.51041 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.62970 * handFrame.width, y: handFrame.minY + 0.55980 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.64867 * handFrame.width, y: handFrame.minY + 0.51865 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.71696 * handFrame.width, y: handFrame.minY + 0.45114 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.68661 * handFrame.width, y: handFrame.minY + 0.50216 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.71317 * handFrame.width, y: handFrame.minY + 0.47088 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.72708 * handFrame.width, y: handFrame.minY + 0.38420 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.72075 * handFrame.width, y: handFrame.minY + 0.43136 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.72450 * handFrame.width, y: handFrame.minY + 0.39306 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.73214 * handFrame.width, y: handFrame.minY + 0.35675 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.72965 * handFrame.width, y: handFrame.minY + 0.37535 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.73468 * handFrame.width, y: handFrame.minY + 0.36662 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.70938 * handFrame.width, y: handFrame.minY + 0.31174 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.72961 * handFrame.width, y: handFrame.minY + 0.34688 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.72202 * handFrame.width, y: handFrame.minY + 0.31947 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.59809 * handFrame.width, y: handFrame.minY + 0.29091 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.69672 * handFrame.width, y: handFrame.minY + 0.30407 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.67396 * handFrame.width, y: handFrame.minY + 0.27117 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.49691 * handFrame.width, y: handFrame.minY + 0.26459 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.59809 * handFrame.width, y: handFrame.minY + 0.29091 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.58038 * handFrame.width, y: handFrame.minY + 0.24919 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.45138 * handFrame.width, y: handFrame.minY + 0.22944 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.49691 * handFrame.width, y: handFrame.minY + 0.26459 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.51715 * handFrame.width, y: handFrame.minY + 0.23602 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.34768 * handFrame.width, y: handFrame.minY + 0.25576 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.38562 * handFrame.width, y: handFrame.minY + 0.22286 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.34768 * handFrame.width, y: handFrame.minY + 0.25576 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.31227 * handFrame.width, y: handFrame.minY + 0.23383 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.34768 * handFrame.width, y: handFrame.minY + 0.25576 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.31986 * handFrame.width, y: handFrame.minY + 0.24260 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.27687 * handFrame.width, y: handFrame.minY + 0.14052 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.30468 * handFrame.width, y: handFrame.minY + 0.22505 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.28951 * handFrame.width, y: handFrame.minY + 0.16469 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.24397 * handFrame.width, y: handFrame.minY + 0.04612 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.26421 * handFrame.width, y: handFrame.minY + 0.11640 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.25409 * handFrame.width, y: handFrame.minY + 0.05494 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.19592 * handFrame.width, y: handFrame.minY + 0.03186 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.23386 * handFrame.width, y: handFrame.minY + 0.03735 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.22122 * handFrame.width, y: handFrame.minY + 0.03077 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.15292 * handFrame.width, y: handFrame.minY + 0.05165 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.17063 * handFrame.width, y: handFrame.minY + 0.03296 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.15797 * handFrame.width, y: handFrame.minY + 0.04064 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.15798 * handFrame.width, y: handFrame.minY + 0.14162 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.14786 * handFrame.width, y: handFrame.minY + 0.06261 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.15798 * handFrame.width, y: handFrame.minY + 0.13613 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.16810 * handFrame.width, y: handFrame.minY + 0.18882 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.15798 * handFrame.width, y: handFrame.minY + 0.14710 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.16304 * handFrame.width, y: handFrame.minY + 0.17895 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.19086 * handFrame.width, y: handFrame.minY + 0.27335 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.17316 * handFrame.width, y: handFrame.minY + 0.19869 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.19338 * handFrame.width, y: handFrame.minY + 0.26672 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.19340 * handFrame.width, y: handFrame.minY + 0.33700 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.18833 * handFrame.width, y: handFrame.minY + 0.27993 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.19592 * handFrame.width, y: handFrame.minY + 0.32713 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.20098 * handFrame.width, y: handFrame.minY + 0.40833 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.19086 * handFrame.width, y: handFrame.minY + 0.34687 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.19845 * handFrame.width, y: handFrame.minY + 0.39407 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.22627 * handFrame.width, y: handFrame.minY + 0.48514 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.20350 * handFrame.width, y: handFrame.minY + 0.42258 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.22374 * handFrame.width, y: handFrame.minY + 0.47527 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.24904 * handFrame.width, y: handFrame.minY + 0.54555 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.22881 * handFrame.width, y: handFrame.minY + 0.49505 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.24904 * handFrame.width, y: handFrame.minY + 0.53563 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.26928 * handFrame.width, y: handFrame.minY + 0.64648 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.24904 * handFrame.width, y: handFrame.minY + 0.55541 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.26168 * handFrame.width, y: handFrame.minY + 0.62235 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.29457 * handFrame.width, y: handFrame.minY + 0.80563 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.27687 * handFrame.width, y: handFrame.minY + 0.67065 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.29962 * handFrame.width, y: handFrame.minY + 0.79247 * handFrame.height))
        pointerFingerPath.addCurve(to: CGPoint(x: handFrame.minX + 0.28066 * handFrame.width, y: handFrame.minY + 0.95491 * handFrame.height), controlPoint1: CGPoint(x: handFrame.minX + 0.28951 * handFrame.width, y: handFrame.minY + 0.81884 * handFrame.height), controlPoint2: CGPoint(x: handFrame.minX + 0.27939 * handFrame.width, y: handFrame.minY + 0.93627 * handFrame.height))
        pointerFingerPath.close()

        let indexFingerTipPath = UIBezierPath(ovalIn: CGRect(x: handFrame.minX + floor((handFrame.width - 7) * 0.18021 - 0.06) + 0.56, y: handFrame.minY + floor((handFrame.height - 7) * 0.04176 + 0.45) + 0.05, width: 7, height: 7))

        return (pointerFingerPath, indexFingerTipPath)
    }

    func flipPathAroundYAxis(_ path: UIBezierPath) {
        path.apply(CGAffineTransform(translationX: -boundingBox.size.width / 2 - boundingBox.origin.x, y: 0))
        path.apply(CGAffineTransform(scaleX: -1, y: 1))
        path.apply(CGAffineTransform(translationX: boundingBox.size.width / 2 + boundingBox.origin.x, y: 0))
    }
}
