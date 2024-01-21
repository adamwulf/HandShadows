//
//  HandShadowView.swift
//
//
//  Created by Adam Wulf on 1/19/24.
//

import UIKit

public class HandShadowView: UIView {
    let handShadow: HandShadow

    @objc public required init(forHand hand: HandType) {
        handShadow = HandShadow(for: hand)
        super.init(frame: .zero)

        backgroundColor = .clear
        isOpaque = false

        layer.addSublayer(handShadow.layer)
    }

    @available(*, unavailable)
    override required init(frame _: CGRect) {
        fatalError("init(frame:) is unavailable")
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Pan

    @objc public func startTwoFingerPan(withTouches touches: [CGPoint]) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startPanningObject(withTouches: touches)
    }

    @objc public func continueTwoFingerPan(withTouches touches: [CGPoint]) {
        assert(handShadow.isPanning, "shadow is not panning")
        handShadow.continuePanningObject(withTouches: touches)
    }

    @objc public func endTwoFingerPan() {
        assert(handShadow.isPanning, "shadow is not panning")
        handShadow.endPanningObject()
    }

    // MARK: - Pinch

    @objc public func startPinch(withTouches touches: [CGPoint]) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startPinchingObject(withTouches: touches)
    }

    @objc public func continuePinch(withTouches touches: [CGPoint]) {
        assert(handShadow.isPinching, "shadow is not pinching")
        handShadow.continuePinchingObject(withTouches: touches)
    }

    @objc public func endPinch() {
        assert(handShadow.isPinching, "shadow is not pinching")
        handShadow.endPinchingObject()
    }

    // MARK: - Index Finger Pointing

    @objc public func startPointing(at touch: CGPoint) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startDrawing(at: touch)
    }

    @objc public func continuePointing(at touch: CGPoint) {
        assert(handShadow.isPointing, "shadow is not pointing")
        handShadow.continueDrawing(at: touch)
    }

    @objc public func endPointing() {
        assert(handShadow.isPointing, "shadow is not pointing")
        handShadow.endDrawing()
    }

    // MARK: - Ignore Touches

    override public func hitTest(_: CGPoint, with _: UIEvent?) -> UIView? {
        return nil
    }

    override public func point(inside _: CGPoint, with _: UIEvent?) -> Bool {
        return false
    }
}
