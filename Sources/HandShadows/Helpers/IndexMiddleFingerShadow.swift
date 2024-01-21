//
//  IndexMiddleFingerShadow.swift
//
//
//  Created by Adam Wulf on 1/19/24.
//

import UIKit

class IndexMiddleFingerShadow: NSObject {
    let handType: HandType

    private let openPath: UIBezierPath
    private let closedPath: UIBezierPath

    private let openMiddleFingerTip: CGPoint
    private let openIndexFingerTip: CGPoint
    private let closedMiddleFingerTip: CGPoint
    private let closedIndexFingerTip: CGPoint

    override init() {
        fatalError("This initializer is not available.")
    }

    init(for hand: HandType) {
        handType = hand
        let boundingBox = CGRect(x: 0, y: 0, width: 400, height: 1200)

        let paths = Self.initPaths(for: boundingBox)

        if hand.isRight {
            boundingBox.flipPathAroundMidY(paths.openPath)
            boundingBox.flipPathAroundMidY(paths.closedPath)
            boundingBox.flipPathAroundMidY(paths.openMiddleFingerTipPath)
            boundingBox.flipPathAroundMidY(paths.openIndexFingerTipPath)
            boundingBox.flipPathAroundMidY(paths.closedMiddleFingerTipPath)
            boundingBox.flipPathAroundMidY(paths.closedIndexFingerTipPath)
        }

        openIndexFingerTip = paths.openIndexFingerTipPath.center()
        openMiddleFingerTip = paths.openMiddleFingerTipPath.center()
        closedIndexFingerTip = paths.closedIndexFingerTipPath.center()
        closedMiddleFingerTip = paths.closedMiddleFingerTipPath.center()
        openPath = paths.openPath
        closedPath = paths.closedPath

        super.init()
    }

    func setFingerDistance(idealDistance: CGFloat) -> (indexFingerLocation: CGPoint, middleFingerLocation: CGPoint, path: UIBezierPath) {
        let idealDistance = idealDistance - 80
        let openDist = openMiddleFingerTip.distance(to: openIndexFingerTip)
        let closedDist = closedMiddleFingerTip.distance(to: closedIndexFingerTip)
        let perc = idealDistance / (openDist - closedDist)
        return openTo(openPercent: perc > 1 ? 1.0 : perc)
    }

    // MARK: - Private

    private func openTo(openPercent: CGFloat) -> (indexFingerLocation: CGPoint, middleFingerLocation: CGPoint, path: UIBezierPath) {
        assert(openPercent <= 1, "must be less than 1")
        let lastInterpolatedPath = UIBezierPath()

        let indexFingerLocation = CGPoint(x: openPercent * openIndexFingerTip.x + (1 - openPercent) * closedIndexFingerTip.x,
                                          y: openPercent * openIndexFingerTip.y + (1 - openPercent) * closedIndexFingerTip.y)
        let middleFingerLocation = CGPoint(x: openPercent * openMiddleFingerTip.x + (1 - openPercent) * closedMiddleFingerTip.x,
                                           y: openPercent * openMiddleFingerTip.y + (1 - openPercent) * closedMiddleFingerTip.y)

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

        var initialFingerAngle = CGVector(start: indexFingerLocation, end: middleFingerLocation)
        if handType.isLeft {
            initialFingerAngle.flip()
        }
        let theta = -initialFingerAngle.theta
        let offset = indexFingerLocation
        lastInterpolatedPath.apply(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))

