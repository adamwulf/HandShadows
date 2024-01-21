import SwiftToolbox
import UIKit

class HandShadow: NSObject {
    private(set) var isPinching: Bool = false
    private(set) var isPanning: Bool = false
    private(set) var isPointing: Bool = false

    private let pointerFingerHelper: IndexFingerShadow
    private let twoFingerPanHelper: IndexMiddleFingerShadow
    private let pinchHelper: ThumbAndIndexShadow
    private var recentTheta: CGFloat = 0.0

    private let shapeLayer: CAShapeLayer
    var layer: CALayer { shapeLayer }
    let handType: HandType

    init(for hand: HandType) {
        handType = hand

        shapeLayer = CAShapeLayer()
        shapeLayer.opacity = 0.5
        shapeLayer.anchorPoint = CGPoint.zero
        shapeLayer.position = CGPoint.zero
        shapeLayer.backgroundColor = UIColor.black.cgColor

        pointerFingerHelper = IndexFingerShadow(for: handType)
        twoFingerPanHelper = IndexMiddleFingerShadow(for: handType)
        pinchHelper = ThumbAndIndexShadow(for: handType)
        super.init()
    }

    var isActive: Bool {
        return isPanning || isPointing || isPinching
    }

    // MARK: - Panning a Page

    func startTwoFingerPan(withTouches touches: [CGPoint]) {
        assert(!isActive, "shadow must be inactive")
        isPanning = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continueTwoFingerPan(withTouches: touches)
    }

    func continueTwoFingerPan(withTouches touches: [CGPoint]) {
        assert(isPanning, "shadow must be panning")
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
        assert(isPanning, "shadow must be panning")
        isPanning = false
        layer.opacity = 0
    }

    // MARK: - Pinching a Page

    // Pinching a Page

    func startPinch(withTouches touches: [CGPoint]) {
        assert(!isActive, "shadow must be inactive")
        isPinching = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePinch(withTouches: touches)
    }

    func continuePinch(withTouches touches: [CGPoint]) {
        assert(isPinching, "shadow must be pinching")
        if touches.count >= 2 {
            var indexFingerLocation = (touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero
            if let lastTouch = (touches.last as? NSValue)?.cgPointValue, lastTouch.y < indexFingerLocation.y {
                indexFingerLocation = lastTouch
            }
            let middleFingerLocation = CGPointEqualToPoint((touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero, indexFingerLocation) ? (touches.last as? NSValue)?.cgPointValue ?? CGPoint.zero : (touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero

            let distance = indexFingerLocation.distance(to: middleFingerLocation)

            pinchHelper.setFingerDistance(idealDistance: distance)
            CATransaction.preventImplicitAnimation {
                shapeLayer.path = pinchHelper.pathForTouches().cgPath

                var currVector = CGVector(start: indexFingerLocation, end: middleFingerLocation)
                if handType.isLeft {
                    currVector.flip()
                }
                let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
                let offset = pinchHelper.locationOfIndexFingerInPathBounds()
                let finalLocation = CGPoint(x: indexFingerLocation.x - offset.x, y: indexFingerLocation.y - offset.y)
                shapeLayer.position = finalLocation
                shapeLayer.setAffineTransform(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
            }
        }
    }

    func endPinch() {
        assert(isPinching, "shadow must be pinching")
        isPinching = false
        layer.opacity = 0
    }

    // MARK: - Drawing Events

    func startPointing(at point: CGPoint) {
        assert(!isActive, "shadow must be inactive")
        isPointing = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePointing(at: point)
    }

    func continuePointing(at point: CGPoint) {
        assert(isPointing, "shadow must be pointing")
        CATransaction.preventImplicitAnimation {
            shapeLayer.path = pointerFingerHelper.path.cgPath
            let offset = pointerFingerHelper.locationOfIndexFingerInPathBounds
            let finalLocation = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
            shapeLayer.position = finalLocation
            shapeLayer.setAffineTransform(.identity)
        }
    }

    func endPointing() {
        assert(isPointing, "shadow must be pointing")
        isPointing = false
        layer.opacity = 0
    }

    // MARK: - Private

    private func continuePanningWithIndexFinger(_ indexFingerLocation: CGPoint, andMiddleFinger middleFingerLocation: CGPoint) {
        let distance = indexFingerLocation.distance(to: middleFingerLocation)
        twoFingerPanHelper.setFingerDistance(idealDistance: distance)
        CATransaction.preventImplicitAnimation {
            shapeLayer.path = twoFingerPanHelper.pathForTouches().cgPath

            var currVector = CGVector(start: indexFingerLocation, end: middleFingerLocation)
            if handType.isLeft {
                currVector.flip()
            }

            let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
            let offset = twoFingerPanHelper.locationOfIndexFingerInPathBounds
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

            shapeLayer.position = finalLocation
            shapeLayer.setAffineTransform(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
        }
    }
}
