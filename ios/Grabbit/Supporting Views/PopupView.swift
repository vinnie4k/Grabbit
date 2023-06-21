//
//  PopupView.swift
//  Grabbit
//
//  Created by Vin Bui on 6/19/23.
//

import SwiftUI

struct PopupView: View {
    
    let image: Image
    let imageColor: Color
    let text: String
        
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            image
                .resizable()
                .scaledToFit()
                .foregroundColor(imageColor)
                .frame(width: 36, height: 36)
            
            Text(text)
                .font(.sfProRounded(size: 14, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
        .frame(width: 128, height: 128)
        .background(Color.grabbit.background)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
}

//struct PopupView_Previews: PreviewProvider {
//    static var previews: some View {
//        PopupView(image: Image.grabbit.checkmark, imageColor: Color.grabbit.success, text: "Copied to clipboard")
//    }
//}
