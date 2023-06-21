//
//  PopupModifier.swift
//  Grabbit
//
//  Created by Vin Bui on 6/19/23.
//

import SwiftUI

struct PopupModifier: ViewModifier {
    
    let image: Image
    let imageColor: Color
    let showPopup: Bool
    let text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
            
            VStack {
                if showPopup {
                    PopupView(image: image, imageColor: imageColor, text: text)
                }
            }
            .animation(.easeOut)
        }
    }
    
}

extension View {
    
    func popup(showPopup: Bool, image: Image, imageColor: Color, text: String) -> some View {
        modifier(PopupModifier(image: image, imageColor: imageColor, showPopup: showPopup, text: text))
    }
    
}
