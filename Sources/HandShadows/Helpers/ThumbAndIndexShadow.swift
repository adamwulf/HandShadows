//
//  ThumbAndIndexShadow.swift
//
//
//  Created by Adam Wulf on 1/19/24.
//

import PerformanceBezier
import UIKit

class ThumbAndIndexShadow: NSObject {
    let handType: HandType
    var lastInterpolatedPath: UIBezierPath
    var lastInterpolatedIndexFinger: CGPoint

    var boundingBox: CGRect
    var openPath: UIBezierPath
    var closedPath: UIBezierPath

    var openThumbTipPath: UIBezierPath
    var openIndexFingerTipPath: UIBezierPath
    var closedThumbTipPath: UIBezierPath
    var closedIndexFingerTipPath: UIBezierPath

    override private init() {
        fatalError("This initializer is not available")
    }

    init(for hand: HandType) {
        handType = hand
        boundingBox = CGRect(x: 0, y: 0, width: 200, height: 300)
        boundingBox = boundingBox.applying(CGAffineTransform(scaleX: 4, y: 4))

        let paths = Self.initPaths(for: boundingBox)
        openIndexFingerTipPath = paths.openIndexFingerTipPath
        openThumbTipPath = paths.openThumbTipPath
        closedIndexFingerTipPath = paths.closedIndexFingerTipPath
        closedThumbTipPath = paths.closedThumbTipPath
        openPath = paths.openPath
        closedPath = paths.closedPath
        lastInterpolatedPath = openPath
        lastInterpolatedIndexFinger = openIndexFingerTipPath.center()

        super.init()

        if handType.isRight {
            flipPathAroundYAxis(path: openPath)
            flipPathAroundYAxis(path: closedPath)
            flipPathAroundYAxis(path: openThumbTipPath)
            flipPathAroundYAxis(path: openIndexFingerTipPath)
            flipPathAroundYAxis(path: closedThumbTipPath)
            flipPathAroundYAxis(path: closedIndexFingerTipPath)
        }
    }

    func pathForTouches() -> UIBezierPath {
        return lastInterpolatedPath
    }

    func locationOfIndexFingerInPathBounds() -> CGPoint {
        return lastInterpolatedIndexFinger
    }

    func setFingerDistance(idealDistance: CGFloat) {
        let openDist = openThumbTipPath.center().distance(to: openIndexFingerTipPath.center())
        let closedDist = closedThumbTipPath.center().distance(to: closedIndexFingerTipPath.center())
        let perc = (idealDistance - closedDist) / (openDist - closedDist)
        openTo(openPercent: perc > 1 ? 1.0 : perc)
    }

    // MARK: - Debug

