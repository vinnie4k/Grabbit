//
//  StatusDots.swift
//  Grabbit
//
//  Created by Vin Bui on 6/17/23.
//

import SwiftUI

struct StatusDots: View {
    
    // MARK: - Properties
    
    @State private var color: Color? = nil
    let status: Status
    
    // MARK: - UI
    
    var body: some View {
        Circle()
            .frame(width: 16, height: 16)
            .foregroundColor(color)
            .onAppear {
                switch status {
                case .closed:
                    color = Color.grabbit.error
                case .open:
                    color = Color.grabbit.success
                case .waitlisted:
                    color = Color.grabbit.warning
                }
            }
    }
    
}
