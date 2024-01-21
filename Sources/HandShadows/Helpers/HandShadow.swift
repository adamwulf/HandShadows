import SwiftToolbox
import UIKit

class HandShadow: NSObject {
    let handType: HandType

    var pointerFingerHelper: IndexFingerShadow
    var twoFingerHelper: IndexMiddleFingerShadow
    var thumbAndIndexHelper: ThumbAndIndexShadow

    var isPinching: Bool = false
    var isPanning: Bool = false
    private(set) var isDrawing: Bool = false
    var recentTheta: CGFloat = 0.0

    private var _layer: CAShapeLayer
    var layer: CALayer { _layer }

    var heldObject: Any?

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
        return isPanning || isDrawing || isPinching
    }

    // MARK: - Panning a Page

    func startPanningObject(_ obj: Any?, withTouches touches: [CGPoint]) {
        heldObject = obj
        isPanning = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePanningObject(obj, withTouches: touches)
    }

    func continuePanningObject(_ obj: Any?, withTouches touches: [CGPoint]) {
        if !isPanning {
            startPanningObject(obj, withTouches: touches)
        }
        if obj as AnyObject? !== heldObject as AnyObject? {
            fatalError("ShadowException: Asked to pan different object than what's held.")
        }
        if touches.count >= 2 {
            var indexFingerTouch = (touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero
            if handType == .leftHand && (touches.last as? NSValue)?.cgPointValue.x ?? 0 > indexFingerTouch.x {
                indexFingerTouch = (touches.last as? NSValue)?.cgPointValue ?? CGPoint.zero
            } else if handType == .rightHand && (touches.last as? NSValue)?.cgPointValue.x ?? 0 < indexFingerTouch.x {
                indexFingerTouch = (touches.last as? NSValue)?.cgPointValue ?? CGPoint.zero
            }
            let middleFingerTouch = CGPointEqualToPoint((touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero, indexFingerTouch) ? (touches.last as? NSValue)?.cgPointValue ?? CGPoint.zero : (touches.first as? NSValue)?.cgPointValue ?? CGPoint.zero

            continuePanningWithIndexFinger(indexFingerTouch, andMiddleFinger: middleFingerTouch)
        }
    }

    func endPanningObject(_ obj: Any?) {
        if obj as AnyObject? !== heldObject as AnyObject? {
            fatalError("ShadowException: Asked to stop holding different object than what's held.")
        }
        if isPanning {
            isPanning = false
            heldObject = nil
            layer.opacity = 0
        }
    }

    // MARK: - Pinching a Page

    // Pinching a Page

    func startPinchingObject(_ obj: Any?, withTouches touches: [CGPoint]) {
        heldObject = obj
        isPinching = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePinchingObject(obj, withTouches: touches)
    }

    func continuePinchingObject(_ obj: Any?, withTouches touches: [CGPoint]) {
        guard isPinching else {
            return
        }
        guard obj as? NSObject == heldObject as? NSObject else {
            fatalError("ShadowException: Asked to pinch different object than what's held.")
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
                if handType == .leftHand {
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

    func endPinchingObject(_ obj: Any?) {
        guard obj as? NSObject == heldObject as? NSObject else {
            fatalError("ShadowException: Asked to stop holding different object than what's held.")
        }
        if isPinching {
            isPinching = false
            heldObject = nil
            layer.opacity = 0
        }
    }

    // MARK: - Drawing Events

    func startDrawingAtTouch(_ touch: CGPoint) {
        isDrawing = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continueDrawingAtTouch(touch)
    }

    func continueDrawingAtTouch(_ locationOfTouch: CGPoint) {
        if !isDrawing {
            startDrawingAtTouch(locationOfTouch)
        }
        CATransaction.preventImplicitAnimation {
            _layer.path = pointerFingerHelper.path.cgPath
            let offset = pointerFingerHelper.locationOfIndexFingerInPathBounds
            let finalLocation = CGPoint(x: locationOfTouch.x - offset.x, y: locationOfTouch.y - offset.y)
            _layer.position = finalLocation
            _layer.setAffineTransform(.identity)
        }
    }

    func endDrawing() {
        if isDrawing {
            isDrawing = false
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
            if handType == .leftHand {
                currVector.flip()
            }

            let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
            let offset = twoFingerHelper.locationOfIndexFingerInPathBounds
            let finalLocation = CGPoint(x: indexFingerLocation.x - offset.x, y: indexFingerLocation.y - offset.y)

            if recentTheta == CGFloat.greatestFiniteMagnitude {
                if handType == .leftHand && theta < 0 && theta > -CGFloat.pi {
                    continuePanningWithIndexFinger(middleFingerLocation, andMiddleFinger: indexFingerLocation)
                    return
                }
                recentTheta = theta
            } else if abs(recentTheta - theta) > CGFloat.pi / 2 && abs(recentTheta - theta) < CGFloat.pi * 3 / 2 {
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
