import UIKit
import SwiftToolbox

public class HandShadow: NSObject {
    var relativeView: UIView

    var isRight: Bool = false
    var initialVector: CGVector?

    var pointerFingerHelper: MMDrawingGestureShadow
    var twoFingerHelper: MMTwoFingerPanShadow
    var thumbAndIndexHelper: MMThumbAndIndexShadow

    var activeTouches: Set<UITouch>?
    var isBezeling: Bool = false
    var isPinching: Bool = false
    var isPanning: Bool = false
    public private(set) var isDrawing: Bool = false
    var recentTheta: CGFloat = 0.0

    private var _layer: CAShapeLayer
    public var layer: CALayer {
        get { _layer }
    }
    public var heldObject: Any?

    public init(isRight: Bool, relativeView: UIView) {
        self.isRight = isRight
        self.relativeView = relativeView

        _layer = CAShapeLayer()
        _layer.opacity = 0.5
        _layer.anchorPoint = CGPoint.zero
        _layer.position = CGPoint.zero
        _layer.backgroundColor = UIColor.black.cgColor

        pointerFingerHelper = MMDrawingGestureShadow(forRightHand: isRight)
        twoFingerHelper = MMTwoFingerPanShadow(forRightHand: isRight)
        thumbAndIndexHelper = MMThumbAndIndexShadow(isRight: isRight)

        super.init()
    }

    public var isActive: Bool {
        return isBezeling || isPanning || isDrawing || isPinching
    }

    // MARK: - Bezeling Pages

    public func startBezelingIn(fromRight: Bool, withTouches touches: [UITouch]) {
        activeTouches = Set(touches)
        isBezeling = true
        layer.opacity = 0.5
        continueBezelingIn(fromRight: fromRight, withTouches: touches)
    }

    public func continueBezelingIn(fromRight: Bool, withTouches touches: [UITouch]) {
        if !isBezeling {
            startBezelingIn(fromRight: fromRight, withTouches: touches)
            return
        }
        var indexFingerTouch = touches.first
        if !isRight && touches.last?.location(in: relativeView).x ?? 0 > indexFingerTouch?.location(in: relativeView).x ?? 0 {
            indexFingerTouch = touches.last
        } else if isRight && touches.last?.location(in: relativeView).x ?? 0 < indexFingerTouch?.location(in: relativeView).x ?? 0 {
            indexFingerTouch = touches.last
        }
        let middleFingerTouch = touches.first == indexFingerTouch ? touches.last : touches.first

        var indexFingerLocation = indexFingerTouch?.location(in: relativeView) ?? CGPoint.zero
        var middleFingerLocation = middleFingerTouch?.location(in: relativeView) ?? CGPoint.zero
        if touches.count == 1 {
            if fromRight {
                if isRight {
                    middleFingerLocation = CGPoint(x: relativeView.bounds.size.width + 15, y: indexFingerLocation.y)
                } else {
                    indexFingerLocation = CGPoint(x: relativeView.bounds.size.width + 15, y: indexFingerLocation.y)
                }
            } else {
                if isRight {
                    indexFingerLocation = CGPoint(x: -15, y: indexFingerLocation.y)
                } else {
                    middleFingerLocation = CGPoint(x: -15, y: indexFingerLocation.y)
                }
            }
        }
        continuePanningWithIndexFinger(indexFingerLocation, andMiddleFinger: middleFingerLocation)
    }

    public func endBezelingIn(fromRight: Bool, withTouches touches: [UITouch]) {
        if isBezeling {
            if touches.isEmpty || activeTouches == Set(touches) {
                activeTouches = nil
                layer.opacity = 0
                isBezeling = false
            }
        }
    }

    // MARK: - Panning a Page

    public func startPanningObject(_ obj: Any, withTouches touches: [UITouch]) {
        heldObject = obj
        isPanning = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePanningObject(obj, withTouches: touches)
    }

    public func continuePanningObject(_ obj: Any, withTouches touches: [UITouch]) {
        if !isPanning {
            startPanningObject(obj, withTouches: touches)
        }
        if obj as AnyObject !== heldObject as AnyObject {
            fatalError("ShadowException: Asked to pan different object than what's held.")
        }
        if touches.count >= 2 {
            var indexFingerTouch = touches.first?.location(in: relativeView) ?? CGPoint.zero
            if !isRight && touches.last?.location(in: relativeView).x ?? 0 > indexFingerTouch.x {
                indexFingerTouch = touches.last?.location(in: relativeView) ?? CGPoint.zero
            } else if isRight && touches.last?.location(in: relativeView).x ?? 0 < indexFingerTouch.x {
                indexFingerTouch = touches.last?.location(in: relativeView) ?? CGPoint.zero
            }
            let middleFingerTouch = touches.first?.location(in: relativeView) == indexFingerTouch ? touches.last?.location(in: relativeView) : touches.first?.location(in: relativeView)

            continuePanningWithIndexFinger(indexFingerTouch, andMiddleFinger: middleFingerTouch ?? CGPoint.zero)
        }
    }