    func openTo(openPercent: CGFloat) {
        lastInterpolatedPath = UIBezierPath()

        lastInterpolatedIndexFinger = CGPoint(x: openPercent * openIndexFingerTipPath.bounds.midX + (1 - openPercent) * closedIndexFingerTipPath.bounds.midX,
                                              y: openPercent * openIndexFingerTipPath.bounds.midY + (1 - openPercent) * closedIndexFingerTipPath.bounds.midY)
        let lastInterpolatedThumb = CGPoint(x: openPercent * openThumbTipPath.bounds.midX + (1 - openPercent) * closedThumbTipPath.bounds.midX,
                                            y: openPercent * openThumbTipPath.bounds.midY + (1 - openPercent) * closedThumbTipPath.bounds.midY)

        for i in 0 ..< openPath.elementCount {
            let openElement = openPath.element(at: i)
            let closedElement = closedPath.element(at: i)

            switch openElement.type {
            case .moveToPoint:
                lastInterpolatedPath.move(to: openElement.points[0].average(with: closedElement.points[0], weight: openPercent))
            case .addLineToPoint:
                lastInterpolatedPath.addLine(to: openElement.points[0].average(with: closedElement.points[0], weight: openPercent))
            case .addQuadCurveToPoint:
                let endPt = openElement.points[1].average(with: closedElement.points[1], weight: openPercent)
                let ctrlPt = openElement.points[0].average(with: closedElement.points[0], weight: openPercent)

                lastInterpolatedPath.addQuadCurve(to: endPt, controlPoint: ctrlPt)
            case .addCurveToPoint:
                let endPt = openElement.points[2].average(with: closedElement.points[2], weight: openPercent)
                let ctrlPt1 = openElement.points[0].average(with: closedElement.points[0], weight: openPercent)
                let ctrlPt2 = openElement.points[1].average(with: closedElement.points[1], weight: openPercent)

                lastInterpolatedPath.addCurve(to: endPt, controlPoint1: ctrlPt1, controlPoint2: ctrlPt2)
            case .closeSubpath:
                lastInterpolatedPath.close()
            @unknown default:
                break
            }
        }

        var openAngle = CGVector(start: openIndexFingerTipPath.center(), end: openThumbTipPath.center())
        var closedAngle = CGVector(start: closedIndexFingerTipPath.center(), end: closedThumbTipPath.center())

        var interpolatedAngle = CGVector(start: lastInterpolatedIndexFinger, end: lastInterpolatedThumb)

        if handType.isLeft {
            openAngle.flip()
            closedAngle.flip()
            interpolatedAngle.flip()
        }

        var theta = -interpolatedAngle.theta
//        let openTheta = -openAngle.theta
//        let closedTheta = -closedAngle.theta

        if theta.isNaN {
            theta = 0
        }

        let offset = lastInterpolatedIndexFinger
        lastInterpolatedPath.apply(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
    }

    struct PathHelper {
        let openThumbTipPath: UIBezierPath
        let openIndexFingerTipPath: UIBezierPath
        let closedThumbTipPath: UIBezierPath
        let closedIndexFingerTipPath: UIBezierPath
        let openPath: UIBezierPath
        let closedPath: UIBezierPath
    }

    static func initPaths(for frame: CGRect) -> PathHelper {
        let openThumbTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.75728 + 0.34) + 0.16, y: frame.minY + floor((frame.height - 7) * 0.34627 - 0.04) + 0.54, width: 7, height: 7))
        let openIndexFingerTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.48103 - 0.34) + 0.84, y: frame.minY + floor((frame.height - 7) * 0.08532 + 0.5), width: 7, height: 7))
        let closedThumbTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.35135 - 0.31) + 0.81, y: frame.minY + floor((frame.height - 7) * 0.16544 - 0.03) + 0.53, width: 7, height: 7))
        let closedIndexFingerTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.23916 + 0.34) + 0.16, y: frame.minY + floor((frame.height - 7) * 0.13026 - 0.33) + 0.83, width: 7, height: 7))

        let openPath = UIBezierPath()
        openPath.move(to: CGPoint(x: frame.minX + 0.42901 * frame.width, y: frame.minY + 0.88607 * frame.height))
        openPath.addLine(to: CGPoint(x: frame.minX + 0.13953 * frame.width, y: frame.minY + 0.88447 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.20570 * frame.width, y: frame.minY + 0.68103 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.13953 * frame.width, y: frame.minY + 0.88447 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.18895 * frame.width, y: frame.minY + 0.71452 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.26790 * frame.width, y: frame.minY + 0.52486 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.22244 * frame.width, y: frame.minY + 0.64753 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.26312 * frame.width, y: frame.minY + 0.54400 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.27029 * frame.width, y: frame.minY + 0.48498 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.26790 * frame.width, y: frame.minY + 0.52486 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27986 * frame.width, y: frame.minY + 0.49615 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.25447 * frame.width, y: frame.minY + 0.45571 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.27029 * frame.width, y: frame.minY + 0.48498 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.25771 * frame.width, y: frame.minY + 0.46146 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.23397 * frame.width, y: frame.minY + 0.40535 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.25124 * frame.width, y: frame.minY + 0.44995 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.23397 * frame.width, y: frame.minY + 0.42549 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.23937 * frame.width, y: frame.minY + 0.34492 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.23397 * frame.width, y: frame.minY + 0.40535 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.24152 * frame.width, y: frame.minY + 0.35140 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.24045 * frame.width, y: frame.minY + 0.32910 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.23721 * frame.width, y: frame.minY + 0.33845 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.23721 * frame.width, y: frame.minY + 0.33485 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.24584 * frame.width, y: frame.minY + 0.30608 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.24369 * frame.width, y: frame.minY + 0.32334 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.24692 * frame.width, y: frame.minY + 0.31687 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.27605 * frame.width, y: frame.minY + 0.27371 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.24476 * frame.width, y: frame.minY + 0.29528 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.24800 * frame.width, y: frame.minY + 0.27442 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.30087 * frame.width, y: frame.minY + 0.28018 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.27605 * frame.width, y: frame.minY + 0.27371 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.29224 * frame.width, y: frame.minY + 0.27226 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.33433 * frame.width, y: frame.minY + 0.26363 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.30087 * frame.width, y: frame.minY + 0.28018 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.31274 * frame.width, y: frame.minY + 0.26148 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.36141 * frame.width, y: frame.minY + 0.27015 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.35591 * frame.width, y: frame.minY + 0.26579 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.35655 * frame.width, y: frame.minY + 0.26635 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.39352 * frame.width, y: frame.minY + 0.23736 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.36242 * frame.width, y: frame.minY + 0.26457 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.36007 * frame.width, y: frame.minY + 0.24024 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.43360 * frame.width, y: frame.minY + 0.25212 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.42697 * frame.width, y: frame.minY + 0.23449 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.43000 * frame.width, y: frame.minY + 0.24924 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.44762 * frame.width, y: frame.minY + 0.26076 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.43720 * frame.width, y: frame.minY + 0.25501 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.43900 * frame.width, y: frame.minY + 0.25860 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.46166 * frame.width, y: frame.minY + 0.24708 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.45626 * frame.width, y: frame.minY + 0.26291 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.45950 * frame.width, y: frame.minY + 0.25212 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.46381 * frame.width, y: frame.minY + 0.19457 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.46166 * frame.width, y: frame.minY + 0.24708 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.46597 * frame.width, y: frame.minY + 0.21040 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.46705 * frame.width, y: frame.minY + 0.10825 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.46166 * frame.width, y: frame.minY + 0.17875 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.46597 * frame.width, y: frame.minY + 0.11760 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.48970 * frame.width, y: frame.minY + 0.08235 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.46813 * frame.width, y: frame.minY + 0.09890 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.46381 * frame.width, y: frame.minY + 0.08235 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.51884 * frame.width, y: frame.minY + 0.11544 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.51560 * frame.width, y: frame.minY + 0.08235 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.51787 * frame.width, y: frame.minY + 0.10730 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.52855 * frame.width, y: frame.minY + 0.17875 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.51980 * frame.width, y: frame.minY + 0.12358 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.52639 * frame.width, y: frame.minY + 0.17227 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.52746 * frame.width, y: frame.minY + 0.21112 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.53070 * frame.width, y: frame.minY + 0.18522 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.52746 * frame.width, y: frame.minY + 0.20752 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.52962 * frame.width, y: frame.minY + 0.26867 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.52746 * frame.width, y: frame.minY + 0.21471 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.52530 * frame.width, y: frame.minY + 0.26148 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.53286 * frame.width, y: frame.minY + 0.29888 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.53395 * frame.width, y: frame.minY + 0.27586 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.53179 * frame.width, y: frame.minY + 0.29385 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.55767 * frame.width, y: frame.minY + 0.35356 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.53395 * frame.width, y: frame.minY + 0.30392 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.53502 * frame.width, y: frame.minY + 0.34852 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.59868 * frame.width, y: frame.minY + 0.35068 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.58034 * frame.width, y: frame.minY + 0.35859 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.58789 * frame.width, y: frame.minY + 0.35283 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.69512 * frame.width, y: frame.minY + 0.33713 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.60947 * frame.width, y: frame.minY + 0.34852 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.66059 * frame.width, y: frame.minY + 0.33713 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.76957 * frame.width, y: frame.minY + 0.35080 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.69512 * frame.width, y: frame.minY + 0.33713 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75339 * frame.width, y: frame.minY + 0.32850 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.76310 * frame.width, y: frame.minY + 0.36159 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.76957 * frame.width, y: frame.minY + 0.35080 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.77497 * frame.width, y: frame.minY + 0.35655 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.71994 * frame.width, y: frame.minY + 0.36878 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.76310 * frame.width, y: frame.minY + 0.36159 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.73000 * frame.width, y: frame.minY + 0.36511 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.69512 * frame.width, y: frame.minY + 0.37552 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.70722 * frame.width, y: frame.minY + 0.37236 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.70052 * frame.width, y: frame.minY + 0.37336 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.65372 * frame.width, y: frame.minY + 0.38994 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.68972 * frame.width, y: frame.minY + 0.37768 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.66235 * frame.width, y: frame.minY + 0.38707 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.60947 * frame.width, y: frame.minY + 0.40463 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.64508 * frame.width, y: frame.minY + 0.39282 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.61487 * frame.width, y: frame.minY + 0.40103 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.56955 * frame.width, y: frame.minY + 0.42621 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.60407 * frame.width, y: frame.minY + 0.40823 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.59329 * frame.width, y: frame.minY + 0.41758 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.47892 * frame.width, y: frame.minY + 0.47585 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.54581 * frame.width, y: frame.minY + 0.43484 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.49618 * frame.width, y: frame.minY + 0.46793 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.46166 * frame.width, y: frame.minY + 0.50318 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.47892 * frame.width, y: frame.minY + 0.47585 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.46273 * frame.width, y: frame.minY + 0.49671 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.44223 * frame.width, y: frame.minY + 0.58448 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.46058 * frame.width, y: frame.minY + 0.50966 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.44331 * frame.width, y: frame.minY + 0.57512 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.42929 * frame.width, y: frame.minY + 0.69166 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.44115 * frame.width, y: frame.minY + 0.59383 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.42929 * frame.width, y: frame.minY + 0.68375 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.42929 * frame.width, y: frame.minY + 0.76648 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.42929 * frame.width, y: frame.minY + 0.69958 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.42820 * frame.width, y: frame.minY + 0.75784 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.42901 * frame.width, y: frame.minY + 0.88607 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.43036 * frame.width, y: frame.minY + 0.77511 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.42122 * frame.width, y: frame.minY + 0.87475 * frame.height))
        openPath.close()

        let closedPath = UIBezierPath()
        closedPath.move(to: CGPoint(x: frame.minX + 0.55150 * frame.width, y: frame.minY + 0.82672 * frame.height))
        closedPath.addLine(to: CGPoint(x: frame.minX + 0.29752 * frame.width, y: frame.minY + 0.81777 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.31712 * frame.width, y: frame.minY + 0.70922 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.29752 * frame.width, y: frame.minY + 0.77 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.31955 * frame.width, y: frame.minY + 0.71981 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.32374 * frame.width, y: frame.minY + 0.62572 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.31469 * frame.width, y: frame.minY + 0.69864 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.32339 * frame.width, y: frame.minY + 0.62922 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.33614 * frame.width, y: frame.minY + 0.53668 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.32409 * frame.width, y: frame.minY + 0.62227 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.33741 * frame.width, y: frame.minY + 0.54139 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.32444 * frame.width, y: frame.minY + 0.49660 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.33486 * frame.width, y: frame.minY + 0.53197 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.32212 * frame.width, y: frame.minY + 0.50231 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.32827 * frame.width, y: frame.minY + 0.47581 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.32676 * frame.width, y: frame.minY + 0.49085 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.32827 * frame.width, y: frame.minY + 0.47581 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.30499 * frame.width, y: frame.minY + 0.44685 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.32827 * frame.width, y: frame.minY + 0.47581 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.31332 * frame.width, y: frame.minY + 0.45068 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.28600 * frame.width, y: frame.minY + 0.43140 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.29665 * frame.width, y: frame.minY + 0.44297 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.29087 * frame.width, y: frame.minY + 0.43511 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.25344 * frame.width, y: frame.minY + 0.41375 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.28449 * frame.width, y: frame.minY + 0.43025 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.25795 * frame.width, y: frame.minY + 0.41686 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.23631 * frame.width, y: frame.minY + 0.39925 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.25067 * frame.width, y: frame.minY + 0.41184 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.23932 * frame.width, y: frame.minY + 0.40160 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.21718 * frame.width, y: frame.minY + 0.38537 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.23399 * frame.width, y: frame.minY + 0.39744 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.22277 * frame.width, y: frame.minY + 0.38953 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.18951 * frame.width, y: frame.minY + 0.36747 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.21136 * frame.width, y: frame.minY + 0.38104 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.19113 * frame.width, y: frame.minY + 0.36956 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.15518 * frame.width, y: frame.minY + 0.33893 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.18742 * frame.width, y: frame.minY + 0.36476 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.15684 * frame.width, y: frame.minY + 0.34559 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.17152 * frame.width, y: frame.minY + 0.31522 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.15210 * frame.width, y: frame.minY + 0.32656 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.17152 * frame.width, y: frame.minY + 0.31522 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.17174 * frame.width, y: frame.minY + 0.30361 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.17152 * frame.width, y: frame.minY + 0.31522 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.17159 * frame.width, y: frame.minY + 0.31052 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.17201 * frame.width, y: frame.minY + 0.29252 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.17181 * frame.width, y: frame.minY + 0.30032 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.17190 * frame.width, y: frame.minY + 0.29654 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.18465 * frame.width, y: frame.minY + 0.24902 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.17249 * frame.width, y: frame.minY + 0.27443 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.18335 * frame.width, y: frame.minY + 0.25171 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.19919 * frame.width, y: frame.minY + 0.20385 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.18686 * frame.width, y: frame.minY + 0.24447 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.19848 * frame.width, y: frame.minY + 0.21081 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.22810 * frame.width, y: frame.minY + 0.14952 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.19988 * frame.width, y: frame.minY + 0.19689 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.22776 * frame.width, y: frame.minY + 0.15302 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.25435 * frame.width, y: frame.minY + 0.12610 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.22845 * frame.width, y: frame.minY + 0.14606 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.23378 * frame.width, y: frame.minY + 0.12073 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.26353 * frame.width, y: frame.minY + 0.16668 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.27492 * frame.width, y: frame.minY + 0.13147 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.26529 * frame.width, y: frame.minY + 0.14408 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.26190 * frame.width, y: frame.minY + 0.18289 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.26353 * frame.width, y: frame.minY + 0.16668 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.26085 * frame.width, y: frame.minY + 0.17589 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.24931 * frame.width, y: frame.minY + 0.23093 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.26294 * frame.width, y: frame.minY + 0.18993 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.24827 * frame.width, y: frame.minY + 0.22393 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.24105 * frame.width, y: frame.minY + 0.26593 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.25035 * frame.width, y: frame.minY + 0.23797 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.24105 * frame.width, y: frame.minY + 0.26593 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.27998 * frame.width, y: frame.minY + 0.24322 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.24105 * frame.width, y: frame.minY + 0.26593 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27129 * frame.width, y: frame.minY + 0.24285 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.31670 * frame.width, y: frame.minY + 0.25997 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.28867 * frame.width, y: frame.minY + 0.24360 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.31184 * frame.width, y: frame.minY + 0.25627 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.33292 * frame.width, y: frame.minY + 0.27235 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.32157 * frame.width, y: frame.minY + 0.26368 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.33292 * frame.width, y: frame.minY + 0.27235 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.32482 * frame.width, y: frame.minY + 0.21343 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.33292 * frame.width, y: frame.minY + 0.27235 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.32276 * frame.width, y: frame.minY + 0.22407 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.35957 * frame.width, y: frame.minY + 0.16222 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.32688 * frame.width, y: frame.minY + 0.20276 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.31775 * frame.width, y: frame.minY + 0.16152 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.37405 * frame.width, y: frame.minY + 0.17447 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.35957 * frame.width, y: frame.minY + 0.16222 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.37522 * frame.width, y: frame.minY + 0.16289 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.38546 * frame.width, y: frame.minY + 0.21039 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.37290 * frame.width, y: frame.minY + 0.18606 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.38453 * frame.width, y: frame.minY + 0.20222 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.39104 * frame.width, y: frame.minY + 0.23952 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.38639 * frame.width, y: frame.minY + 0.21860 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.39049 * frame.width, y: frame.minY + 0.23274 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.39575 * frame.width, y: frame.minY + 0.26735 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.39158 * frame.width, y: frame.minY + 0.24629 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.39209 * frame.width, y: frame.minY + 0.25742 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.40525 * frame.width, y: frame.minY + 0.31197 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.39942 * frame.width, y: frame.minY + 0.27728 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.40257 * frame.width, y: frame.minY + 0.30372 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.43129 * frame.width, y: frame.minY + 0.35356 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.40790 * frame.width, y: frame.minY + 0.32022 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.42387 * frame.width, y: frame.minY + 0.34039 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.44414 * frame.width, y: frame.minY + 0.39947 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.43870 * frame.width, y: frame.minY + 0.36668 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.44345 * frame.width, y: frame.minY + 0.38897 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.45352 * frame.width, y: frame.minY + 0.42785 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.44484 * frame.width, y: frame.minY + 0.41002 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.44946 * frame.width, y: frame.minY + 0.41602 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.45351 * frame.width, y: frame.minY + 0.48022 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.45757 * frame.width, y: frame.minY + 0.43968 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.44969 * frame.width, y: frame.minY + 0.46606 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.47379 * frame.width, y: frame.minY + 0.55677 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.45734 * frame.width, y: frame.minY + 0.49435 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.46647 * frame.width, y: frame.minY + 0.54247 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.51502 * frame.width, y: frame.minY + 0.68543 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.48108 * frame.width, y: frame.minY + 0.57106 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.50934 * frame.width, y: frame.minY + 0.67239 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.55150 * frame.width, y: frame.minY + 0.82672 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.52069 * frame.width, y: frame.minY + 0.69852 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.54895 * frame.width, y: frame.minY + 0.79985 * frame.height))
        closedPath.close()

        return PathHelper(openThumbTipPath: openThumbTipPath, openIndexFingerTipPath: openIndexFingerTipPath, closedThumbTipPath: closedThumbTipPath, closedIndexFingerTipPath: closedIndexFingerTipPath, openPath: openPath, closedPath: closedPath)
    }

    // MARK: - CALayer Helper

    func flipPathAroundYAxis(path: UIBezierPath) {
        path.apply(CGAffineTransform(translationX: -boundingBox.size.width / 2 - boundingBox.origin.x, y: 0))
        path.apply(CGAffineTransform(scaleX: -1, y: 1))
        path.apply(CGAffineTransform(translationX: boundingBox.size.width / 2 + boundingBox.origin.x, y: 0))
    }
}
