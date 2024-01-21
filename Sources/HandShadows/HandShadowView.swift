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

    @objc public func startPanningObject(withTouches touches: [CGPoint]) {
        handShadow.startPanningObject(withTouches: touches)
    }

    @objc public func continuePanningObject(withTouches touches: [CGPoint]) {
        handShadow.continuePanningObject(withTouches: touches)
    }

    @objc public func endPanningObject() {
        handShadow.endPanningObject()
    }

    // MARK: - Pinch

    @objc public func startPinchingObject(withTouches touches: [CGPoint]) {
        handShadow.startPinchingObject(withTouches: touches)
    }

    @objc public func continuePinchingObject(withTouches touches: [CGPoint]) {
        handShadow.continuePinchingObject(withTouches: touches)
    }

    @objc public func endPinchingObject() {
        handShadow.endPinchingObject()
    }

    // MARK: - Index Finger Pointing

    @objc public func startPointing(at touch: CGPoint) {
        handShadow.startDrawing(at: touch)
    }

    @objc public func continuePointing(at touch: CGPoint) {
        handShadow.continueDrawing(at: touch)
    }

    @objc public func endPointing() {
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
