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

    public var isActive: Bool {
        return handShadow.isActive
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

    @objc public func startTwoFingerPan(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startTwoFingerPan(with: firstPoint, and: secondPoint)
    }

    @objc public func continueTwoFingerPan(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(handShadow.isPanning, "shadow is not panning")
        handShadow.continueTwoFingerPan(with: firstPoint, and: secondPoint)
    }

    @objc public func endTwoFingerPan() {
        assert(handShadow.isPanning, "shadow is not panning")
        handShadow.endTwoFingerPan()
    }

    // MARK: - Pinch

    @objc public func startPinch(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startPinch(with: firstPoint, and: secondPoint)
    }

    @objc public func continuePinch(with firstPoint: CGPoint, and secondPoint: CGPoint) {
        assert(handShadow.isPinching, "shadow is not pinching")
        handShadow.continuePinch(with: firstPoint, and: secondPoint)
    }

    @objc public func endPinch() {
        assert(handShadow.isPinching, "shadow is not pinching")
        handShadow.endPinch()
    }

    // MARK: - Index Finger Pointing

    @objc public func startPointing(at point: CGPoint) {
        assert(!handShadow.isActive, "shadow already active")
        handShadow.startPointing(at: point)
    }

    @objc public func continuePointing(at point: CGPoint) {
        assert(handShadow.isPointing, "shadow is not pointing")
        handShadow.continuePointing(at: point)
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
