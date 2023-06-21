//
//  ConfirmationModifier.swift
//  Grabbit
//
//  Created by Vin Bui on 6/19/23.
//

import SwiftUI

struct ConfirmationModifier: ViewModifier {
    
    let action: String
    let heading: String
    let subheading: String
    let showConfirmation: Bool
    
    @Binding var confirmationStatus: ConfirmationStatus
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
                .blur(radius: showConfirmation ? 1 : 0)
            
            VStack {
                if showConfirmation {
                    ConfirmationView(action: action, heading: heading, subheading: subheading, confirmationStatus: $confirmationStatus)
                }
            }
            .animation(.easeOut)
        }
    }
    
}

extension View {
    
    func showConfirmation(action: String, heading: String, subheading: String, showConfirmation: Bool, confirmationStatus: Binding<ConfirmationStatus>) -> some View {
        modifier(ConfirmationModifier(action: action, heading: heading, subheading: subheading, showConfirmation: showConfirmation, confirmationStatus: confirmationStatus))
    }
    
}