    public func endPanningObject(_ obj: Any) {
        if obj as AnyObject !== heldObject as AnyObject {
            fatalError("ShadowException: Asked to stop holding different object than what's held.")
        }
        if isPanning {
            activeTouches = nil
            isPanning = false
            heldObject = nil
            layer.opacity = 0
        }
    }

    // MARK: - Pinching a Page

    public func startPinchingObject(_ obj: Any, withTouches touches: [UITouch]) {
        heldObject = obj
        isPinching = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePinchingObject(obj, withTouches: touches)
    }

    public func continuePinchingObject(_ obj: Any, withTouches touches: [UITouch]) {
        if !isPinching {
            return
        }
        if obj as AnyObject !== heldObject as AnyObject {
            fatalError("ShadowException: Asked to pinch object than what's held.")
        }
        if touches.count >= 2 {
            var indexFingerLocation = touches.first?.location(in: relativeView) ?? CGPoint.zero
            if touches.last?.location(in: relativeView).y ?? 0 < indexFingerLocation.y {
                indexFingerLocation = touches.last?.location(in: relativeView) ?? CGPoint.zero
            }
            let middleFingerLocation = touches.first?.location(in: relativeView) == indexFingerLocation ? touches.last?.location(in: relativeView) : touches.first?.location(in: relativeView)

            let distance = HandShadow.distanceBetweenPoint(indexFingerLocation, andPoint: middleFingerLocation ?? CGPoint.zero)

            thumbAndIndexHelper.setFingerDistance(idealDistance: distance)
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _layer.path = thumbAndIndexHelper.pathForTouches().cgPath

            var currVector = (middleFingerLocation ?? CGPoint.zero) - indexFingerLocation
            if !isRight {
                currVector = currVector.flipped()
            }
            let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
            let offset = thumbAndIndexHelper.locationOfIndexFingerInPathBounds()
            let finalLocation = CGPoint(x: indexFingerLocation.x - offset.x, y: indexFingerLocation.y - offset.y)
            _layer.position = finalLocation
            _layer.setAffineTransform(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
            CATransaction.commit()
        }
    }

    public func endPinchingObject(_ obj: Any) {
        if obj as AnyObject !== heldObject as AnyObject {
            fatalError("ShadowException: Asked to stop holding different object than what's held.")
        }
        if isPinching {
            activeTouches = nil
            isPinching = false
            heldObject = nil
            layer.opacity = 0
        }
    }

    // MARK: - Drawing Events

    public func startDrawingAtTouch(_ touch: CGPoint) {
        isDrawing = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continueDrawingAtTouch(touch)
    }

    public func continueDrawingAtTouch(_ locationOfTouch: CGPoint) {
        if !isDrawing {
            startDrawingAtTouch(locationOfTouch)
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        _layer.path = pointerFingerHelper.path.cgPath
        let offset = pointerFingerHelper.locationOfIndexFingerInPathBounds
        let finalLocation = CGPoint(x: locationOfTouch.x - offset.x, y: locationOfTouch.y - offset.y)
        layer.position = finalLocation
        CATransaction.commit()
    }

    public func endDrawing() {
        if isDrawing {
            activeTouches = nil
            isDrawing = false
            if !isPanning && !isBezeling {
                layer.opacity = 0
            }
        }
    }

    // MARK: - Private

    private func continuePanningWithIndexFinger(_ indexFingerLocation: CGPoint, andMiddleFinger middleFingerLocation: CGPoint) {
        let distance = HandShadow.distanceBetweenPoint(indexFingerLocation, andPoint: middleFingerLocation)
        twoFingerHelper.setFingerDistance(idealDistance: distance)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        _layer.path = twoFingerHelper.pathForTouches().cgPath

        var currVector = CGVector(start: indexFingerLocation, end: middleFingerLocation)
        if !isRight {
            currVector = currVector.flipped()
        }

        let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
        let offset = twoFingerHelper.locationOfIndexFingerInPathBounds
        let finalLocation = CGPoint(x: indexFingerLocation.x - offset.x, y: indexFingerLocation.y - offset.y)

        print("isright: \(isRight)  recentTheta: \(recentTheta)   theta: \(theta)")
        if recentTheta == CGFloat.greatestFiniteMagnitude {
            if !isRight && theta < 0 && theta > -CGFloat.pi {
                continuePanningWithIndexFinger(middleFingerLocation, andMiddleFinger: indexFingerLocation)
                return
            }
            recentTheta = theta
            print("isright: \(isRight)  setRecentTheta: \(recentTheta)")
        } else if abs(recentTheta-theta) > CGFloat.pi/2 && abs(recentTheta-theta) < CGFloat.pi*3/2 {
            continuePanningWithIndexFinger(middleFingerLocation, andMiddleFinger: indexFingerLocation)
            return
        } else {
            recentTheta = theta
            print("isright: \(isRight)  setRecentTheta: \(recentTheta)")
        }

        _layer.position = finalLocation
        _layer.setAffineTransform(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
        CATransaction.commit()
    }

    func preventCALayerImplicitAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }

    static func distanceBetweenPoint(_ p1: CGPoint, andPoint p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
}