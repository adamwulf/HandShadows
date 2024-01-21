//
//  HandShadowView.swift
//
//
//  Created by Adam Wulf on 1/19/24.
//

import UIKit

@objc public enum HandType: Int {
    case leftHand = 0
    case rightHand = 1
}

public class HandShadowView: UIView {
    var pointerFingerHelper: IndexFingerShadow?
    var rightHand: HandShadow?
    var leftHand: HandShadow?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        leftHand = HandShadow(isRight: false, relativeView: self)
        rightHand = HandShadow(isRight: true, relativeView: self)

        backgroundColor = .clear
        isOpaque = false

        layer.addSublayer(leftHand!.layer)
        layer.addSublayer(rightHand!.layer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Pan

    @objc public func startPanningObject(_ obj: Any, withTouches touches: [CGPoint], forHand hand: HandType) {
        if hand == .rightHand {
            rightHand?.startPanningObject(obj, withTouches: touches)
        } else {
            leftHand?.startPanningObject(obj, withTouches: touches)
        }
    }

    @objc public func continuePanningObject(_ obj: Any, withTouches touches: [CGPoint], forHand hand: HandType) {
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

    @objc public func startPinchingObject(_ obj: Any, withTouches touches: [CGPoint]) {
        rightHand?.startPinchingObject(obj, withTouches: touches)
    }

    @objc public func continuePinchingObject(_ obj: Any, withTouches touches: [CGPoint]) {
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

    override public func hitTest(_: CGPoint, with _: UIEvent?) -> UIView? {
        return nil
    }

    override public func point(inside _: CGPoint, with _: UIEvent?) -> Bool {
        return false
    }
}
