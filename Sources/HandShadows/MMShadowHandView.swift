//
//  File.swift
//  
//
//  Created by Adam Wulf on 1/19/24.
//

import UIKit

@objc public enum HandType: Int {
    case leftHand = 0
    case rightHand = 1
}

public class MMShadowHandView: UIView {
    var pointerFingerHelper: MMDrawingGestureShadow?
    var rightHand: HandShadow?
    var leftHand: HandShadow?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        leftHand = HandShadow(isRight: false, relativeView: self)
        rightHand = HandShadow(isRight: true, relativeView: self)

        self.backgroundColor = .clear
        self.isOpaque = false

        self.layer.addSublayer(leftHand!.layer)
        self.layer.addSublayer(rightHand!.layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Right Bezel

    @objc public func startBezelingIn(fromRight: Bool, withTouches touches: [UITouch]) {
        rightHand?.startBezelingIn(fromRight: fromRight, withTouches: touches)
    }

    @objc public func continueBezelingIn(fromRight: Bool, withTouches touches: [UITouch]) {
        rightHand?.continueBezelingIn(fromRight: fromRight, withTouches: touches)
    }

    @objc public func endBezelingIn(fromRight: Bool, withTouches touches: [UITouch]) {
        rightHand?.endBezelingIn(fromRight: fromRight, withTouches: touches)
    }

    // MARK: - Pan

    @objc public func startPanningObject(_ obj: Any, withTouches touches: [UITouch], forHand hand: HandType) {
        if hand == .rightHand {
            rightHand?.startPanningObject(obj, withTouches: touches)
        } else {
            leftHand?.startPanningObject(obj, withTouches: touches)
        }
    }

    @objc public func continuePanningObject(_ obj: Any, withTouches touches: [UITouch], forHand hand: HandType) {
        if hand == .rightHand {
            rightHand?.continuePanningObject(obj, withTouches: touches)
        } else {
            leftHand?.continuePanningObject(obj, withTouches: touches)
        }
    }

    @objc public func endPanningObject(_ obj: Any, forHand hand: HandType) {
        if hand == .rightHand {
            rightHand?.endPanningObject(obj)
        } else {
            leftHand?.endPanningObject(obj)
        }
    }

    // Pinch

    @objc public func startPinchingObject(_ obj: Any, withTouches touches: [UITouch]) {
        rightHand?.startPinchingObject(obj, withTouches: touches)
    }

    @objc public func continuePinchingObject(_ obj: Any, withTouches touches: [UITouch]) {
        rightHand?.continuePinchingObject(obj, withTouches: touches)
    }

    @objc public func endPinchingObject(_ obj: Any) {
        rightHand?.endPinchingObject(obj)
    }

    // MARK: - Touch

    @objc public func startDrawingAtTouch(_ touch: CGPoint) {
        if !(rightHand?.isActive ?? false) {
            rightHand?.startDrawingAtTouch(touch)
        } else {
            leftHand?.startDrawingAtTouch(touch)
        }
    }

    @objc public func continueDrawingAtTouch(_ touch: CGPoint) {
        if rightHand?.isActive ?? false {
            rightHand?.continueDrawingAtTouch(touch)
        } else {
            leftHand?.continueDrawingAtTouch(touch)
        }
    }

    @objc public func endDrawing() {
        if rightHand?.isDrawing ?? false {
            rightHand?.endDrawing()
        }
        if leftHand?.isDrawing ?? false {
            leftHand?.endDrawing()
        }
    }

    // MARK: - Ignore Touches

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }

    // MARK: - CALayer Helper

    private func preventCALayerImplicitAnimation(_ block: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        block()
        CATransaction.commit()
    }
}
