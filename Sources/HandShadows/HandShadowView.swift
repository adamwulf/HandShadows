//
//  HandShadowView.swift
//
//
//  Created by Adam Wulf on 1/19/24.
//

import UIKit

public class HandShadowView: UIView {
    let rightHand: HandShadow
    let leftHand: HandShadow

    override public init(frame: CGRect) {
        leftHand = HandShadow(for: .leftHand)
        rightHand = HandShadow(for: .rightHand)
        super.init(frame: frame)

        backgroundColor = .clear
        isOpaque = false

        layer.addSublayer(leftHand.layer)
        layer.addSublayer(rightHand.layer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Pan

    @objc public func startPanningObject(withTouches touches: [CGPoint], forHand hand: HandType) {
        if hand.isRight {
            rightHand.startPanningObject(withTouches: touches)
        } else {
            leftHand.startPanningObject(withTouches: touches)
        }
    }

    @objc public func continuePanningObject(withTouches touches: [CGPoint], forHand hand: HandType) {
        if hand.isRight {
            rightHand.continuePanningObject(withTouches: touches)
        } else {
            leftHand.continuePanningObject(withTouches: touches)
        }
    }

    @objc public func endPanningObject(forHand hand: HandType) {
        if hand.isRight {
            rightHand.endPanningObject()
        } else {
            leftHand.endPanningObject()
        }
    }

    // Pinch

    @objc public func startPinchingObject(withTouches touches: [CGPoint]) {
        rightHand.startPinchingObject(withTouches: touches)
    }

    @objc public func continuePinchingObject(withTouches touches: [CGPoint]) {
        rightHand.continuePinchingObject(withTouches: touches)
    }

    @objc public func endPinchingObject() {
        rightHand.endPinchingObject()
    }

    // MARK: - Touch

    @objc public func startDrawingAtTouch(_ touch: CGPoint) {
        if !(rightHand.isActive) {
            rightHand.startDrawingAtTouch(touch)
        } else {
            leftHand.startDrawingAtTouch(touch)
        }
    }

    @objc public func continueDrawingAtTouch(_ touch: CGPoint) {
        if rightHand.isActive {
            rightHand.continueDrawingAtTouch(touch)
        } else {
            leftHand.continueDrawingAtTouch(touch)
        }
    }

    @objc public func endDrawing() {
        if rightHand.isPointing {
            rightHand.endDrawing()
        }
        if leftHand.isPointing {
            leftHand.endDrawing()
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
