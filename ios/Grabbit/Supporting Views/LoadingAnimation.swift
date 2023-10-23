//
//  LoadingAnimation.swift
//  Grabbit
//
//  Created by Vin Bui on 6/18/23.
//

import SwiftUI

struct LoadingAnimation: View {
    
    let text: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack(spacing: 8) {
                DotView()
                DotView(delay: 0.2)
                DotView(delay: 0.4)
            }

            Text(text)
                .font(.sfProRounded(size: 16, weight: .semibold))
                .foregroundColor(Color.grabbit.offWhite)
        }
    }
    
}

struct DotView: View {
    
    @State var delay: Double = 0
    @State var scale: CGFloat = 0.5
    
    var body: some View {
        Circle()
            .frame(width: 32, height: 32)
            .scaleEffect(scale)
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever().delay(delay)) {
                        self.scale = 0.75
                    }
                }
            }
    }
    
}
