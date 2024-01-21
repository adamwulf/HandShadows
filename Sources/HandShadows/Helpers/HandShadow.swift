import SwiftToolbox
import UIKit

class HandShadow: NSObject {
    private(set) var isPinching: Bool = false
    private(set) var isPanning: Bool = false
    private(set) var isPointing: Bool = false

    private let pointerFingerHelper: IndexFingerShadow
    private let twoFingerHelper: IndexMiddleFingerShadow
    private let thumbAndIndexHelper: ThumbAndIndexShadow
    private var recentTheta: CGFloat = 0.0

    private let _layer: CAShapeLayer
    var layer: CALayer { _layer }
    let handType: HandType

    init(for hand: HandType) {
        handType = hand

        _layer = CAShapeLayer()
        _layer.opacity = 0.5
        _layer.anchorPoint = CGPoint.zero
        _layer.position = CGPoint.zero
        _layer.backgroundColor = UIColor.black.cgColor

        pointerFingerHelper = IndexFingerShadow(for: handType)
        twoFingerHelper = IndexMiddleFingerShadow(for: handType)
        thumbAndIndexHelper = ThumbAndIndexShadow(for: handType)
        super.init()
    }

    var isActive: Bool {
        return isPanning || isPointing || isPinching
    }

    // MARK: - Panning a Page

    func startTwoFingerPan(withTouches touches: [CGPoint]) {
        isPanning = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continueTwoFingerPan(withTouches: touches)
    }

    func continueTwoFingerPan(withTouches touches: [CGPoint]) {
        if !isPanning {
            startTwoFingerPan(withTouches: touches)
        }
        if touches.count >= 2,
           let firstTouch = touches.first,
           let lastTouch = touches.last
        {
            var indexFingerTouch = firstTouch
            if handType.isLeft, lastTouch.x > indexFingerTouch.x {
                indexFingerTouch = (touches.last as? NSValue)?.cgPointValue ?? CGPoint.zero
            } else if handType.isRight, lastTouch.x < indexFingerTouch.x {
                indexFingerTouch = (touches.last as? NSValue)?.cgPointValue ?? CGPoint.zero
            }
            let middleFingerTouch = CGPointEqualToPoint(firstTouch, indexFingerTouch) ? lastTouch : firstTouch

            continuePanningWithIndexFinger(indexFingerTouch, andMiddleFinger: middleFingerTouch)
        }
    }

    func endTwoFingerPan() {
        if isPanning {
            isPanning = false
            layer.opacity = 0
        }
    }

    // MARK: - Pinching a Page

    // Pinching a Page

    func startPinch(withTouches touches: [CGPoint]) {
        isPinching = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePinch(withTouches: touches)
    }

    func continuePinch(withTouches touches: [CGPoint]) {
        guard isPinching else {
            return
        }
        if touches.count >= 2 {
            var indexFingerLocation = (touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero
            if let lastTouch = (touches.last as? NSValue)?.cgPointValue, lastTouch.y < indexFingerLocation.y {
                indexFingerLocation = lastTouch
            }
            let middleFingerLocation = CGPointEqualToPoint((touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero, indexFingerLocation) ? (touches.last as? NSValue)?.cgPointValue ?? CGPoint.zero : (touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero

            let distance = HandShadow.distanceBetweenPoint(indexFingerLocation, andPoint: middleFingerLocation)

            thumbAndIndexHelper.setFingerDistance(idealDistance: distance)
            CATransaction.preventImplicitAnimation {
                _layer.path = thumbAndIndexHelper.pathForTouches().cgPath

                var currVector = CGVector(start: indexFingerLocation, end: middleFingerLocation)
                if handType.isLeft {
                    currVector.flip()
                }
                let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
                let offset = thumbAndIndexHelper.locationOfIndexFingerInPathBounds()
                let finalLocation = CGPoint(x: indexFingerLocation.x - offset.x, y: indexFingerLocation.y - offset.y)
                _layer.position = finalLocation
                _layer.setAffineTransform(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
            }
        }
    }

    func endPinch() {
        if isPinching {
            isPinching = false
            layer.opacity = 0
        }
    }

    // MARK: - Drawing Events

    func startPointing(at point: CGPoint) {
        isPointing = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePointing(at: point)
    }

    func continuePointing(at point: CGPoint) {
        if !isPointing {
            startPointing(at: point)
        }
        CATransaction.preventImplicitAnimation {
            _layer.path = pointerFingerHelper.path.cgPath
            let offset = pointerFingerHelper.locationOfIndexFingerInPathBounds
            let finalLocation = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
            _layer.position = finalLocation
            _layer.setAffineTransform(.identity)
        }
    }

    func endPointing() {
        if isPointing {
            isPointing = false
            if !isPanning {
                layer.opacity = 0
            }
        }
    }

    // MARK: - Private

    private func continuePanningWithIndexFinger(_ indexFingerLocation: CGPoint, andMiddleFinger middleFingerLocation: CGPoint) {
        let distance = HandShadow.distanceBetweenPoint(indexFingerLocation, andPoint: middleFingerLocation)
        twoFingerHelper.setFingerDistance(idealDistance: distance)
        CATransaction.preventImplicitAnimation {
            _layer.path = twoFingerHelper.pathForTouches().cgPath

            var currVector = CGVector(start: indexFingerLocation, end: middleFingerLocation)
            if handType.isLeft {
                currVector.flip()
            }

            let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
            let offset = twoFingerHelper.locationOfIndexFingerInPathBounds
            let finalLocation = CGPoint(x: indexFingerLocation.x - offset.x, y: indexFingerLocation.y - offset.y)

            if recentTheta == CGFloat.greatestFiniteMagnitude {
                if handType.isLeft, theta < 0, theta > -CGFloat.pi {
                    continuePanningWithIndexFinger(middleFingerLocation, andMiddleFinger: indexFingerLocation)
                    return
                }
                recentTheta = theta
            } else if abs(recentTheta - theta) > CGFloat.pi / 2, abs(recentTheta - theta) < CGFloat.pi * 3 / 2 {
                continuePanningWithIndexFinger(middleFingerLocation, andMiddleFinger: indexFingerLocation)
                return
            } else {
                recentTheta = theta
            }

            _layer.position = finalLocation
            _layer.setAffineTransform(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
        }
    }

    static func distanceBetweenPoint(_ p1: CGPoint, andPoint p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
}
