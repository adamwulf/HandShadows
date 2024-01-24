//
//  HandType.swift
//
//
//  Created by Adam Wulf on 1/20/24.
//

import Foundation

@objc public enum HandType: Int {
    case leftHand = 0
    case rightHand = 1

    var isRight: Bool {
        return self == .rightHand
    }

    var isLeft: Bool {
        return self == .leftHand
    }

    var stringValue: String {
        switch self {
        case .leftHand: return "left"
        case .rightHand: return "right"
        }
    }
}
