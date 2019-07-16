//
//  Helper.swift
//  ZombieGo
//
//  Created by Lo Howard on 7/8/19.
//  Copyright © 2019 Lo Howard. All rights reserved.
//

import Foundation

func randomPosition(lowerBound lower:Float, upperBound upper:Float) -> Float {
    return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
}

func randomNumber(lowerBound lower:Int, upperBound upper:Int) -> Int {
    return Int(arc4random()) / Int(UInt32.max) * (lower - upper) + upper
}

func randomEleven() -> Int {
    let whatever = Bool.random()
    if whatever {
        return 11
    } else {
        return -11
    }
}
