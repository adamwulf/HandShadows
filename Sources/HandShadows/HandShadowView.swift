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
        handShadow.startTwoFingerPan(withTouches: touches)
    }

    @objc public func continueTwoFingerPan(withTouches touches: [CGPoint]) {
        assert(handShadow.isPanning, "shadow is not panning")
        handShadow.continueTwoFingerPan(withTouches: touches)
    }

    @objc public func endTwoFingerPan() {
        assert(handShadow.isPanning, "shadow is not panning")
        handShadow.endTwoFingerPan()
    }

    // MARK: - Pinch

    @objc public func startPinch(withTouches touches: [CGPoint]) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startPinch(withTouches: touches)
    }

    @objc public func continuePinch(withTouches touches: [CGPoint]) {
        assert(handShadow.isPinching, "shadow is not pinching")
        handShadow.continuePinch(withTouches: touches)
    }

    @objc public func endPinch() {
        assert(handShadow.isPinching, "shadow is not pinching")
        handShadow.endPinch()
    }

    // MARK: - Index Finger Pointing

    @objc public func startPointing(at touch: CGPoint) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startPointing(at: touch)
    }

    @objc public func continuePointing(at touch: CGPoint) {
        assert(handShadow.isPointing, "shadow is not pointing")
        handShadow.continuePointing(at: touch)
    }

    @objc public func endPointing() {
        assert(handShadow.isPointing, "shadow is not pointing")
        handShadow.endPointing()
    }

    // MARK: - Ignore Touches

    override public func hitTest(_: CGPoint, with _: UIEvent?) -> UIView? {
        return nil
    }

    override public func point(inside _: CGPoint, with _: UIEvent?) -> Bool {
        return false
    }
}
