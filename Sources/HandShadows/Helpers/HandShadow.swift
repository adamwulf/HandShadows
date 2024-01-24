//
//  HandShadow.swift
//
//
//  Created by Adam Wulf on 1/20/24.
//

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

    func startTwoFingerPan(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(!isActive, "shadow must be inactive")
        guard !isActive else { return }

        isPanning = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continueTwoFingerPan(with: firstPoint, and: secondPoint)
    }

    func continueTwoFingerPan(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(isPanning, "shadow must be panning")
        guard isPanning else { return }

        var indexFingerPoint = firstPoint
        if handType.isLeft, secondPoint.x > indexFingerPoint.x {
            indexFingerPoint = secondPoint
        } else if handType.isRight, secondPoint.x < indexFingerPoint.x {
            indexFingerPoint = secondPoint
        }
        let middleFingerPoint = CGPointEqualToPoint(firstPoint, indexFingerPoint) ? secondPoint : firstPoint

        continuePanningWithIndexFinger(indexFingerPoint, andMiddleFinger: middleFingerPoint)
    }

    func endTwoFingerPan() {
        assert(isPanning || !isActive, "shadow must be panning")
        guard isPanning else { return }

        isPanning = false
        layer.opacity = 0
    }

    // MARK: - Pinching a Page

    // Pinching a Page

    func startPinch(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(!isActive, "shadow must be inactive")
        guard !isActive else { return }

        isPinching = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePinch(with: firstPoint, and: secondPoint)
    }

    func continuePinch(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(isPinching, "shadow must be pinching")
        guard isPinching else { return }

        var indexFingerLocation = firstPoint
        if secondPoint.y < indexFingerLocation.y {
            indexFingerLocation = secondPoint
        }
        let middleFingerLocation = CGPointEqualToPoint(firstPoint, indexFingerLocation) ? secondPoint : firstPoint
        let distance = indexFingerLocation.distance(to: middleFingerLocation)

        let result = pinchHelper.setFingerDistance(idealDistance: distance)
        CATransaction.preventImplicitAnimation {
            shapeLayer.path = result.path.cgPath

            var currVector = CGVector(start: indexFingerLocation, end: middleFingerLocation)
            if handType.isLeft {
                currVector.flip()
            }
            let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
            let offset = result.indexFingerLocation
            let finalLocation = CGPoint(x: indexFingerLocation.x - offset.x, y: indexFingerLocation.y - offset.y)
            shapeLayer.position = finalLocation
            shapeLayer.setAffineTransform(CGAffineTransform(translationX: offset.x, y: offset.y).rotated(by: theta).translatedBy(x: -offset.x, y: -offset.y))
        }
    }

    func endPinch() {
        assert(isPinching || !isActive, "shadow must be pinching")
        guard isPinching else { return }

        isPinching = false
        layer.opacity = 0
    }

    // MARK: - Drawing Events

    func startPointing(at point: CGPoint) {
        assert(!isActive, "shadow must be inactive")
        guard !isActive else { return }

        isPointing = true
        layer.opacity = 0.5
        recentTheta = CGFloat.greatestFiniteMagnitude
        continuePointing(at: point)
    }

    func continuePointing(at point: CGPoint) {
        assert(isPointing, "shadow must be pointing")
        guard isPointing else { return }

        CATransaction.preventImplicitAnimation {
            shapeLayer.path = pointerFingerHelper.path.cgPath
            let offset = pointerFingerHelper.indexFingerLocation
            let finalLocation = CGPoint(x: point.x - offset.x, y: point.y - offset.y)
            shapeLayer.position = finalLocation
            shapeLayer.setAffineTransform(.identity)
        }
    }

    func endPointing() {
        assert(isPointing || !isActive, "shadow must be pointing")
        guard isPointing else { return }

        isPointing = false
        layer.opacity = 0
    }

    // MARK: - Private

    private func continuePanningWithIndexFinger(_ indexFingerLocation: CGPoint, andMiddleFinger middleFingerLocation: CGPoint) {
        let distance = indexFingerLocation.distance(to: middleFingerLocation)
        let result = twoFingerPanHelper.setFingerDistance(idealDistance: distance)
        CATransaction.preventImplicitAnimation {
            shapeLayer.path = result.path.cgPath

            var currVector = CGVector(start: indexFingerLocation, end: middleFingerLocation)
            if handType.isLeft {
                currVector.flip()
            }

            let theta = CGVector(dx: 1, dy: 0).angleBetween(currVector)
            let offset = result.indexFingerLocation
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
