//
//  Font+Extension.swift
//  Grabbit
//
//  Created by Vin Bui on 6/16/23.
//

import SwiftUI

extension Font {
    
    static func sfProRounded(size: CGFloat, weight: Weight) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }
    
    static func spartanLight(size: CGFloat) -> Font {
        return Font(UIFont(name: "LeagueSpartan-Light", size: size) ?? .systemFont(ofSize: size))
    }
    
}
