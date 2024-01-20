//
//  File.swift
//  
//
//  Created by Adam Wulf on 1/19/24.
//

import Foundation

func distance(p1: CGPoint, p2: CGPoint ) -> CGFloat {
    return sqrt(pow((p2.x-p1.x), 2) + pow((p2.y-p1.y), 2))
}
