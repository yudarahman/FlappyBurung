//
//  RandomFunction.swift
//  FlappyBurung
//
//  Created by Yuda on 1/2/18.
//  Copyright © 2018 Yuda. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public extension CGFloat {
    
    public static func random() -> CGFloat {
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min: CGFloat, max: CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
    }
}
