//
//  BackgroundModifier.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct BackgroundModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        ZStack {
            Color.grabbit.background
                .ignoresSafeArea()
            
            content
        }
    }
    
}

extension View {
    
    func setBackground() -> some View {
        modifier(BackgroundModifier())
    }
    
}
