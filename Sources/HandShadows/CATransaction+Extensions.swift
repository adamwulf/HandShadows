//
//  File.swift
//  
//
//  Created by Adam Wulf on 1/20/24.
//

import QuartzCore

extension CATransaction {
    static func preventImplicitAnimation(_ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }
}