        return (indexFingerLocation: indexFingerLocation, middleFingerLocation: middleFingerLocation, path: lastInterpolatedPath)
    }

    private struct PathHelper {
        let openMiddleFingerTipPath: UIBezierPath
        let openIndexFingerTipPath: UIBezierPath
        let closedMiddleFingerTipPath: UIBezierPath
        let closedIndexFingerTipPath: UIBezierPath
        let openPath: UIBezierPath
        let closedPath: UIBezierPath
    }

    private static func initPaths(for frame: CGRect) -> PathHelper {
        let openMiddleFingerTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.27322 + 0.03) + 0.47, y: frame.minY + floor((frame.height - 7) * 0.04833 - 0.34) + 0.84, width: 7, height: 7))
        let openIndexFingerTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.87880 - 0.43) + 0.93, y: frame.minY + floor((frame.height - 7) * 0.07405 + 0.2) + 0.3, width: 7, height: 7))
        let closedMiddleFingerTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.53012 + 0.08) + 0.42, y: frame.minY + floor((frame.height - 7) * 0.04172 - 0.28) + 0.78, width: 7, height: 7))
        let closedIndexFingerTipPath = UIBezierPath(ovalIn: CGRect(x: frame.minX + floor((frame.width - 7) * 0.71794 - 0.43) + 0.93, y: frame.minY + floor((frame.height - 7) * 0.06205 - 0.32) + 0.82, width: 7, height: 7))

        let openPath = UIBezierPath()
        openPath.move(to: CGPoint(x: frame.minX + 0.61863 * frame.width, y: frame.minY + 0.81132 * frame.height))
        openPath.addLine(to: CGPoint(x: frame.minX + 0.07600 * frame.width, y: frame.minY + 0.81132 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.18222 * frame.width, y: frame.minY + 0.66361 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.07600 * frame.width, y: frame.minY + 0.81132 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.16788 * frame.width, y: frame.minY + 0.67990 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.23677 * frame.width, y: frame.minY + 0.58495 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.19658 * frame.width, y: frame.minY + 0.64732 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.23103 * frame.width, y: frame.minY + 0.59361 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.25113 * frame.width, y: frame.minY + 0.53220 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.24252 * frame.width, y: frame.minY + 0.57632 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.25688 * frame.width, y: frame.minY + 0.53890 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.20806 * frame.width, y: frame.minY + 0.48815 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.24539 * frame.width, y: frame.minY + 0.52549 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.23104 * frame.width, y: frame.minY + 0.49870 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.13342 * frame.width, y: frame.minY + 0.41715 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.18509 * frame.width, y: frame.minY + 0.47757 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.14203 * frame.width, y: frame.minY + 0.44882 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.10758 * frame.width, y: frame.minY + 0.37207 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.12480 * frame.width, y: frame.minY + 0.38549 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.11045 * frame.width, y: frame.minY + 0.37878 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.11333 * frame.width, y: frame.minY + 0.35386 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.10471 * frame.width, y: frame.minY + 0.36536 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.11333 * frame.width, y: frame.minY + 0.36057 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.10184 * frame.width, y: frame.minY + 0.29340 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.11333 * frame.width, y: frame.minY + 0.34715 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.08750 * frame.width, y: frame.minY + 0.30303 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.20806 * frame.width, y: frame.minY + 0.27953 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.11618 * frame.width, y: frame.minY + 0.28382 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.15064 * frame.width, y: frame.minY + 0.26707 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.25113 * frame.width, y: frame.minY + 0.23870 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.20806 * frame.width, y: frame.minY + 0.27953 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.17649 * frame.width, y: frame.minY + 0.24540 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.35449 * frame.width, y: frame.minY + 0.26270 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.32579 * frame.width, y: frame.minY + 0.23199 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.35449 * frame.width, y: frame.minY + 0.26270 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.30431 * frame.width, y: frame.minY + 0.19840 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.35449 * frame.width, y: frame.minY + 0.26270 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.32155 * frame.width, y: frame.minY + 0.21378 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.26849 * frame.width, y: frame.minY + 0.13224 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.28709 * frame.width, y: frame.minY + 0.18307 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27136 * frame.width, y: frame.minY + 0.14470 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.27424 * frame.width, y: frame.minY + 0.03824 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.26563 * frame.width, y: frame.minY + 0.11978 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.19386 * frame.width, y: frame.minY + 0.04303 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.37474 * frame.width, y: frame.minY + 0.09578 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.35464 * frame.width, y: frame.minY + 0.03345 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.37474 * frame.width, y: frame.minY + 0.09578 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.43926 * frame.width, y: frame.minY + 0.17349 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.37474 * frame.width, y: frame.minY + 0.09578 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.43926 * frame.width, y: frame.minY + 0.16774 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.49517 * frame.width, y: frame.minY + 0.24828 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.43926 * frame.width, y: frame.minY + 0.17924 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.47506 * frame.width, y: frame.minY + 0.24732 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.62998 * frame.width, y: frame.minY + 0.21186 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.51527 * frame.width, y: frame.minY + 0.24924 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.59265 * frame.width, y: frame.minY + 0.25211 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.76463 * frame.width, y: frame.minY + 0.10440 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.66730 * frame.width, y: frame.minY + 0.17157 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75314 * frame.width, y: frame.minY + 0.11303 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.86784 * frame.width, y: frame.minY + 0.06607 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.77611 * frame.width, y: frame.minY + 0.09578 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.79894 * frame.width, y: frame.minY + 0.06128 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.87085 * frame.width, y: frame.minY + 0.12840 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.93674 * frame.width, y: frame.minY + 0.07086 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.87372 * frame.width, y: frame.minY + 0.12074 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.81146 * frame.width, y: frame.minY + 0.19074 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.86798 * frame.width, y: frame.minY + 0.13607 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.81766 * frame.width, y: frame.minY + 0.18553 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.75343 * frame.width, y: frame.minY + 0.23678 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.80540 * frame.width, y: frame.minY + 0.19583 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75630 * frame.width, y: frame.minY + 0.22911 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.70476 * frame.width, y: frame.minY + 0.32886 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.75056 * frame.width, y: frame.minY + 0.24445 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.68754 * frame.width, y: frame.minY + 0.30586 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.71338 * frame.width, y: frame.minY + 0.40465 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.72198 * frame.width, y: frame.minY + 0.35190 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.72198 * frame.width, y: frame.minY + 0.39215 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.69327 * frame.width, y: frame.minY + 0.45932 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.70476 * frame.width, y: frame.minY + 0.41711 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.69327 * frame.width, y: frame.minY + 0.45261 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.68754 * frame.width, y: frame.minY + 0.52261 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.69327 * frame.width, y: frame.minY + 0.46603 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.69327 * frame.width, y: frame.minY + 0.51111 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.63012 * frame.width, y: frame.minY + 0.64732 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.68179 * frame.width, y: frame.minY + 0.53411 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.64734 * frame.width, y: frame.minY + 0.62140 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.61863 * frame.width, y: frame.minY + 0.78449 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.61289 * frame.width, y: frame.minY + 0.67320 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.61863 * frame.width, y: frame.minY + 0.77582 * frame.height))
        openPath.addCurve(to: CGPoint(x: frame.minX + 0.61863 * frame.width, y: frame.minY + 0.81132 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.61863 * frame.width, y: frame.minY + 0.79311 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.61863 * frame.width, y: frame.minY + 0.81132 * frame.height))
        openPath.close()

        let closedPath = UIBezierPath()
        closedPath.move(to: CGPoint(x: frame.minX + 0.66734 * frame.width, y: frame.minY + 0.80639 * frame.height))
        closedPath.addLine(to: CGPoint(x: frame.minX + 0.12471 * frame.width, y: frame.minY + 0.80639 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.23093 * frame.width, y: frame.minY + 0.65868 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.12471 * frame.width, y: frame.minY + 0.80639 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.21659 * frame.width, y: frame.minY + 0.67498 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.28548 * frame.width, y: frame.minY + 0.58002 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.24529 * frame.width, y: frame.minY + 0.64239 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27973 * frame.width, y: frame.minY + 0.58868 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.29984 * frame.width, y: frame.minY + 0.52060 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.29123 * frame.width, y: frame.minY + 0.57139 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.30559 * frame.width, y: frame.minY + 0.52731 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.25677 * frame.width, y: frame.minY + 0.48323 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.29410 * frame.width, y: frame.minY + 0.51389 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.27975 * frame.width, y: frame.minY + 0.49377 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.18213 * frame.width, y: frame.minY + 0.41223 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.23380 * frame.width, y: frame.minY + 0.47264 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.19073 * frame.width, y: frame.minY + 0.44389 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.15629 * frame.width, y: frame.minY + 0.36714 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.17351 * frame.width, y: frame.minY + 0.38056 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.15916 * frame.width, y: frame.minY + 0.37385 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.16204 * frame.width, y: frame.minY + 0.34893 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.15342 * frame.width, y: frame.minY + 0.36043 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.16204 * frame.width, y: frame.minY + 0.35564 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.15055 * frame.width, y: frame.minY + 0.28848 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.16204 * frame.width, y: frame.minY + 0.34223 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.13621 * frame.width, y: frame.minY + 0.29810 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.25677 * frame.width, y: frame.minY + 0.27460 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.16489 * frame.width, y: frame.minY + 0.27889 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.19935 * frame.width, y: frame.minY + 0.26214 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.29984 * frame.width, y: frame.minY + 0.23377 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.25677 * frame.width, y: frame.minY + 0.27460 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.22519 * frame.width, y: frame.minY + 0.24048 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.40319 * frame.width, y: frame.minY + 0.25777 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.37450 * frame.width, y: frame.minY + 0.22706 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.40319 * frame.width, y: frame.minY + 0.25777 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.43513 * frame.width, y: frame.minY + 0.19348 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.40319 * frame.width, y: frame.minY + 0.25777 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.43460 * frame.width, y: frame.minY + 0.21097 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.45597 * frame.width, y: frame.minY + 0.12755 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.43368 * frame.width, y: frame.minY + 0.17724 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.45884 * frame.width, y: frame.minY + 0.14001 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.53184 * frame.width, y: frame.minY + 0.03464 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.45311 * frame.width, y: frame.minY + 0.11509 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.44680 * frame.width, y: frame.minY + 0.03580 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.57650 * frame.width, y: frame.minY + 0.09085 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.60583 * frame.width, y: frame.minY + 0.03461 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.57650 * frame.width, y: frame.minY + 0.09085 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.56803 * frame.width, y: frame.minY + 0.16790 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.57650 * frame.width, y: frame.minY + 0.09085 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.56803 * frame.width, y: frame.minY + 0.16215 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.55202 * frame.width, y: frame.minY + 0.24392 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.56803 * frame.width, y: frame.minY + 0.17365 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.53192 * frame.width, y: frame.minY + 0.24296 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.61527 * frame.width, y: frame.minY + 0.20703 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.57213 * frame.width, y: frame.minY + 0.24488 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.57794 * frame.width, y: frame.minY + 0.24728 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.64537 * frame.width, y: frame.minY + 0.09723 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.63124 * frame.width, y: frame.minY + 0.16731 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.64161 * frame.width, y: frame.minY + 0.10726 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.71147 * frame.width, y: frame.minY + 0.05276 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.64913 * frame.width, y: frame.minY + 0.08721 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.63836 * frame.width, y: frame.minY + 0.05435 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.75319 * frame.width, y: frame.minY + 0.10818 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.77438 * frame.width, y: frame.minY + 0.05294 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75605 * frame.width, y: frame.minY + 0.10052 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.75008 * frame.width, y: frame.minY + 0.17559 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.75032 * frame.width, y: frame.minY + 0.11585 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75295 * frame.width, y: frame.minY + 0.17080 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.74075 * frame.width, y: frame.minY + 0.22895 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.74721 * frame.width, y: frame.minY + 0.18038 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.74362 * frame.width, y: frame.minY + 0.22129 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.74349 * frame.width, y: frame.minY + 0.32393 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.73788 * frame.width, y: frame.minY + 0.23662 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.73625 * frame.width, y: frame.minY + 0.30093 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.76209 * frame.width, y: frame.minY + 0.39973 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.76072 * frame.width, y: frame.minY + 0.34698 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.76072 * frame.width, y: frame.minY + 0.38723 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.74198 * frame.width, y: frame.minY + 0.45439 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.75347 * frame.width, y: frame.minY + 0.41218 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.74198 * frame.width, y: frame.minY + 0.44768 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.73625 * frame.width, y: frame.minY + 0.51768 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.74198 * frame.width, y: frame.minY + 0.46110 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.74198 * frame.width, y: frame.minY + 0.50618 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.67883 * frame.width, y: frame.minY + 0.64239 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.73050 * frame.width, y: frame.minY + 0.52918 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.69605 * frame.width, y: frame.minY + 0.61648 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.66734 * frame.width, y: frame.minY + 0.77956 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.66160 * frame.width, y: frame.minY + 0.66827 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.66734 * frame.width, y: frame.minY + 0.77089 * frame.height))
        closedPath.addCurve(to: CGPoint(x: frame.minX + 0.66734 * frame.width, y: frame.minY + 0.80639 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.66734 * frame.width, y: frame.minY + 0.78818 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.66734 * frame.width, y: frame.minY + 0.80639 * frame.height))
        closedPath.close()

        return PathHelper(openMiddleFingerTipPath: openMiddleFingerTipPath, openIndexFingerTipPath: openIndexFingerTipPath, closedMiddleFingerTipPath: closedMiddleFingerTipPath, closedIndexFingerTipPath: closedIndexFingerTipPath, openPath: openPath, closedPath: closedPath)
    }
}
